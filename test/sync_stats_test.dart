import 'package:test/test.dart';
import 'package:legacy_gantt_protocol/legacy_gantt_protocol.dart';

void main() {
  group('SyncStats', () {
    test('percentage calculation handles zero total', () {
      const progress = SyncProgress(processed: 0, total: 0);
      expect(progress.percentage, 0.0);
    });

    test('percentage calculation is correct', () {
      const progress = SyncProgress(processed: 50, total: 100);
      expect(progress.percentage, 0.5);

      const progressStart = SyncProgress(processed: 0, total: 100);
      expect(progressStart.percentage, 0.0);

      const progressEnd = SyncProgress(processed: 100, total: 100);
      expect(progressEnd.percentage, 1.0);
    });

    test('toString returns correct format', () {
      const progress = SyncProgress(processed: 5, total: 10);
      expect(progress.toString(), 'SyncProgress(processed: 5, total: 10, status: )');
    });
  });
}
