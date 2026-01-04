import 'package:legacy_gantt_protocol/legacy_gantt_protocol.dart';
import 'package:test/test.dart';

// Mock Sync Client not needed here as CRDTEngine is tested directly.

void main() {
  group('CRDTEngine', () {
    late CRDTEngine engine;

    setUp(() {
      engine = CRDTEngine();
    });

    test('should merge new task update', () {
      final task = ProtocolTask(id: '1', rowId: 'row1', start: DateTime(2023, 1, 1), end: DateTime(2023, 1, 5), name: 'Task 1', lastUpdated: Hlc.zero);

      final op = Operation(
        type: 'UPDATE_TASK',
        data: {
          'id': '1',
          'rowId': 'row1',
          'start': DateTime(2023, 1, 2).toIso8601String(),
          'end': DateTime(2023, 1, 6).toIso8601String(),
          'name': 'Task 1 Updated',
        },
        timestamp: Hlc.fromIntTimestamp(100),
        actorId: 'user1',
      );

      final result = engine.mergeTasks([task], [op]);

      expect(result.length, 1);
      expect(result.first.start, DateTime(2023, 1, 2));
      expect(result.first.end, DateTime(2023, 1, 6));
      expect(result.first.name, 'Task 1 Updated');
      expect(result.first.lastUpdated, Hlc.fromIntTimestamp(100));
      expect(result.first.lastUpdatedBy, 'user1');
    });

    test('should ignore older update', () {
      final task = ProtocolTask(
        id: '1',
        rowId: 'row1',
        start: DateTime(2023, 1, 2),
        end: DateTime(2023, 1, 6),
        name: 'Task 1 Updated',
        lastUpdated: Hlc.fromIntTimestamp(200),
        lastUpdatedBy: 'user1',
      );

      final op = Operation(
        type: 'UPDATE_TASK',
        data: {
          'id': '1',
          'rowId': 'row1',
          'start': DateTime(2023, 1, 1).toIso8601String(),
          'end': DateTime(2023, 1, 5).toIso8601String(),
          'name': 'Task 1 Old',
        },
        timestamp: Hlc.fromIntTimestamp(100),
        actorId: 'user2',
      );

      final result = engine.mergeTasks([task], [op]);

      expect(result.length, 1);
      // Values should remain unchanged
      expect(result.first.start, DateTime(2023, 1, 2));
      expect(result.first.name, 'Task 1 Updated');
    });

    test('should handle new task creation via update', () {
      final op = Operation(
        type: 'UPDATE_TASK',
        data: {'id': '2', 'rowId': 'row1', 'start': DateTime(2023, 1, 1).toIso8601String(), 'end': DateTime(2023, 1, 5).toIso8601String(), 'name': 'Task 2'},
        timestamp: Hlc.fromIntTimestamp(100),
        actorId: 'user1',
      );

      final result = engine.mergeTasks([], [op]);

      expect(result.length, 1);
      expect(result.first.id, '2');
      expect(result.first.name, 'Task 2');
    });
  });
}
