import 'dart:convert';
import '../models/operation.dart';
import '../models/protobuf_mapper.dart';
import '../generated/gantt_protocol.pb.dart';
import '../models/protocol_extensions.dart';
import '../models/protocol_tag.dart';
import 'merkle_tree.dart';
import 'merkle_hash_normalizer.dart';
import 'hlc.dart';

/// The core engine for Conflict-Free Replicated Data Types (CRDT) logic.
///
/// Handles merging of tasks, resources, and tags based on Last-Write-Wins (LWW)
/// and hybrid logical clocks.
class CRDTEngine {
  /// Merges a list of tasks with a list of operations.
  /// Uses "Hybrid Sovereignty" logic:
  /// - Field-Level LWW (Map-CRDT) for properties.
  /// - Add-Wins OR-Set (Tombstones) for existence.
  /// Returns tombstones as state; UI callers must filter [ProtocolTask.isDeleted].
  List<ProtocolTask> mergeTasks(
    List<ProtocolTask> currentTasks,
    List<Operation> operations,
  ) {
    // 1. Initialize map with existing tasks
    final taskMap = {for (var t in currentTasks) t.id: t};

    // 2. Apply operations sequentially
    for (var op in operations) {
      if (op.type == 'BATCH_UPDATE') {
        final subOpsList = op.data['operations'] as List? ?? [];
        for (final subOpMaps in subOpsList) {
          try {
            final opMap = subOpMaps as Map<String, dynamic>;
            final subOp = Operation.fromJson(opMap);
            _applyOp(taskMap, subOp);
          } catch (e) {
            print('CRDTEngine Error processing batch op: $e');
          }
        }
      } else {
        _applyOp(taskMap, op);
      }
    }

    // Retain tombstones for subsequent merges and Merkle reconciliation.
    return taskMap.values.toList();
  }

  /// Merges resources, retaining tombstones for later merges and integrity checks.
  List<ProtocolResource> mergeResources(
    List<ProtocolResource> currentResources,
    List<Operation> operations,
  ) {
    // 1. Initialize map with existing resources
    final resourceMap = {for (var r in currentResources) r.id: r};

    // 2. Apply operations sequentially
    for (var op in operations) {
      if (op.type == 'BATCH_UPDATE') {
        final subOpsList = op.data['operations'] as List? ?? [];
        for (final subOpMaps in subOpsList) {
          try {
            final opMap = subOpMaps as Map<String, dynamic>;
            final subOp = Operation.fromJson(opMap);
            _applyResourceOp(resourceMap, subOp);
          } catch (e) {
            print('CRDTEngine Error processing batch op (resource): $e');
          }
        }
      } else {
        _applyResourceOp(resourceMap, op);
      }
    }

    return resourceMap.values.toList();
  }

  void _applyResourceOp(
    Map<String, ProtocolResource> resourceMap,
    Operation op,
  ) {
    if (!const {
      'DELETE_RESOURCE',
      'INSERT_RESOURCE',
      'UPDATE_RESOURCE',
    }.contains(op.type)) {
      return;
    }

    final opData = op.data;
    var effectiveData = opData;
    if (effectiveData.containsKey('data') && effectiveData['data'] is Map) {
      effectiveData = effectiveData['data'];
    }

    final String? resourceId = effectiveData['id'] as String?;
    if (resourceId == null) return;

    final existing = resourceMap[resourceId];
    // If not exists, create new
    final base =
        existing ??
        (ProtocolResource()
          ..id = resourceId
          ..name = ''
          ..isDeleted = true
          ..lastUpdated = Hlc.zero.toString());

    resourceMap[resourceId] = _mergeResource(base, op, {
      ...effectiveData,
      'isDeleted':
          op.type == 'DELETE_RESOURCE' || effectiveData['isDeleted'] == true,
    });
  }

  ProtocolResource _mergeResource(
    ProtocolResource target,
    Operation op,
    Map<String, dynamic> changes,
  ) {
    final deleted = changes['isDeleted'] == true;
    if (op.timestamp < target.parsedLastUpdated ||
        (target.isDeleted &&
            !deleted &&
            op.timestamp <= target.parsedLastUpdated)) {
      return target;
    }
    if (deleted) {
      return ProtocolResource(
        id: target.id,
        name: '',
        parentId: '',
        type: 'person',
        isDeleted: true,
        metadataJson: '{}',
        lastUpdated: op.timestamp.toString(),
      );
    }
    // Resource updates are complete LWW records. Inheriting an absent field
    // from previous state would make replay depend on delivery order.
    return ProtobufMapper.resourceFromJson(changes)
      ..lastUpdated = op.timestamp.toString()
      ..isDeleted = false;
  }

  void _applyOp(Map<String, ProtocolTask> taskMap, Operation op) {
    if (op.type == 'DELETE_TASK') {
      final taskId = op.data['id'] as String? ?? op.data['taskId'] as String?;
      if (taskId == null) return;

      final existing = taskMap[taskId];

      // Basic tombstone creation
      final base =
          existing ??
          (ProtocolTask()
            ..id = taskId
            ..rowId = ''
            ..start = DateTime.utc(1970, 1, 1).toIso8601String()
            ..end = DateTime.utc(1970, 1, 2).toIso8601String()
            ..lastUpdated = Hlc.zero.toString()
            ..isDeleted = true); // minimally valid tombstone

      final fieldClocks = op.data['fieldTimestamps'];
      final deletionData = fieldClocks is Map && fieldClocks.isNotEmpty
          ? op.data
          : <String, dynamic>{'id': taskId};
      taskMap[taskId] = _mergeTask(base, op, {
        ...deletionData,
        'isDeleted': true,
      });
      return;
    }

    if (!const {'INSERT_TASK', 'UPDATE_TASK', 'UPDATE'}.contains(op.type)) {
      return;
    }

    final opData = op.data;
    var effectiveData = opData;
    if (effectiveData.containsKey('data') && effectiveData['data'] is Map) {
      effectiveData = effectiveData['data'];
    }

    final String? taskId =
        effectiveData['id'] as String? ?? effectiveData['taskId'] as String?;
    if (taskId == null) return;

    final existing = taskMap[taskId];
    // For INSERT/UPDATE, we assume isDeleted=false (Resurrection)
    final base =
        existing ??
        (ProtocolTask()
          ..id = taskId
          ..rowId = ''
          ..start = DateTime.utc(1970, 1, 1).toIso8601String()
          ..end = DateTime.utc(1970, 1, 2).toIso8601String()
          ..lastUpdated = Hlc.zero.toString()
          ..isDeleted = false);

    // Inject isDeleted=false into the data to force resurrection check
    final mergeData = Map<String, dynamic>.from(effectiveData);
    mergeData['isDeleted'] = effectiveData['isDeleted'] == true;

    taskMap[taskId] = _mergeTask(base, op, mergeData);
  }

  ProtocolTask _mergeTask(
    ProtocolTask target,
    Operation op,
    Map<String, dynamic> changes,
  ) {
    final newTimestamps = Map<String, String>.from(target.fieldTimestamps);
    final baseline = target.lastUpdated.isEmpty
        ? Hlc.zero.toString()
        : target.lastUpdated;
    for (final field in [
      'rowId',
      'start',
      'end',
      'name',
      'completion',
      'resourceId',
      'parentId',
      'notes',
      'isSummary',
      'isMilestone',
      'isDeleted',
    ]) {
      newTimestamps.putIfAbsent(field, () => baseline);
    }
    final priorMetadata = ProtobufMapper.metadataFromJson({
      'metadataJson': target.metadataJson,
    });
    for (final key in priorMetadata.keys) {
      newTimestamps.putIfAbsent(key, () => baseline);
    }

    final incomingTimestamps = changes['fieldTimestamps'] as Map?;
    Hlc fieldClock(String field) {
      if (field == 'isDeleted' && changes['isDeleted'] != true) {
        return op.timestamp;
      }
      final value = incomingTimestamps?[field];
      return value is String && value.isNotEmpty
          ? Hlc.parse(value)
          : op.timestamp;
    }

    // Snapshot fields keep their individual clocks; a newer envelope does not
    // turn unchanged fields into newer edits.
    bool shouldUpdate(String field) {
      final lastHlcStr = newTimestamps[field] ?? Hlc.zero.toString();
      final lastHlc = lastHlcStr.isNotEmpty ? Hlc.parse(lastHlcStr) : Hlc.zero;
      return fieldClock(field) >= lastHlc;
    }

    // Helper to update field
    T update<T>(String field, T candidate, T current) {
      if (field == 'isDeleted' &&
          current == true &&
          candidate == false &&
          fieldClock(field) <= Hlc.parse(newTimestamps[field]!)) {
        return current;
      }
      if (shouldUpdate(field)) {
        newTimestamps[field] = fieldClock(field).toString();
        return candidate;
      }
      return current;
    }

    // 1. Merge "isDeleted" (Resurrection / Deletion)
    bool newIsDeleted = target.isDeleted;
    if (changes.containsKey('isDeleted')) {
      newIsDeleted = update<bool>(
        'isDeleted',
        changes['isDeleted'],
        target.isDeleted,
      );
    }

    // 2. Merge Properties
    String newRowId = target.rowId;
    if (changes.containsKey('rowId')) {
      newRowId = update('rowId', changes['rowId'], target.rowId);
    }

    String newStart = target.start;
    final startVal =
        changes['start'] ?? changes['startDate'] ?? changes['start_date'];
    if (startVal != null) {
      final parsed = _parseDate(startVal);
      if (parsed != null) {
        newStart = update(
          'start',
          parsed.toUtc().toIso8601String(),
          target.start,
        );
      }
    }

    String newEnd = target.end;
    final endVal = changes['end'] ?? changes['endDate'] ?? changes['end_date'];
    if (endVal != null) {
      final parsed = _parseDate(endVal);
      if (parsed != null) {
        newEnd = update('end', parsed.toUtc().toIso8601String(), target.end);
      }
    }

    String newName = target.name;
    if (changes.containsKey('name')) {
      newName = update('name', changes['name'], target.name);
    }

    double newCompletion = target.completion;
    if (changes.containsKey('completion')) {
      newCompletion = update(
        'completion',
        (changes['completion'] as num).toDouble(),
        target.completion,
      );
    }

    String newResourceId = target.resourceId;
    if (changes.containsKey('resourceId')) {
      newResourceId = update(
        'resourceId',
        changes['resourceId'] ?? '',
        target.resourceId,
      );
    }

    String newParentId = target.parentId;
    if (changes.containsKey('parentId')) {
      newParentId = update(
        'parentId',
        changes['parentId'] ?? '',
        target.parentId,
      );
    }

    String newNotes = target.notes;
    if (changes.containsKey('notes')) {
      newNotes = update('notes', changes['notes'] ?? '', target.notes);
    }

    bool newIsSummary = target.isSummary;
    final ganttType = changes['ganttType'] ?? changes['gantt_type'];
    if (changes.containsKey('isSummary') || ganttType != null) {
      newIsSummary = update(
        'isSummary',
        changes['isSummary'] == true ||
            ganttType == 'summary' ||
            ganttType == 'project',
        target.isSummary,
      );
    }

    bool newIsMilestone = target.isMilestone;
    if (changes.containsKey('isMilestone') || ganttType != null) {
      newIsMilestone = update(
        'isMilestone',
        changes['isMilestone'] == true || ganttType == 'milestone',
        target.isMilestone,
      );
    }

    // Metadata Merging (Generalized LWW)
    Map<String, dynamic> currentMetadata = {};
    if (target.hasMetadataJson() && target.metadataJson.isNotEmpty) {
      try {
        currentMetadata =
            jsonDecode(target.metadataJson) as Map<String, dynamic>;
      } catch (_) {}
    }

    Map<String, dynamic> newMetadata = Map.from(currentMetadata);

    ProtobufMapper.metadataFromJson(changes).forEach((key, value) {
      if (shouldUpdate(key)) {
        newMetadata[key] = value;
        newTimestamps[key] = fieldClock(key).toString();
      }
    });

    var maxHlc = op.timestamp > target.parsedLastUpdated
        ? op.timestamp
        : target.parsedLastUpdated;
    for (final value in newTimestamps.values) {
      final fieldHlc = Hlc.parse(value);
      if (fieldHlc > maxHlc) maxHlc = fieldHlc;
    }
    final maxActor = op.timestamp > target.parsedLastUpdated
        ? op.actorId
        : target.lastUpdatedBy;

    return target.deepCopy()
      ..rowId = newRowId
      ..start = newStart
      ..end = newEnd
      ..name = newName
      ..completion = newCompletion
      ..resourceId = newResourceId
      ..parentId = newParentId
      ..notes = newNotes
      ..isSummary = newIsSummary
      ..isMilestone = newIsMilestone
      ..fieldTimestamps.clear()
      ..fieldTimestamps.addAll(newTimestamps)
      ..isDeleted = newIsDeleted
      ..lastUpdated = maxHlc.toString()
      ..lastUpdatedBy = maxActor
      ..metadataJson = jsonEncode(newMetadata);
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) {
      final dt = DateTime.tryParse(value);
      if (dt != null) return dt;
      final ms = int.tryParse(value);
      if (ms != null) return DateTime.fromMillisecondsSinceEpoch(ms);
    }
    return null;
  }

  /// Computes the full Merkle Tree for a list of tasks and dependencies using the deterministic content hash.
  MerkleTree computeMerkleTree(
    List<ProtocolTask> tasks, {
    List<ProtocolDependency> dependencies = const [],
    List<ProtocolResource> resources = const [],
  }) {
    final List<MapEntry<String, String>> items = [];

    for (final t in tasks) {
      items.add(
        MapEntry(
          MerkleHashNormalizer.merkleHlcKey(
            t.hasLastUpdated() ? t.lastUpdated : '',
          ),
          t.contentHash,
        ),
      );
    }
    for (final d in dependencies) {
      items.add(
        MapEntry(
          MerkleHashNormalizer.merkleHlcKey(
            d.hasLastUpdated() ? d.lastUpdated : '',
          ),
          d.contentHash,
        ),
      );
    }
    for (final r in resources) {
      items.add(
        MapEntry(
          MerkleHashNormalizer.merkleHlcKey(
            r.hasLastUpdated() ? r.lastUpdated : '',
          ),
          r.contentHash,
        ),
      );
    }

    return MerkleTree.build(items);
  }

  /// Computes the Merkle Root for a list of tasks and dependencies using the deterministic content hash.
  String computeMerkleRoot(
    List<ProtocolTask> tasks, {
    List<ProtocolDependency> dependencies = const [],
    List<ProtocolResource> resources = const [],
  }) {
    final tree = computeMerkleTree(
      tasks,
      dependencies: dependencies,
      resources: resources,
    );
    return tree.root.hash;
  }

  /// Creates a new immutable Snapshot Tag for the current state.
  ProtocolTag createTag({
    required String name,
    required String id,
    required Hlc timestamp,
    required List<ProtocolTask> tasks,
    List<ProtocolDependency> dependencies = const [],
    List<ProtocolResource> resources = const [],
    String? actorId,
    Map<String, dynamic> metadata = const {},
  }) {
    final root = computeMerkleRoot(
      tasks,
      dependencies: dependencies,
      resources: resources,
    );
    return ProtocolTag(
      id: id,
      name: name,
      merkleRoot: root,
      timestamp: timestamp,
      actorId: actorId,
      metadata: metadata,
    );
  }

  /// Merges a list of tags with a list of operations (CREATE_TAG, DELETE_TAG).
  List<ProtocolTag> mergeTags(
    List<ProtocolTag> currentTags,
    List<Operation> operations,
  ) {
    final tagMap = {for (var t in currentTags) t.id: t};

    for (var op in operations) {
      if (op.type == 'BATCH_UPDATE') {
        final subOpsList = op.data['operations'] as List? ?? [];
        for (final subOpMaps in subOpsList) {
          try {
            final opMap = subOpMaps as Map<String, dynamic>;
            final subOp = Operation.fromJson(opMap);
            _applyTagOp(tagMap, subOp);
          } catch (e) {
            print('CRDTEngine Error processing batch op (tag): $e');
          }
        }
      } else {
        _applyTagOp(tagMap, op);
      }
    }

    return tagMap.values.where((t) => !t.isDeleted).toList();
  }

  void _applyTagOp(Map<String, ProtocolTag> tagMap, Operation op) {
    if (op.type == 'DELETE_TAG') {
      final tagId = op.data['id'] as String?;
      if (tagId == null) return;

      final existing = tagMap[tagId];
      if (existing != null) {
        // Tag deletion is simple LWW on isDeleted or purely add-wins if we treat tags as immutable once created.
        // Assuming we allow deleting tags.
        // Ifop timestamp > existing timestamp? Or just apply delete?
        // Tags are usually immutable states, but the *list* of tags is mutable.
        tagMap[tagId] = existing.copyWith(isDeleted: true);
      }
      return;
    }

    if (op.type != 'CREATE_TAG') return;

    final opData = op.data;
    final String? tagId = opData['id'] as String?;
    if (tagId == null) return;

    final existing = tagMap[tagId];
    if (existing != null) {
      // Tags are immutable. If it exists, we technically shouldn't update it unless we support renaming.
      // But let's assume CREATE_TAG is idempotent.
      // If deleted, resurrect?
      if (existing.isDeleted) {
        tagMap[tagId] = existing.copyWith(isDeleted: false);
      }
      return;
    }

    final newTag = ProtocolTag.fromJson(opData);
    tagMap[tagId] = newTag;
  }
}
