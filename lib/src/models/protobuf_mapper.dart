import 'dart:convert';
import '../generated/gantt_protocol.pb.dart';
import '../sync/merkle_hash_normalizer.dart';
import 'package:fixnum/fixnum.dart';

class ProtobufMapper {
  static ProtocolMessage toProtobuf(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? '';
    final envelope = ProtocolMessage()
      ..type = type
      ..timestamp = json['timestamp']?.toString() ?? ''
      ..actorId = json['actorId']?.toString() ?? '';

    if (json['channel'] != null) envelope.channel = json['channel'].toString();
    if (json['error'] != null) envelope.error = json['error'].toString();

    final data = json['data'] is Map
        ? json['data'] as Map<String, dynamic>
        : <String, dynamic>{};

    if (type == 'subscribe' || type == 'SUBSCRIBE') {
      envelope.subscribe = SubscribeRequest()
        ..channel = (json['channel'] ?? data['channel'])?.toString() ?? ''
        ..lastSyncedTimestamp =
            (json['lastSyncedTimestamp'] ?? data['lastSyncedTimestamp'])
                ?.toString() ??
            '';
    } else if (type == 'SYNC_METADATA') {
      envelope.syncMetadata = SyncMetadataPayload()
        ..totalOperations = Int64(data['totalOperations'] as int? ?? 0);
    } else if (type == 'BATCH_UPDATE') {
      final batch = BatchUpdatePayload();
      final ops = data['operations'] as List? ?? [];
      for (final op in ops) {
        if (op is! Map<String, dynamic>) continue;
        final opType = op['type'] as String? ?? '';
        final opData = Map<String, dynamic>.from(
          op['data'] as Map<String, dynamic>? ?? {},
        );
        final opTimestamp = op['timestamp']?.toString() ?? '';

        if (opTimestamp.isNotEmpty) {
          opData.putIfAbsent('lastUpdated', () => opTimestamp);
          opData.putIfAbsent(
            'lastUpdatedBy',
            () => op['actorId']?.toString() ?? '',
          );
        }

        if (opType.contains('DELETE')) {
          opData['isDeleted'] = true;
        }
        if (opType.contains('TASK')) {
          batch.tasks.add(taskFromJson(opData));
        } else if (opType.contains('DEPENDENCY')) {
          final dep = dependencyFromJson(opData);
          if (opType.contains('DELETE')) {
            dep.type = 'DELETE';
          }
          batch.dependencies.add(dep);
        } else if (opType.contains('RESOURCE')) {
          batch.resources.add(resourceFromJson(opData));
        }
      }
      envelope.batchUpdate = batch;
    } else if (type == 'MERKLE_ROOT') {
      envelope.merkleRoot = MerkleRootPayload()
        ..root = data['root']?.toString() ?? '';
    } else if (type == 'MERKLE_NODE') {
      final node = MerkleNodePayload()
        ..prefix = data['prefix']?.toString() ?? '';
      final children = data['children'] as Map? ?? {};
      children.forEach((key, value) {
        node.children[key.toString()] = value.toString();
      });
      envelope.merkleNode = node;
    } else if (type == 'GET_MERKLE_NODE') {
      envelope.getMerkleNode = GetMerkleNodeRequest()
        ..prefix = data['prefix']?.toString() ?? '';
    } else if (type == 'GET_ENTITIES_IN_RANGE') {
      envelope.getEntitiesInRange = GetEntitiesInRangeRequest()
        ..prefix = data['prefix']?.toString() ?? '';
    } else if (type == 'GET_MERKLE_ROOT') {
      // no payload needed
    } else if (type == 'AUTH_SUCCESS' ||
        type == 'ERROR' ||
        type == 'SUBSCRIBE_SUCCESS') {
      if (type == 'AUTH_SUCCESS' && json['userId'] != null) {
        envelope.actorId = json['userId'].toString();
      }
    } else {
      // Single operations (INSERT_TASK, etc)
      final singleOp = SingleOperationPayload()..operationType = type;
      if (type.contains('TASK')) {
        singleOp.task = taskFromJson(data);
      } else if (type.contains('DEPENDENCY')) {
        singleOp.dependency = dependencyFromJson(data);
      } else if (type.contains('RESOURCE')) {
        singleOp.resource = resourceFromJson(data);
      } else if (type == 'CURSOR_MOVE' ||
          type == 'GHOST_UPDATE' ||
          type == 'RESET_DATA') {
        singleOp.metadataJson = jsonEncode(data);
      }
      envelope.singleOperation = singleOp;
    }

    return envelope;
  }

  static Map<String, dynamic> toJson(ProtocolMessage proto) {
    final Map<String, dynamic> json = {
      'type': proto.type,
      if (proto.timestamp.isNotEmpty) 'timestamp': proto.timestamp,
      if (proto.actorId.isNotEmpty) 'actorId': proto.actorId,
    };
    if (proto.channel.isNotEmpty) json['channel'] = proto.channel;
    if (proto.error.isNotEmpty) json['error'] = proto.error;

    if (proto.type == 'AUTH_SUCCESS') {
      json['userId'] = proto.actorId;
    }

    switch (proto.whichPayload()) {
      case ProtocolMessage_Payload.subscribe:
        json['type'] = 'subscribe'; // ensure standard
        json['channel'] = proto.subscribe.channel;
        json['lastSyncedTimestamp'] = proto.subscribe.lastSyncedTimestamp;
        break;
      case ProtocolMessage_Payload.batchUpdate:
        final ops = <Map<String, dynamic>>[];
        for (final t in proto.batchUpdate.tasks) {
          ops.add({
            'type': t.isDeleted
                ? 'DELETE_TASK'
                : 'UPDATE_TASK', // Approximate, server handles actual type matching usually
            'data': taskToJson(t),
            'timestamp': t.lastUpdated.isNotEmpty
                ? t.lastUpdated
                : proto.timestamp,
            'actorId': t.lastUpdatedBy.isNotEmpty
                ? t.lastUpdatedBy
                : proto.actorId,
          });
        }
        for (final d in proto.batchUpdate.dependencies) {
          ops.add({
            'type': d.type == 'DELETE'
                ? 'DELETE_DEPENDENCY'
                : 'UPDATE_DEPENDENCY',
            'data': dependencyToJson(d),
            'timestamp': d.lastUpdated.isNotEmpty
                ? d.lastUpdated
                : proto.timestamp,
            'actorId': proto.actorId,
          });
        }
        for (final r in proto.batchUpdate.resources) {
          ops.add({
            'type': r.isDeleted ? 'DELETE_RESOURCE' : 'UPDATE_RESOURCE',
            'data': resourceToJson(r),
            'timestamp': r.lastUpdated.isNotEmpty
                ? r.lastUpdated
                : proto.timestamp,
            'actorId': proto.actorId,
          });
        }
        json['data'] = {'operations': ops};
        break;
      case ProtocolMessage_Payload.syncMetadata:
        json['data'] = {
          'totalOperations': proto.syncMetadata.totalOperations.toInt(),
        };
        break;
      case ProtocolMessage_Payload.merkleRoot:
        json['data'] = {'root': proto.merkleRoot.root};
        break;
      case ProtocolMessage_Payload.merkleNode:
        json['data'] = {
          'prefix': proto.merkleNode.prefix,
          'children': proto.merkleNode.children,
        };
        break;
      case ProtocolMessage_Payload.singleOperation:
        final op = proto.singleOperation;
        json['type'] = op.operationType;
        if (op.operationType.contains('TASK')) {
          json['data'] = taskToJson(op.task);
        } else if (op.operationType.contains('DEPENDENCY')) {
          json['data'] = dependencyToJson(op.dependency);
        } else if (op.operationType.contains('RESOURCE')) {
          json['data'] = resourceToJson(op.resource);
        } else if (op.operationType == 'CURSOR_MOVE' ||
            op.operationType == 'GHOST_UPDATE' ||
            op.operationType == 'RESET_DATA') {
          if (op.metadataJson.isNotEmpty) {
            try {
              json['data'] = jsonDecode(op.metadataJson);
            } catch (_) {
              json['data'] = {};
            }
          } else {
            json['data'] = {};
          }
        }
        break;
      case ProtocolMessage_Payload.getMerkleNode:
        json['data'] = {'prefix': proto.getMerkleNode.prefix};
        break;
      case ProtocolMessage_Payload.getEntitiesInRange:
        json['data'] = {'prefix': proto.getEntitiesInRange.prefix};
        break;
      default:
        break;
    }
    return json;
  }

  static ProtocolTask taskFromJson(Map<String, dynamic> data) {
    if (data['data'] is Map<String, dynamic>) {
      data = {...data, ...data['data'] as Map<String, dynamic>}..remove('data');
    }
    final task = ProtocolTask()
      ..id = data['id']?.toString() ?? data['taskId']?.toString() ?? ''
      ..rowId = (data['rowId'] ?? data['row_id'])?.toString() ?? ''
      ..start = MerkleHashNormalizer.formatProtocolDate(
        data['start'] ?? data['startDate'] ?? data['start_date'],
      )
      ..end = MerkleHashNormalizer.formatProtocolDate(
        data['end'] ?? data['endDate'] ?? data['end_date'],
        fallback: DateTime.utc(1970, 1, 2).toIso8601String(),
      )
      ..name = data['name']?.toString() ?? ''
      ..completion = (data['completion'] as num?)?.toDouble() ?? 0.0
      ..isSummary =
          data['isSummary'] == true ||
          data['ganttType'] == 'summary' ||
          data['gantt_type'] == 'summary'
      ..isMilestone =
          data['isMilestone'] == true ||
          data['ganttType'] == 'milestone' ||
          data['gantt_type'] == 'milestone'
      ..resourceId = data['resourceId']?.toString() ?? ''
      ..parentId = (data['parentId'] ?? data['parent_id'])?.toString() ?? ''
      ..notes = data['notes']?.toString() ?? ''
      ..isDeleted = data['isDeleted'] == true || data['is_deleted'] == true
      ..lastUpdated = data['lastUpdated']?.toString() ?? ''
      ..lastUpdatedBy = data['lastUpdatedBy']?.toString() ?? ''
      ..metadataJson = jsonEncode(metadataFromJson(data));

    if (data['fieldTimestamps'] is Map) {
      final ft = data['fieldTimestamps'] as Map;
      for (final key in ft.keys) {
        task.fieldTimestamps[key.toString()] = ft[key].toString();
      }
    }
    return task;
  }

  static ProtocolDependency dependencyFromJson(Map<String, dynamic> data) {
    return ProtocolDependency()
      ..predecessorTaskId = data['predecessorTaskId']?.toString() ?? ''
      ..successorTaskId = data['successorTaskId']?.toString() ?? ''
      ..type = data['type']?.toString() ?? ''
      ..lag = Int64(data['lag'] as int? ?? 0)
      ..lastUpdated = data['lastUpdated']?.toString() ?? '';
  }

  static ProtocolResource resourceFromJson(Map<String, dynamic> data) {
    if (data['data'] is Map<String, dynamic>) {
      data = {...data, ...data['data'] as Map<String, dynamic>}..remove('data');
    }
    return ProtocolResource()
      ..id = data['id']?.toString() ?? ''
      ..name = data['name']?.toString() ?? ''
      ..parentId = data['parentId']?.toString() ?? ''
      ..isDeleted = data['isDeleted'] == true || data['is_deleted'] == true
      ..type =
          (data['type'] ?? data['ganttType'] ?? data['gantt_type'])
              ?.toString() ??
          'person'
      ..metadataJson = jsonEncode(metadataFromJson(data))
      ..lastUpdated = data['lastUpdated']?.toString() ?? '';
  }

  static Map<String, dynamic> taskToJson(ProtocolTask task) {
    return {
      'id': task.id,
      'rowId': task.rowId,
      'start': task.start,
      'start_date': task.start,
      'end': task.end,
      'end_date': task.end,
      'name': task.name,
      'completion': task.completion,
      'isSummary': task.isSummary,
      'isMilestone': task.isMilestone,
      'resourceId': task.resourceId,
      'parentId': task.parentId,
      'notes': task.notes,
      'isDeleted': task.isDeleted,
      'lastUpdated': task.lastUpdated,
      'lastUpdatedBy': task.lastUpdatedBy,
      ...metadataFromJson({'metadataJson': task.metadataJson}),
      'fieldTimestamps': Map<String, String>.from(task.fieldTimestamps),
      // Provide both for compatibility
      'gantt_type': task.isMilestone
          ? 'milestone'
          : (task.isSummary ? 'summary' : 'task'),
      'taskId': task.id,
    };
  }

  static Map<String, dynamic> dependencyToJson(ProtocolDependency dep) {
    return {
      'predecessorTaskId': dep.predecessorTaskId,
      'successorTaskId': dep.successorTaskId,
      'type': dep.type,
      'lag': dep.lag.toInt(),
      'lastUpdated': dep.lastUpdated,
    };
  }

  static Map<String, dynamic> resourceToJson(ProtocolResource res) {
    return {
      'id': res.id,
      'name': res.name,
      'parentId': res.parentId,
      'type': res.type,
      'isDeleted': res.isDeleted,
      ...metadataFromJson({'metadataJson': res.metadataJson}),
      'lastUpdated': res.lastUpdated,
    };
  }

  static Map<String, dynamic> metadataFromJson(Map<String, dynamic> data) {
    final encoded = data['metadataJson'];
    final nested = encoded is String && encoded.isNotEmpty
        ? jsonDecode(encoded) as Map<String, dynamic>
        : data['metadata'] as Map<String, dynamic>? ?? {};
    return {
      ...nested,
      for (final entry in data.entries)
        if (!const {
          'id',
          'taskId',
          'rowId',
          'row_id',
          'start',
          'startDate',
          'start_date',
          'end',
          'endDate',
          'end_date',
          'name',
          'completion',
          'isSummary',
          'isMilestone',
          'resourceId',
          'resource_id',
          'parentId',
          'parent_id',
          'notes',
          'isDeleted',
          'is_deleted',
          'lastUpdated',
          'lastUpdatedBy',
          'last_updated_by',
          'fieldTimestamps',
          'metadata',
          'metadataJson',
          'type',
          'ganttType',
          'gantt_type',
          'data',
          'timestamp',
          'actorId',
        }.contains(entry.key))
          entry.key: entry.value,
    };
  }
}
