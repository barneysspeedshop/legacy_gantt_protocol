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
}
