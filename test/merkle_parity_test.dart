import 'dart:convert';

import 'package:legacy_gantt_protocol/legacy_gantt_protocol.dart';
import 'package:test/test.dart';

/// Mirrors [MerkleService._hashTask] after fixes — must match client [LegacyGanttTask.toProtocolTask].
ProtocolTask serverTaskHashProto(Map<String, dynamic> row) {
  final pt = ProtocolTask()
    ..id = row['id']?.toString() ?? ''
    ..rowId = row['row_id']?.toString() ?? ''
    ..start = MerkleHashNormalizer.formatProtocolDate(
      row['start_date'],
      fallback: DateTime.utc(1970, 1, 1).toIso8601String(),
    )
    ..end = MerkleHashNormalizer.formatProtocolDate(
      row['end_date'],
      fallback: DateTime.utc(1970, 1, 2).toIso8601String(),
    )
    ..completion = (row['completion'] as num?)?.toDouble() ?? 0.0
    ..isSummary =
        row['gantt_type'] == 'project' || row['gantt_type'] == 'summary'
    ..isMilestone = row['gantt_type'] == 'milestone'
    ..isDeleted = row['is_deleted'] == true || row['is_deleted'] == 1;

  if (row['name'] != null) pt.name = row['name'];
  if (row['resource_id'] != null) pt.resourceId = row['resource_id'].toString();
  if (row['parent_id'] != null) pt.parentId = row['parent_id'].toString();
  if (row['notes'] != null) pt.notes = row['notes'];

  final metadata = MerkleHashNormalizer.normalizeTaskMetadata({
    'color': row['color'],
    'textColor': row['text_color'],
    'stackIndex': row['stack_index'] ?? 0,
    'originalId': row['original_id']?.toString(),
    'isTimeRangeHighlight': row['is_time_range_highlight'] == true,
    'isOverlapIndicator': row['is_overlap_indicator'] == true,
    'usesWorkCalendar': row['uses_work_calendar'] == true,
    'load': (row['load'] as num?)?.toDouble() ?? 1.0,
    'isAutoScheduled': row['is_auto_scheduled'] != null
        ? row['is_auto_scheduled'] == true || row['is_auto_scheduled'] == 1
        : true,
    'propagatesMoveToChildren': row['propagates_move_to_children'] != false,
    'resizePolicy': row['resize_policy'],
    'baselineStart': MerkleHashNormalizer.formatProtocolDateOrNull(
      row['baseline_start'],
    ),
    'baselineEnd': MerkleHashNormalizer.formatProtocolDateOrNull(
      row['baseline_end'],
    ),
  });
  pt.metadataJson = jsonEncode(metadata);
  return pt;
}

ProtocolDependency serverDependencyHashProto(Map<String, dynamic> row) {
  final pd = ProtocolDependency()
    ..predecessorTaskId = row['predecessor_task_id']?.toString() ?? ''
    ..successorTaskId = row['successor_task_id']?.toString() ?? ''
    ..type = row['dependency_type']?.toString() ?? 'finishToStart';
  return pd;
}

ProtocolTask clientStyleTaskProto({
  required String id,
  required String rowId,
  required DateTime start,
  required DateTime end,
  int resizePolicyIndex = 0,
  List<Map<String, dynamic>>? segments,
}) {
  final meta = {
    'color': 'ffff0000',
    'textColor': null,
    'stackIndex': 0,
    'originalId': null,
    'isTimeRangeHighlight': false,
    'isOverlapIndicator': false,
    'segments': segments,
    'usesWorkCalendar': false,
    'load': 1.0,
    'isAutoScheduled': true,
    'propagatesMoveToChildren': true,
    'resizePolicy': ['none', 'constrain', 'elastic'][resizePolicyIndex],
    'baselineStart': null,
    'baselineEnd': null,
    'hasCellBuilder': true,
    'startIsUtc': start.isUtc,
    'endIsUtc': end.isUtc,
    'baselineStartIsUtc': null,
    'baselineEndIsUtc': null,
  };
  return ProtocolTask()
    ..id = id
    ..rowId = rowId
    ..start = start.toUtc().toIso8601String()
    ..end = end.toUtc().toIso8601String()
    ..completion = 0.5
    ..isSummary = false
    ..isMilestone = false
    ..isDeleted = false
    ..lastUpdated = Hlc.fromDate(
      DateTime.utc(2026, 6, 12, 6, 33),
      'client',
    ).toString()
    ..metadataJson = jsonEncode(meta);
}

void main() {
  group('Merkle parity', () {
    test('task hash matches between server row and client protocol task', () {
      final startMs = DateTime.utc(
        2026,
        5,
        23,
        5,
        49,
        12,
      ).millisecondsSinceEpoch;
      final endMs = DateTime.utc(2026, 5, 24).millisecondsSinceEpoch;

      final serverRow = {
        'id': 'task-1',
        'row_id': 'row-1',
        'start_date': startMs.toString(),
        'end_date': endMs.toString(),
        'completion': 0.5,
        'gantt_type': 'task',
        'is_deleted': 0,
        'color': 'ffff0000',
        'resize_policy': '0',
        'propagates_move_to_children': 1,
        'uses_work_calendar': 0,
        'last_updated': Hlc.fromDate(
          DateTime.utc(2026, 6, 12, 6, 33),
          'client',
        ).toString(),
      };

      final serverProto = serverTaskHashProto(serverRow);
      final clientProto = clientStyleTaskProto(
        id: 'task-1',
        rowId: 'row-1',
        start: DateTime.fromMillisecondsSinceEpoch(startMs),
        end: DateTime.fromMillisecondsSinceEpoch(endMs),
        resizePolicyIndex: 0,
        segments: [
          {
            'start': '2026-01-01T00:00:00.000Z',
            'end': '2026-01-02T00:00:00.000Z',
          },
        ],
      );

      expect(serverProto.contentHash, clientProto.contentHash);
    });

    test('dependency hash uses dependency_type column', () {
      final row = {
        'predecessor_task_id': 'a',
        'successor_task_id': 'b',
        'dependency_type': 'startToStart',
        'last_updated': Hlc.fromDate(
          DateTime.utc(2026, 5, 19, 19, 4),
          'x',
        ).toString(),
      };

      final serverProto = serverDependencyHashProto(row);
      final clientProto = ProtocolDependency()
        ..predecessorTaskId = 'a'
        ..successorTaskId = 'b'
        ..type = 'startToStart'
        ..lastUpdated = row['last_updated'] as String;

      expect(serverProto.contentHash, clientProto.contentHash);
    });

    test('merkleHlcKey normalizes legacy epoch millis strings', () {
      final ms = DateTime.utc(2026, 6, 12, 7, 20).millisecondsSinceEpoch;
      final fromMillis = MerkleHashNormalizer.merkleHlcKey(ms.toString());
      final fromHlc = MerkleHashNormalizer.merkleHlcKey(
        Hlc.fromDate(DateTime.utc(2026, 6, 12, 7, 20), 'node').toString(),
      );
      expect(
        MerkleHashNormalizer.merkleMinutePrefix(fromMillis),
        MerkleHashNormalizer.merkleMinutePrefix(fromHlc),
      );
    });

    test('computeMerkleTree uses raw HLC keys without re-parsing', () {
      final hlc = '2026-06-12T06:33:00.000Z-0001-node';
      final task = ProtocolTask()
        ..id = 't1'
        ..rowId = 'r1'
        ..start = DateTime.utc(2026, 1, 1).toIso8601String()
        ..end = DateTime.utc(2026, 1, 2).toIso8601String()
        ..lastUpdated = hlc;

      final engine = CRDTEngine();
      final tree = engine.computeMerkleTree([task]);
      final node = tree.getNode('2026-06-12T06:33');
      expect(node, isNotNull);
      expect(node!.count, 1);
    });

    test('millisecond epoch strings hash the same as UTC ISO dates', () {
      final startMs = DateTime.utc(
        2026,
        5,
        23,
        5,
        49,
        12,
      ).millisecondsSinceEpoch;
      final endMs = DateTime.utc(2026, 5, 24).millisecondsSinceEpoch;
      final baseRow = {
        'id': 'task-ms',
        'row_id': 'row-ms',
        'completion': 0.0,
        'gantt_type': 'task',
        'is_deleted': 0,
        'propagates_move_to_children': 1,
        'uses_work_calendar': 0,
      };

      final fromMillis = serverTaskHashProto({
        ...baseRow,
        'start_date': startMs.toString(),
        'end_date': endMs.toString(),
      });
      final fromIso = serverTaskHashProto({
        ...baseRow,
        'start_date': DateTime.fromMillisecondsSinceEpoch(
          startMs,
          isUtc: true,
        ).toIso8601String(),
        'end_date': DateTime.fromMillisecondsSinceEpoch(
          endMs,
          isUtc: true,
        ).toIso8601String(),
      });

      expect(fromMillis.contentHash, fromIso.contentHash);
    });

    test('deleted task tombstones are included in merkle tree', () {
      final hlc = '2026-06-12T07:13:00.000Z-0001-node';
      final live = ProtocolTask()
        ..id = 'live'
        ..rowId = 'r1'
        ..start = DateTime.utc(2026, 1, 1).toIso8601String()
        ..end = DateTime.utc(2026, 1, 2).toIso8601String()
        ..lastUpdated = hlc
        ..metadataJson = jsonEncode(
          MerkleHashNormalizer.normalizeTaskMetadata({}),
        );
      final tombstone = ProtocolTask()
        ..id = 'dead'
        ..rowId = 'r1'
        ..start = DateTime.utc(2026, 1, 1).toIso8601String()
        ..end = DateTime.utc(2026, 1, 2).toIso8601String()
        ..isDeleted = true
        ..lastUpdated = hlc
        ..metadataJson = jsonEncode(
          MerkleHashNormalizer.normalizeTaskMetadata({}),
        );

      final withTombstone = CRDTEngine().computeMerkleTree([live, tombstone]);
      final withoutTombstone = CRDTEngine().computeMerkleTree([live]);

      expect(withTombstone.root.hash, isNot(withoutTombstone.root.hash));
    });

    test('resource metadata includes ganttType for hash parity', () {
      final serverProto = ProtocolResource()
        ..id = 'res-1'
        ..name = 'Crew A'
        ..type = 'job'
        ..metadataJson = jsonEncode(
          MerkleHashNormalizer.normalizeResourceMetadata({
            'isExpanded': true,
          }, type: 'job'),
        );

      final clientProto = ProtocolResource()
        ..id = 'res-1'
        ..name = 'Crew A'
        ..type = 'job'
        ..metadataJson = jsonEncode({'isExpanded': true});

      expect(serverProto.contentHash, clientProto.contentHash);
    });
  });
}
