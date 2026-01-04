/// Statistics about the synchronization state.
class SyncStats {
  /// The number of operations waiting to be sent (outbound queue).
  final int pendingOperations;

  /// The total number of operations processed in the current session (or since metrics reset).
  final int totalOperations;

  /// Creates a [SyncStats] instance.
  SyncStats({required this.pendingOperations, required this.totalOperations});
}

/// Represents the progress of an inbound synchronization.
class SyncProgress {
  /// The number of items processed so far.
  final int processed;

  /// The total number of items to process.
  final int total;

  /// A descriptive status message (e.g., "Downloading...", "Merging...").
  final String status;

  /// Creates a [SyncProgress] instance.
  const SyncProgress({this.processed = 0, this.total = 0, this.status = ''});

  /// The completion percentage (0.0 to 1.0).
  /// Returns 0.0 if total is 0.
  double get percentage => total == 0 ? 0 : processed / total;

  @override
  String toString() =>
      'SyncProgress(processed: $processed, total: $total, status: $status)';
}
