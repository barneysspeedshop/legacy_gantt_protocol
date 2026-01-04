import '../models/operation.dart';
import '../models/protocol_task.dart';
import '../models/protocol_dependency.dart';
import '../models/protocol_resource.dart';
import '../models/protocol_tag.dart';
import 'merkle_tree.dart';
import 'hlc.dart';

class CRDTEngine {
  /// Merges a list of tasks with a list of operations.
  /// Uses Last-Write-Wins (LWW) based on timestamps.
  /// Merges a list of tasks with a list of operations.
  /// Uses "Hybrid Sovereignty" logic:
  /// - Field-Level LWW (Map-CRDT) for properties.
  /// - Add-Wins OR-Set (Tombstones) for existence.
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

    // 3. Return only non-deleted tasks (Tombstones are filtered out for UI)
    return taskMap.values.where((t) => !t.isDeleted).toList();
  }

  /// Merges a list of resources with a list of operations.
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

    // 3. Return non-deleted resources
    return resourceMap.values.where((r) => !r.isDeleted).toList();
  }

  void _applyResourceOp(
    Map<String, ProtocolResource> resourceMap,
    Operation op,
  ) {
    if (op.type == 'DELETE_RESOURCE') {
      final resourceId =
          op.data['id'] as String? ?? op.data['resourceId'] as String?;
      if (resourceId == null) return;

      final existing = resourceMap[resourceId];
      if (existing != null) {
        resourceMap[resourceId] = existing.copyWith(isDeleted: true);
      }
      return;
    }

    if (op.type != 'INSERT_RESOURCE' && op.type != 'UPDATE_RESOURCE') return;

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
        ProtocolResource(
          id: resourceId,
          name: '',
          isDeleted: true, // will be resurrected
        );

    resourceMap[resourceId] = _mergeResource(base, op, effectiveData);
  }

  ProtocolResource _mergeResource(
    ProtocolResource target,
    Operation op,
    Map<String, dynamic> changes,
  ) {
    String newName = target.name;
    if (changes.containsKey('name')) newName = changes['name'];

    String? newParentId = target.parentId;
    if (changes.containsKey('parentId')) newParentId = changes['parentId'];

    String newType = target.type;
    if (changes.containsKey('ganttType'))
      newType = changes['ganttType']; // Map legacy ganttType to type

    // Metadata merging
    final Map<String, dynamic> newMetadata = Map.from(target.metadata);
    changes.forEach((key, value) {
      if (![
        'id',
        'name',
        'parentId',
        'ganttType',
        'isDeleted',
        'data',
      ].contains(key)) {
        newMetadata[key] = value;
      }
    });

    // Implicit resurrection
    return target.copyWith(
      name: newName,
      parentId: newParentId,
      type: newType,
      isDeleted: false,
      metadata: newMetadata,
    );
  }

  void _applyOp(Map<String, ProtocolTask> taskMap, Operation op) {
    if (op.type == 'DELETE_TASK') {
      final taskId = op.data['id'] as String? ?? op.data['taskId'] as String?;
      if (taskId == null) return;

      final existing = taskMap[taskId];

      // Basic tombstone creation
      final base =
          existing ??
          ProtocolTask(
            id: taskId,
            rowId: '',
            start: DateTime.utc(0),
            end: DateTime.utc(0),
            lastUpdated: Hlc.zero,
            isDeleted: true,
          ); // minimally valid tombstone

      taskMap[taskId] = _mergeTask(base, op, {'isDeleted': true});
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
        ProtocolTask(
          id: taskId,
          rowId: '',
          start: DateTime.utc(1970, 1, 1),
          end: DateTime.utc(1970, 1, 2),
          lastUpdated: Hlc.zero,
          isDeleted: true,
        );

    // Inject isDeleted=false into the data to force resurrection check
    final mergeData = Map<String, dynamic>.from(effectiveData);
    mergeData['isDeleted'] = false;

    taskMap[taskId] = _mergeTask(base, op, mergeData);
  }

  ProtocolTask _mergeTask(
    ProtocolTask target,
    Operation op,
    Map<String, dynamic> changes,
  ) {
    final newTimestamps = Map<String, Hlc>.from(target.fieldTimestamps);

    // Helper to check LWW per field
    bool shouldUpdate(String field) {
      final lastHlc = newTimestamps[field] ?? target.lastUpdated;
      return op.timestamp >= lastHlc;
    }

    // Helper to update field
    T update<T>(String field, T candidate, T current) {
      if (shouldUpdate(field)) {
        newTimestamps[field] = op.timestamp;
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
    if (changes.containsKey('rowId'))
      newRowId = update('rowId', changes['rowId'], target.rowId);

    DateTime newStart = target.start;
    final startVal =
        changes['start'] ?? changes['startDate'] ?? changes['start_date'];
    if (startVal != null) {
      final parsed = _parseDate(startVal);
      if (parsed != null) newStart = update('start', parsed, target.start);
    }

    DateTime newEnd = target.end;
    final endVal = changes['end'] ?? changes['endDate'] ?? changes['end_date'];
    if (endVal != null) {
      final parsed = _parseDate(endVal);
      if (parsed != null) newEnd = update('end', parsed, target.end);
    }

    String? newName = target.name;
    if (changes.containsKey('name'))
      newName = update('name', changes['name'], target.name);

    double newCompletion = target.completion;
    if (changes.containsKey('completion')) {
      newCompletion = update(
        'completion',
        (changes['completion'] as num).toDouble(),
        target.completion,
      );
    }

    String? newResourceId = target.resourceId;
    if (changes.containsKey('resourceId')) {
      newResourceId = update(
        'resourceId',
        changes['resourceId'],
        target.resourceId,
      );
    }

    String? newParentId = target.parentId;
    if (changes.containsKey('parentId'))
      newParentId = update('parentId', changes['parentId'], target.parentId);

    String? newNotes = target.notes;
    if (changes.containsKey('notes'))
      newNotes = update('notes', changes['notes'], target.notes);

    bool newIsSummary = target.isSummary;
    if (changes.containsKey('isSummary')) {
      newIsSummary = update(
        'isSummary',
        changes['isSummary'] == true,
        target.isSummary,
      );
    }

    bool newIsMilestone = target.isMilestone;
    if (changes.containsKey('isMilestone')) {
      newIsMilestone = update(
        'isMilestone',
        changes['isMilestone'] == true,
        target.isMilestone,
      );
    }

    // Metadata Merging (Generalized LWW)
    // Any field not explicitly handled above goes into metadata
    Map<String, dynamic> newMetadata = Map.from(target.metadata);

    // Also catch-all for any other keys in 'changes' that aren't managed above
    final managedFields = [
      'id',
      'taskId',
      'rowId',
      'start',
      'startDate',
      'start_date',
      'end',
      'endDate',
      'end_date',
      'name',
      'completion',
      'resourceId',
      'parentId',
      'notes',
      'isSummary',
      'isMilestone',
      'isDeleted',
      'data',
      'timestamp',
      'actorId',
      'fieldTimestamps',
      'lastUpdated',
      'lastUpdatedBy',
    ];

    changes.forEach((key, value) {
      if (!managedFields.contains(key)) {
        // It's a metadata candidate.
        // Check timestamp for this specific metadata key?
        // Yes, we should treat metadata keys as fields for LWW if possible.
        if (shouldUpdate(key)) {
          newMetadata[key] = value;
          newTimestamps[key] = op.timestamp;
        }
      }
    });

    return target.copyWith(
      rowId: newRowId,
      start: newStart,
      end: newEnd,
      name: newName,
      completion: newCompletion,
      resourceId: newResourceId,
      parentId: newParentId,
      notes: newNotes,
      isSummary: newIsSummary,
      isMilestone: newIsMilestone,
      fieldTimestamps: newTimestamps,
      isDeleted: newIsDeleted,
      lastUpdated: op.timestamp > target.lastUpdated
          ? op.timestamp
          : target.lastUpdated,
      lastUpdatedBy: op.timestamp > target.lastUpdated
          ? op.actorId
          : target.lastUpdatedBy,
      metadata: newMetadata,
    );
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

  /// Computes the Merkle Root for a list of tasks and dependencies using the deterministic content hash.
  String computeMerkleRoot(
    List<ProtocolTask> tasks, {
    List<ProtocolDependency> dependencies = const [],
    List<ProtocolResource> resources = const [],
  }) {
    final taskHashes = tasks.map((t) => t.contentHash);
    final depHashes = dependencies.map((d) => d.contentHash);
    final resourceHashes = resources.map((r) => r.contentHash);
    final allHashes = [...taskHashes, ...depHashes, ...resourceHashes];

    return MerkleTree.computeRoot(allHashes.toList());
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
