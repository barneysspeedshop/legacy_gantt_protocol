class SyncStats {
  final int pendingOperations;
  final int totalOperations;

  SyncStats({required this.pendingOperations, required this.totalOperations});
}

class SyncProgress {
  final int processed;
  final int total;
  final String status;

  const SyncProgress({this.processed = 0, this.total = 0, this.status = ''});

  double get percentage => total == 0 ? 0 : processed / total;

  @override
  String toString() =>
      'SyncProgress(processed: $processed, total: $total, status: $status)';
}
