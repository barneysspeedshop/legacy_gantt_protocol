import 'package:test/test.dart';
import 'package:legacy_gantt_protocol/legacy_gantt_protocol.dart';

void main() {
  group('CausalIntegrityAudit', () {
    late CausalIntegrityAudit audit;

    setUp(() {
      audit = CausalIntegrityAudit();
    });

    test('records and retrieves operations for a task', () {
      final hlc1 = Hlc.parse('2023-01-01T12:00:00.000Z-0000-nodeA');
      final hlc2 = Hlc.parse('2023-01-01T12:01:00.000Z-0000-nodeA');

      final op1 = Operation(
        type: 'UPDATE_TASK',
        data: {'id': 'task1', 'name': 'Task 1'},
        timestamp: hlc1,
        actorId: 'user1',
      );
      final op2 = Operation(
        type: 'UPDATE_TASK',
        data: {'id': 'task1', 'completion': 50},
        timestamp: hlc2,
        actorId: 'user1',
      );
      final opOther = Operation(
        type: 'UPDATE_TASK',
        data: {'id': 'task2', 'name': 'Task 2'},
        timestamp: hlc1,
        actorId: 'user1',
      );

      audit.recordOperation(op2); // Out of order insert
      audit.recordOperation(op1);
      audit.recordOperation(opOther);

      final history = audit.getHistoryForTask('task1');
      expect(history.length, 2);
      expect(history[0], op1); // Sorted by timestamp
      expect(history[1], op2);

      expect(audit.getHistoryForTask('task2').length, 1);
    });

    test('analyzes conflict correctly (time)', () {
      final hlcEarly = Hlc.parse('2023-01-01T12:00:00.000Z-0000-nodeA');
      final hlcLate = Hlc.parse('2023-01-01T12:00:01.000Z-0000-nodeB');

      final opEarly = Operation(
        type: 'UPDATE_TASK',
        data: {'id': 'task1', 'name': 'Early Name'},
        timestamp: hlcEarly,
        actorId: 'userA',
      );
      final opLate = Operation(
        type: 'UPDATE_TASK',
        data: {'id': 'task1', 'name': 'Late Name'},
        timestamp: hlcLate,
        actorId: 'userB',
      );

      final analysis = audit.analyzeConflict(opEarly, opLate, 'name');
      expect(analysis.winner, opLate);
      expect(analysis.loser, opEarly);
      expect(
        analysis.reason,
        contains('Operation B has a later physical time'),
      );
    });

    test('analyzes conflict correctly (tie-breaker)', () {
      // Same time, different nodes. nodeB > nodeA
      final hlcA = Hlc.parse('2023-01-01T12:00:00.000Z-0000-nodeA');
      final hlcB = Hlc.parse('2023-01-01T12:00:00.000Z-0000-nodeB');

      final opA = Operation(
        type: 'UPDATE_TASK',
        data: {'id': 'task1', 'name': 'Name A'},
        timestamp: hlcA,
        actorId: 'userA',
      );
      final opB = Operation(
        type: 'UPDATE_TASK',
        data: {'id': 'task1', 'name': 'Name B'},
        timestamp: hlcB,
        actorId: 'userB',
      );

      final analysis = audit.analyzeConflict(opA, opB, 'name');
      expect(analysis.winner, opB); // nodeB > nodeA
      expect(analysis.loser, opA);
      expect(
        analysis.reason,
        contains('Operation B wins by Node ID tie-breaker'),
      );
    });

    test('handles BATCH_UPDATE indexing', () {
      final hlc = Hlc.fromDate(DateTime.now(), 'nodeA');

      final subOp1 = Operation(
        type: 'UPDATE_TASK',
        data: {'id': 'task1', 'name': 'Task 1 Batch'},
        timestamp: hlc,
        actorId: 'user1',
      );

      final batchOp = Operation(
        type: 'BATCH_UPDATE',
        data: {
          'operations': [subOp1.toJson()],
        },
        timestamp: hlc,
        actorId: 'user1',
      );

      audit.recordOperation(batchOp);

      final history = audit.getHistoryForTask('task1');
      expect(history.length, 1);
      // It should index the BATCH op itself in the history, because that's the causal container?
      // Or the sub-op?
      // My implementation indexes the PARENT op if available, otherwise the op itself.
      // So here it returns batchOp.
      expect(history.first, batchOp);
    });
  });
}
