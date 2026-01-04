import 'package:legacy_gantt_protocol/legacy_gantt_protocol.dart';
import 'package:test/test.dart';

void main() {
  group('Hybrid Sovereignty Sync', () {
    late CRDTEngine engine;

    setUp(() {
      engine = CRDTEngine();
    });

    test('Field-Level Independence: Name and Notes update concurrently', () {
      // Hlc timestamp generation
      // t0 (1000)
      // A (2000)
      // B (2000, 2001 logic) ?
      // Manually crafted for clarity.
      const hlcA = Hlc(millis: 2000, counter: 0, nodeId: 'A');
      const hlcB = Hlc(millis: 2000, counter: 0, nodeId: 'B');

      final baseTask = ProtocolTask(
        id: '1',
        rowId: 'r1',
        start: DateTime(2023, 1, 1),
        end: DateTime(2023, 1, 2),
        name: 'Original Name',
        notes: 'Original Notes',
        lastUpdated: Hlc.zero,
      );

      // Op A: Updates Name
      final opA = Operation(
        type: 'UPDATE_TASK',
        data: {'id': '1', 'name': 'Name by A'},
        timestamp: hlcA,
        actorId: 'A',
      );

      // Op B: Updates Notes
      final opB = Operation(
        type: 'UPDATE_TASK',
        data: {'id': '1', 'notes': 'Notes by B'},
        timestamp: hlcB,
        actorId: 'B',
      );

      // Apply A then B
      var result = engine.mergeTasks([baseTask], [opA]);
      var task = result.first;
      expect(task.name, 'Name by A');
      expect(task.notes, 'Original Notes');

      // Apply B (on top of A)
      result = engine.mergeTasks(result, [opB]);
      task = result.first;

      // Both should persist
      expect(task.name, 'Name by A');
      expect(task.notes, 'Notes by B');
    });

    test('Field-Level LWW: Later timestamp wins per field', () {
      const hlc1 = Hlc(millis: 1000, counter: 0, nodeId: 'A');
      const hlc2 = Hlc(millis: 2000, counter: 0, nodeId: 'B');

      final baseTask = ProtocolTask(
        id: '1',
        rowId: 'r1',
        start: DateTime.now(),
        end: DateTime.now(),
        name: 'Old',
        lastUpdated: Hlc.zero,
      );

      // Op 1 (Newer): Set Name to New
      final op1 = Operation(
        type: 'UPDATE',
        data: {'id': '1', 'name': 'New'},
        timestamp: hlc2,
        actorId: 'B',
      );

      // Op 2 (Older): Set Name to Old2 (arrives late)
      final op2 = Operation(
        type: 'UPDATE',
        data: {'id': '1', 'name': 'Old2'},
        timestamp: hlc1,
        actorId: 'A',
      );

      var result = engine.mergeTasks([baseTask], [op1, op2]);
      expect(result.first.name, 'New'); // Newer wins
    });

    test('Add-Wins OR-Set: Update resurrects Deleted task', () {
      const hlcDelete = Hlc(millis: 1000, counter: 0, nodeId: 'A');
      const hlcUpdate = Hlc(millis: 2000, counter: 0, nodeId: 'B');

      final baseTask = ProtocolTask(
        id: '1',
        rowId: 'r1',
        start: DateTime.now(),
        end: DateTime.now(),
        name: 'Alive',
        lastUpdated: Hlc.zero,
      );

      // Op 1: Delete
      final opDelete = Operation(
        type: 'DELETE_TASK',
        data: {'id': '1'},
        timestamp: hlcDelete,
        actorId: 'A',
      );

      // Op 2: Update (Resurrect)
      final opUpdate = Operation(
        type: 'UPDATE_TASK',
        data: {'id': '1', 'name': 'Resurrected'},
        timestamp: hlcUpdate,
        actorId: 'B',
      );

      // Apply Delete
      var result = engine.mergeTasks([baseTask], [opDelete]);
      expect(
        result,
        isEmpty,
      ); // Hidden from UI (logic might return tombstone or filter it? Engine usually returns all, including deleted if not filtered)
      // Wait, mergeTasks filters deleted?
      // CRDTEngine description: "Returns the filtered list of visible tasks." (Usually)
      // Let's assume it DOES filter. If so, result is empty.

      // Apply Update (Resurrect) - Need to pass tombstone.
      // Recreate tombstone
      final tombstone = baseTask.copyWith(
        isDeleted: true,
        fieldTimestamps: {'isDeleted': hlcDelete},
      );
      result = engine.mergeTasks([tombstone], [opUpdate]);

      expect(result, hasLength(1));
      expect(result.first.name, 'Resurrected');
      expect(result.first.isDeleted, false);
    });
  });
}
