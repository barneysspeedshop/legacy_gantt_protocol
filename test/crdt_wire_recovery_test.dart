import 'dart:convert';
import 'package:legacy_gantt_protocol/legacy_gantt_protocol.dart';
import 'package:test/test.dart';

Operation wireOperation(String type, Map<String, dynamic> data, Hlc clock) {
  final encoded = ProtobufMapper.toProtobuf({
    'type': type,
    'data': data,
    'timestamp': clock.toString(),
    'actorId': 'server',
  }).writeToBuffer();
  return Operation.fromJson(
    ProtobufMapper.toJson(ProtocolMessage.fromBuffer(encoded)),
  );
}

void main() {
  final engine = CRDTEngine();
  final clock = Hlc.fromIntTimestamp(2000);
  test(
    'wire resource canonical type survives merge without metadata pollution',
    () {
      final snapshot = {
        'id': 'resource',
        'name': 'People',
        'type': 'group',
        'lastUpdated': clock.toString(),
        'metadataJson': jsonEncode({'sortOrder': 2}),
      };
      final merged = engine.mergeResources([], [
        wireOperation('UPDATE_RESOURCE', snapshot, clock),
      ]);
      expect(merged.single.type, 'group');
      expect(jsonDecode(merged.single.metadataJson), {'sortOrder': 2});
      expect(
        engine.computeMerkleRoot([], resources: merged),
        engine.computeMerkleRoot(
          [],
          resources: [ProtobufMapper.resourceFromJson(snapshot)],
        ),
      );
    },
  );
  test(
    'fresh task tombstone recovery retains full snapshot and Merkle hash',
    () {
      final snapshot = {
        'id': 'task',
        'rowId': 'row',
        'name': 'Deleted',
        'start': '2026-11-17T00:00:00.000Z',
        'end': '2026-11-18T00:00:00.000Z',
        'isDeleted': true,
        'lastUpdated': clock.toString(),
        'lastUpdatedBy': 'server',
        'metadataJson': jsonEncode({'color': 0xffaabbcc}),
      };
      final merged = engine.mergeTasks([], [
        wireOperation('DELETE_TASK', snapshot, clock),
      ]);
      expect(merged, hasLength(1));
      expect(merged.single.isDeleted, isTrue);
      expect(merged.single.name, 'Deleted');
      expect(
        engine.computeMerkleRoot(merged),
        engine.computeMerkleRoot([ProtobufMapper.taskFromJson(snapshot)]),
      );
      final stale = wireOperation('UPDATE_TASK', {
        'id': 'task',
        'name': 'Stale',
      }, Hlc.fromIntTimestamp(1000));
      expect(engine.mergeTasks(merged, [stale]).single.isDeleted, isTrue);
    },
  );
  test('fresh resource tombstone recovery retains full snapshot and hash', () {
    final snapshot = {
      'id': 'resource',
      'name': 'Deleted',
      'type': 'group',
      'isDeleted': true,
      'lastUpdated': clock.toString(),
      'metadataJson': jsonEncode({'sortOrder': 2}),
    };
    final merged = engine.mergeResources([], [
      wireOperation('DELETE_RESOURCE', snapshot, clock),
    ]);
    expect(merged, hasLength(1));
    expect(merged.single.isDeleted, isTrue);
    expect(
      engine.computeMerkleRoot([], resources: merged),
      engine.computeMerkleRoot(
        [],
        resources: [ProtobufMapper.resourceFromJson(snapshot)],
      ),
    );
  });
}
