import 'package:test/test.dart';
import 'package:legacy_gantt_protocol/src/models/protocol_task.dart';
import 'package:legacy_gantt_protocol/src/sync/hlc.dart';

void main() {
  group('CRDT Determinism Hash Testing', () {
    final baseHlc = Hlc.fromDate(DateTime(2023, 10, 27, 10, 0, 0, 0, 0).toUtc(), 'node-1');

    final baseTask = ProtocolTask(
      id: 'task-1',
      rowId: 'row-1',
      start: DateTime.utc(2023, 11, 1),
      end: DateTime.utc(2023, 11, 5),
      name: 'Base Initialization Task',
      completion: 0.5,
      isSummary: false,
      isMilestone: false,
      resourceId: 'res-1',
      parentId: null,
      notes: 'Initial requirements definition',
      isDeleted: false,
      lastUpdated: baseHlc,
      lastUpdatedBy: 'actor-1',
      fieldTimestamps: {
        'name': baseHlc,
      },
      metadata: const {
        'color': '#ff0000',
        'tags': ['urgent', 'backend'],
      },
    );

    test('Identical Equality: Instances produce identical hashes', () {
      final taskA = baseTask.copyWith();
      final taskB = baseTask.copyWith(name: 'Base Initialization Task'); // Explicit same value

      expect(taskA.contentHash, equals(taskB.contentHash));
      expect(taskA.contentHash.isNotEmpty, isTrue);
    });

    test('Metadata Sorting: Map keys out of order still produce deterministic hashes', () {
      final taskA = baseTask.copyWith(
        metadata: const {
          'color': '#ff0000',
          'tags': ['urgent', 'backend'],
        },
      );
      
      final taskB = baseTask.copyWith(
        metadata: const {
          'tags': ['urgent', 'backend'],
          'color': '#ff0000',
        },
      );

      expect(taskA.contentHash, equals(taskB.contentHash), 
        reason: 'Metadata objects with keys in different orders should resolve to identical hashes through MerkleTree.deterministicJsonEncode');
    });

    test('Strict Mutation Differences: Changing any value strictly produces a different hash', () {
      final baseHash = baseTask.contentHash;

      // Ensure every property triggers a contentHash modification. Not doing so breaks the Merkle Sync logic!
      expect(baseTask.copyWith(name: 'Different Name').contentHash, isNot(equals(baseHash)));
      expect(baseTask.copyWith(id: 'task-1-mutated').contentHash, isNot(equals(baseHash)));
      expect(baseTask.copyWith(rowId: 'row-2').contentHash, isNot(equals(baseHash)));
      expect(baseTask.copyWith(start: DateTime.utc(2023, 11, 2)).contentHash, isNot(equals(baseHash)));
      expect(baseTask.copyWith(end: DateTime.utc(2023, 11, 6)).contentHash, isNot(equals(baseHash)));
      expect(baseTask.copyWith(completion: 0.8).contentHash, isNot(equals(baseHash)));
      expect(baseTask.copyWith(isSummary: true).contentHash, isNot(equals(baseHash)));
      expect(baseTask.copyWith(isMilestone: true).contentHash, isNot(equals(baseHash)));
      expect(baseTask.copyWith(resourceId: 'res-2').contentHash, isNot(equals(baseHash)));
      expect(baseTask.copyWith(parentId: 'parent-1').contentHash, isNot(equals(baseHash)));
      expect(baseTask.copyWith(notes: 'Updated notes!').contentHash, isNot(equals(baseHash)));
      expect(baseTask.copyWith(isDeleted: true).contentHash, isNot(equals(baseHash)));
      
      // Modify metadata
      expect(baseTask.copyWith(metadata: {'color': '#00ff00'}).contentHash, isNot(equals(baseHash)));
      expect(baseTask.copyWith(metadata: {}).contentHash, isNot(equals(baseHash)));
    });
  });
}
