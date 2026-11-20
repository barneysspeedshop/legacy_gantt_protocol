import 'package:legacy_gantt_protocol/legacy_gantt_protocol.dart';
import 'package:test/test.dart';

Hlc clock(int value) => Hlc(millis: value, counter: 0, nodeId: 'fixture');
Operation edit(int value, Map<String, dynamic> data) => Operation(
  type: 'UPDATE_TASK',
  timestamp: clock(value),
  actorId: 'fixture',
  data: {'id': 'task', ...data},
);

void main() {
  test(
    'full snapshots preserve independent field edits in either delivery order',
    () {
      final engine = CRDTEngine();
      final base = edit(100, {'name': 'Original', 'notes': 'Original notes'});
      final name = edit(300, {
        'name': 'New name',
        'notes': 'Original notes',
        'fieldTimestamps': {
          'name': clock(300).toString(),
          'notes': clock(100).toString(),
        },
      });
      final notes = edit(200, {
        'name': 'Original',
        'notes': 'New notes',
        'fieldTimestamps': {
          'name': clock(100).toString(),
          'notes': clock(200).toString(),
        },
      });
      for (final operations in [
        [base, name, notes],
        [base, notes, name],
      ]) {
        final task = engine.mergeTasks([], operations).single;
        expect(task.name, 'New name');
        expect(task.notes, 'New notes');
        expect(task.fieldTimestamps['name'], clock(300).toString());
        expect(task.fieldTimestamps['notes'], clock(200).toString());
        expect(task.parsedLastUpdated, clock(300));
      }
    },
  );

  test(
    'replayed snapshots retain field clocks for subsequent intermediate edits',
    () {
      final engine = CRDTEngine();
      final task = engine.mergeTasks([], [
        edit(300, {
          'name': 'New name',
          'notes': 'Older notes',
          'fieldTimestamps': {
            'name': clock(300).toString(),
            'notes': clock(100).toString(),
          },
        }),
      ]).single;
      final replay = edit(300, ProtobufMapper.taskToJson(task));
      final restored = engine.mergeTasks([], [
        replay,
        edit(200, {'notes': 'Offline notes'}),
      ]).single;
      expect(restored.name, 'New name');
      expect(restored.notes, 'Offline notes');
      expect(restored.fieldTimestamps['notes'], clock(200).toString());
    },
  );
  test(
    'delayed deletion and newer update converge in either delivery order',
    () {
      final engine = CRDTEngine();
      final update = edit(300, {'name': 'Retained'});
      final deletion = Operation(
        type: 'DELETE_TASK',
        data: {'id': 'task'},
        timestamp: clock(200),
        actorId: 'fixture',
      );
      for (final operations in [
        [update, deletion],
        [deletion, update],
      ]) {
        final task = engine.mergeTasks([], operations).single;
        expect(task.name, 'Retained');
        expect(task.isDeleted, false);
        expect(task.parsedLastUpdated, clock(300));
      }
    },
  );
  test(
    'historical task fields commute with deletion and survive cold replay',
    () {
      final engine = CRDTEngine();
      final base = edit(100, {'name': 'Original'});
      final historical = edit(150, {'notes': 'Offline notes'});
      final deletion = Operation(
        type: 'DELETE_TASK',
        data: {'id': 'task'},
        timestamp: clock(200),
        actorId: 'fixture',
      );
      final before = engine.mergeTasks([], [base, historical, deletion]).single;
      final after = engine.mergeTasks([], [base, deletion, historical]).single;
      expect(after.notes, 'Offline notes');
      expect(after.isDeleted, true);
      expect(after.contentHash, before.contentHash);
      final replay = engine.mergeTasks([], [
        edit(200, ProtobufMapper.taskToJson(after)),
      ]).single;
      expect(replay.contentHash, before.contentHash);
      expect(replay.fieldTimestamps['isDeleted'], clock(200).toString());
    },
  );
  test(
    'resource writes replace whole records and deletion has a minimal payload',
    () {
      final engine = CRDTEngine();
      Operation resource(
        int time,
        Map<String, dynamic> data, {
        bool deleted = false,
      }) => Operation(
        type: deleted ? 'DELETE_RESOURCE' : 'UPDATE_RESOURCE',
        data: {'id': 'resource', ...data},
        timestamp: clock(time),
        actorId: 'fixture',
      );
      final original = resource(100, {
        'name': 'Old',
        'parentId': 'parent',
        'type': 'tool',
        'metadataJson': '{"custom":1}',
      });
      final replacement = resource(300, {'name': 'New'});
      final deletion = resource(200, {}, deleted: true);
      final before = engine.mergeResources([], [
        original,
        deletion,
        replacement,
      ]).single;
      final after = engine.mergeResources([], [
        original,
        replacement,
        deletion,
      ]).single;
      expect(after.name, 'New');
      expect(after.parentId, '');
      expect(after.type, 'person');
      expect(after.metadataJson, '{}');
      expect(after.contentHash, before.contentHash);
      final tombstone = engine.mergeResources([], [original, deletion]).single;
      expect(tombstone.name, '');
      expect(tombstone.parentId, '');
      expect(tombstone.type, 'person');
      expect(tombstone.metadataJson, '{}');
      expect(tombstone.isDeleted, true);
    },
  );
  test(
    'unknown sparse task history commutes with virtual reset tombstones',
    () {
      final engine = CRDTEngine();
      final historical = edit(100, {'notes': 'Offline notes'});
      final deletion = Operation(
        type: 'DELETE_TASK',
        data: {'id': 'task'},
        timestamp: clock(200),
        actorId: 'reset',
      );
      final before = engine.mergeTasks([], [historical, deletion]).single;
      final after = engine.mergeTasks([], [deletion, historical]).single;
      expect(after.notes, 'Offline notes');
      expect(after.isDeleted, true);
      expect(after.contentHash, before.contentHash);
    },
  );
  test(
    'all task field, deletion and restoration arrival permutations converge',
    () {
      final engine = CRDTEngine();
      final operations = [
        edit(100, {
          'name': 'Original',
          'start': '2026-01-01T00:00:00.000Z',
          'end': '2026-01-02T00:00:00.000Z',
        }),
        edit(150, {'notes': 'Offline notes'}),
        Operation(
          type: 'DELETE_TASK',
          data: {'id': 'task'},
          timestamp: clock(200),
          actorId: 'fixture',
        ),
        edit(300, {'name': 'Restored'}),
      ];
      String? hash;
      for (final order in permutations(operations)) {
        final task = engine.mergeTasks([], order).single;
        expect(task.name, 'Restored');
        expect(task.notes, 'Offline notes');
        expect(task.start, '2026-01-01T00:00:00.000Z');
        expect(task.isDeleted, false);
        hash ??= task.contentHash;
        expect(
          task.contentHash,
          hash,
          reason: order
              .map((op) => '${op.type}@${op.timestamp.millis}')
              .join(','),
        );
      }
    },
  );
  test('all complete resource and deletion arrival permutations converge', () {
    final engine = CRDTEngine();
    Operation resource(
      int time,
      Map<String, dynamic> data, {
      bool deleted = false,
    }) => Operation(
      type: deleted ? 'DELETE_RESOURCE' : 'UPDATE_RESOURCE',
      data: {'id': 'resource', ...data},
      timestamp: clock(time),
      actorId: 'fixture',
    );
    final operations = [
      resource(100, {
        'name': 'Original',
        'parentId': 'parent',
        'metadataJson': '{"custom":1}',
      }),
      resource(200, {}, deleted: true),
      resource(300, {'name': 'Restored'}),
    ];
    String? hash;
    for (final order in permutations(operations)) {
      final value = engine.mergeResources([], order).single;
      expect(value.name, 'Restored');
      expect(value.parentId, '');
      expect(value.metadataJson, '{}');
      expect(value.isDeleted, false);
      hash ??= value.contentHash;
      expect(value.contentHash, hash);
    }
  });
  test(
    'zero clock legacy inserts are live while explicit zero tombstones win ties',
    () {
      final engine = CRDTEngine();
      final insert = Operation(
        type: 'UPDATE_TASK',
        data: {'id': 'task', 'name': 'Legacy'},
        timestamp: Hlc.zero,
        actorId: 'fixture',
      );
      final live = engine.mergeTasks([], [insert]).single;
      expect(live.name, 'Legacy');
      expect(live.isDeleted, false);
      final deletion = Operation(
        type: 'DELETE_TASK',
        data: {'id': 'task'},
        timestamp: Hlc.zero,
        actorId: 'fixture',
      );
      final hidden = engine.mergeTasks([], [deletion, insert]).single;
      expect(hidden.name, 'Legacy');
      expect(hidden.isDeleted, true);
    },
  );
  test(
    'bare protobuf deletion preserves content while clocked snapshots recover history',
    () {
      final engine = CRDTEngine();
      final original = engine.mergeTasks([], [
        edit(100, {'name': 'Retained', 'notes': 'History'}),
      ]).single;
      final wire = ProtobufMapper.toJson(
        ProtobufMapper.toProtobuf(
          Operation(
            type: 'DELETE_TASK',
            data: {'id': 'task'},
            timestamp: clock(200),
            actorId: 'fixture',
          ).toJson(),
        ),
      );
      final bare = Operation.fromJson(wire);
      final deleted = engine.mergeTasks([original], [bare]).single;
      expect(deleted.name, 'Retained');
      expect(deleted.notes, 'History');
      expect(deleted.isDeleted, true);
      final snapshot = Operation(
        type: 'DELETE_TASK',
        data: ProtobufMapper.taskToJson(deleted),
        timestamp: clock(200),
        actorId: 'fixture',
      );
      final recovered = engine.mergeTasks([], [snapshot]).single;
      expect(recovered.contentHash, deleted.contentHash);
    },
  );
}

Iterable<List<T>> permutations<T>(List<T> values) sync* {
  if (values.isEmpty) {
    yield <T>[];
    return;
  }
  for (var index = 0; index < values.length; index++) {
    final rest = [...values]..removeAt(index);
    for (final tail in permutations(rest)) {
      yield [values[index], ...tail];
    }
  }
}
