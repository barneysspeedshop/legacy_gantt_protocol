import '../models/operation.dart';

/// The Diagnostic Engine for inspecting the causal history of the Gantt system.
///
/// This class maintains an in-memory log of operations and provides methods
/// to query the history of specific tasks and analyze conflicts.
/// It is designed to be the "Source of Truth" for auditing why a task is in its current state.
class CausalIntegrityAudit {
  final List<Operation> _sessionHistory = [];

  /// Index of operations by Task ID for faster lookup.
  final Map<String, List<Operation>> _taskIndex = {};

  /// Records an operation into the audit log.
  ///
  /// This should be called for every operation processed by the system (inbound and outbound).
  void recordOperation(Operation op) {
    _sessionHistory.add(op);
    _indexOperation(op);
  }

  void _indexOperation(Operation op) {
    if (op.type == 'BATCH_UPDATE') {
      final subOpsList = op.data['operations'] as List? ?? [];
      for (final subOpMaps in subOpsList) {
        try {
          final subOp = Operation.fromJson(subOpMaps as Map<String, dynamic>);
          _indexSingleOp(subOp, parentOp: op);
        } catch (_) {
          // Ignore malformed sub-ops
        }
      }
    } else {
      _indexSingleOp(op);
    }
  }

  void _indexSingleOp(Operation op, {Operation? parentOp}) {
    // Extract Task ID if present
    final opData = op.data;
    var effectiveData = opData;
    if (effectiveData.containsKey('data') && effectiveData['data'] is Map) {
      effectiveData = effectiveData['data'];
    }

    // Check for Task ID in various common fields
    final String? taskId = effectiveData['id'] as String? ?? effectiveData['taskId'] as String?;

    if (taskId != null) {
      _taskIndex.putIfAbsent(taskId, () => []).add(parentOp ?? op);
    }
  }

  /// Returns the chronological history of operations affecting a specific task.
  List<Operation> getHistoryForTask(String taskId) {
    final ops = _taskIndex[taskId] ?? [];
    // Ensure chronological order by timestamp
    ops.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return ops;
  }

  /// Analyzes a conflict between two operations affecting the same field.
  ///
  /// Returns a [ConflictAnalysis] describing the winner and the reason.
  ConflictAnalysis analyzeConflict(Operation opA, Operation opB, String fieldId) {
    final tA = opA.timestamp;
    final tB = opB.timestamp;

    // 1. Physical Time Comparison
    if (tA.millis > tB.millis) {
      return ConflictAnalysis(winner: opA, loser: opB, fieldId: fieldId, reason: 'Operation A has a later physical time (${tA.millis} > ${tB.millis}).');
    }
    if (tB.millis > tA.millis) {
      return ConflictAnalysis(winner: opB, loser: opA, fieldId: fieldId, reason: 'Operation B has a later physical time (${tB.millis} > ${tA.millis}).');
    }

    // 2. Logical Counter Comparison
    if (tA.counter > tB.counter) {
      return ConflictAnalysis(
        winner: opA,
        loser: opB,
        fieldId: fieldId,
        reason: 'Physical time is equal, but Operation A has a higher logical counter (${tA.counter} > ${tB.counter}).',
      );
    }
    if (tB.counter > tA.counter) {
      return ConflictAnalysis(
        winner: opB,
        loser: opA,
        fieldId: fieldId,
        reason: 'Physical time is equal, but Operation B has a higher logical counter (${tB.counter} > ${tA.counter}).',
      );
    }

    // 3. Node ID Tie-Breaker
    final nodeComp = tA.nodeId.compareTo(tB.nodeId);
    if (nodeComp > 0) {
      return ConflictAnalysis(
        winner: opA,
        loser: opB,
        fieldId: fieldId,
        reason: 'Time and counters are equal. Operation A wins by Node ID tie-breaker (${tA.nodeId} > ${tB.nodeId}).',
      );
    } else if (nodeComp < 0) {
      return ConflictAnalysis(
        winner: opB,
        loser: opA,
        fieldId: fieldId,
        reason: 'Time and counters are equal. Operation B wins by Node ID tie-breaker (${tB.nodeId} > ${tA.nodeId}).',
      );
    }

    return ConflictAnalysis(winner: opA, loser: opB, fieldId: fieldId, reason: 'Operations are identical or fully equivalent timestamps.');
  }

  /// Returns the full session history.
  List<Operation> get sessionHistory => List.unmodifiable(_sessionHistory);

  /// Clears the history (e.g. on massive reset or memory constraint).
  void clear() {
    _sessionHistory.clear();
    _taskIndex.clear();
  }
}

/// Represents the result of a conflict analysis between two operations.
class ConflictAnalysis {
  /// The operation that won the conflict resolution.
  final Operation winner;

  /// The operation that lost the conflict resolution.
  final Operation loser;

  /// The ID of the field where the conflict occurred.
  final String fieldId;

  /// The explanation for why the winner won.
  final String reason;

  /// Creates a [ConflictAnalysis] result.
  ConflictAnalysis({required this.winner, required this.loser, required this.fieldId, required this.reason});
}
