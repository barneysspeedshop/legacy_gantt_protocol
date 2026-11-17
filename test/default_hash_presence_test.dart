import 'dart:convert';
import 'package:fixnum/fixnum.dart';
import 'package:legacy_gantt_protocol/legacy_gantt_protocol.dart';
import 'package:test/test.dart';

void main() {
  test('task hashes use scalar values rather than protobuf field presence', () {
    final absent = ProtocolTask(
      id: 'task',
      start: '2026-01-01T00:00:00.000Z',
      end: '2026-01-02T00:00:00.000Z',
    );
    final explicit = absent.deepCopy()
      ..rowId = ''
      ..name = ''
      ..completion = 0
      ..isSummary = false
      ..isMilestone = false
      ..resourceId = ''
      ..parentId = ''
      ..notes = ''
      ..isDeleted = false
      ..metadataJson = '{}';
    expect(absent.contentHash, explicit.contentHash);
    explicit.metadataJson = jsonEncode({
      'originalId': null,
      'baselineStart': null,
      'baselineEnd': null,
    });
    expect(absent.contentHash, explicit.contentHash);
    expect(
      ProtocolTask.fromBuffer(explicit.writeToBuffer()).contentHash,
      absent.contentHash,
    );
    expect(
      (explicit.deepCopy()..isDeleted = true).contentHash,
      isNot(absent.contentHash),
    );
  });
  test('resource omitted and explicit defaults have identical hashes', () {
    final absent = ProtocolResource(id: 'resource');
    final explicit = ProtocolResource(
      id: 'resource',
      name: '',
      parentId: '',
      type: 'person',
      isDeleted: false,
      metadataJson: '{}',
    );
    expect(absent.contentHash, explicit.contentHash);
    expect(
      ProtocolResource.fromBuffer(explicit.writeToBuffer()).contentHash,
      absent.contentHash,
    );
    expect(
      (explicit.deepCopy()..isDeleted = true).contentHash,
      isNot(absent.contentHash),
    );
  });
  test(
    'dependency zero lag and empty scalar presence do not change hashes',
    () {
      final absent = ProtocolDependency();
      final explicit = ProtocolDependency(
        predecessorTaskId: '',
        successorTaskId: '',
        type: '',
        lag: Int64.ZERO,
      );
      expect(absent.contentHash, explicit.contentHash);
      expect(
        ProtocolDependency.fromBuffer(explicit.writeToBuffer()).contentHash,
        absent.contentHash,
      );
      expect(
        (explicit.deepCopy()..lag = Int64(1)).contentHash,
        isNot(absent.contentHash),
      );
    },
  );
}
