import 'package:legacy_gantt_protocol/legacy_gantt_protocol.dart';
import 'package:uuid/uuid.dart';

void main() {
  print('=== Legacy Gantt Protocol Example ===\n');

  // 1. Setup - Create two independent "replicas" (Client A and Client B)
  final engine = CRDTEngine();

  // State is external to the engine
  List<ProtocolTask> tasksA = [];
  List<ProtocolTask> tasksB = [];

  // 2. Client A creates a task
  final taskId = const Uuid().v4();
  final createOp = Operation(
    type: 'INSERT_TASK',
    data: {
      'id': taskId,
      'name': 'Project Plan',
      'start': DateTime.now().toIso8601String(),
      'end': DateTime.now().add(const Duration(days: 5)).toIso8601String(),
    },
    timestamp: Hlc.fromDate(DateTime.now(), 'client_a'),
    actorId: 'client_a',
  );

  print('Client A: Created Task "${createOp.data['name']}"');
  tasksA = engine.mergeTasks(tasksA, [createOp]);

  // 3. Client B also creates/merges the same task (simulation of receiving sync)
  print('Client B: Received Task creation');
  tasksB = engine.mergeTasks(tasksB, [createOp]);

  // 4. Concurrent Editing!
  print('\n-- Concurrent Edits --');
  final renameOpA = Operation(
    type: 'UPDATE_TASK',
    data: {'id': taskId, 'name': 'Project Plan (Updated by A)'},
    timestamp: Hlc.fromDate(DateTime.now().add(const Duration(seconds: 1)), 'client_a'),
    actorId: 'client_a',
  );
  print('Client A: Renames to "${renameOpA.data['name']}"');
  tasksA = engine.mergeTasks(tasksA, [renameOpA]);

  // Client B completes the task (at a slightly later time)
  final completeOpB = Operation(
    type: 'UPDATE_TASK',
    data: {'id': taskId, 'completion': 1.0},
    timestamp: Hlc.fromDate(DateTime.now().add(const Duration(seconds: 2)), 'client_b'),
    actorId: 'client_b',
  );
  print('Client B: Marks completion as 100%');
  tasksB = engine.mergeTasks(tasksB, [completeOpB]);

  // 5. Sync Loop - Exchange operations
  print('\n-- Syncing --');
  print('Client A receives B\'s completion...');
  tasksA = engine.mergeTasks(tasksA, [completeOpB]);

  print('Client B receives A\'s rename...');
  tasksB = engine.mergeTasks(tasksB, [renameOpA]);

  // 6. Verify Convergence
  final taskA = tasksA.firstWhere((t) => t.id == taskId);
  final taskB = tasksB.firstWhere((t) => t.id == taskId);

  print('\n=== Final State ===');
  print('Client A: ${taskA.name}, Complete: ${taskA.completion}');
  print('Client B: ${taskB.name}, Complete: ${taskB.completion}');

  if (taskA.contentHash == taskB.contentHash) {
    print('\nSUCCESS: Replicas have converged! Hash: ${taskA.contentHash.substring(0, 8)}...');
  } else {
    print('\nFAILURE: Replicas diverged!');
  }
}
