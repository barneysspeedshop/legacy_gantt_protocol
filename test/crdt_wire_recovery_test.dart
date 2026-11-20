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
        'fieldTimestamps': {'isDeleted': clock.toString()},
        'metadataJson': jsonEncode({'color': 0xffaabbcc}),
      };
      final canonical = ProtobufMapper.taskFromJson(snapshot);
      canonical.fieldTimestamps.addAll(canonical.normalizedFieldTimestamps);
      snapshot['fieldTimestamps'] = Map<String, String>.from(
        canonical.fieldTimestamps,
      );
      snapshot['metadataJson'] = jsonEncode(
        MerkleHashNormalizer.completeTaskMetadata(
          jsonDecode(canonical.metadataJson) as Map<String, dynamic>,
        ),
      );
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
  test(
    'fresh resource tombstone recovery produces a canonical minimal record',
    () {
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
          resources: [
            ProtobufMapper.resourceFromJson({
              'id': 'resource',
              'name': '',
              'parentId': '',
              'type': 'person',
              'isDeleted': true,
              'lastUpdated': clock.toString(),
              'metadataJson': '{}',
            }),
          ],
        ),
      );
    },
  );
  test('task tombstones merge historical fields without resurrection', () {
    final tombstone = ProtobufMapper.taskFromJson({
      'id': 'deleted',
      'name': 'Deleted',
      'isDeleted': true,
      'lastUpdated': clock.toString(),
      'metadataJson': '{"color":42}',
      'fieldTimestamps': {
        'isDeleted': clock.toString(),
        'name': Hlc.fromIntTimestamp(500).toString(),
        'color': Hlc.fromIntTimestamp(500).toString(),
      },
    });
    for (final type in ['INSERT_TASK', 'UPDATE_TASK']) {
      for (final millis in [1000, 2000]) {
        final merged = engine.mergeTasks(
          [tombstone],
          [
            wireOperation(type, {
              'id': 'deleted',
              'name': 'Stale',
              'color': 99,
            }, Hlc.fromIntTimestamp(millis)),
          ],
        );
        expect(merged.single.isDeleted, isTrue, reason: '$type at $millis');
        expect(merged.single.name, 'Stale');
        expect(jsonDecode(merged.single.metadataJson)['color'], 99);
        expect(merged.single.lastUpdated, clock.toString());
      }
    }
    final restored = engine.mergeTasks(
      [tombstone],
      [
        wireOperation('UPDATE_TASK', {
          'id': 'deleted',
          'name': 'Restored',
        }, Hlc.fromIntTimestamp(3000)),
      ],
    );
    expect(restored.single.isDeleted, isFalse);
    expect(restored.single.name, 'Restored');
  });

  test('resource tombstones reject older and equal-clock live updates', () {
    final tombstone = ProtobufMapper.resourceFromJson({
      'id': 'deleted',
      'name': 'Deleted',
      'type': 'person',
      'isDeleted': true,
      'lastUpdated': clock.toString(),
      'metadataJson': '{"sortOrder":2}',
    });
    for (final type in ['INSERT_RESOURCE', 'UPDATE_RESOURCE']) {
      for (final millis in [1000, 2000]) {
        final merged = engine.mergeResources(
          [tombstone],
          [
            wireOperation(type, {
              'id': 'deleted',
              'name': 'Stale',
              'sortOrder': 99,
            }, Hlc.fromIntTimestamp(millis)),
          ],
        );
        expect(merged.single.isDeleted, isTrue, reason: '$type at $millis');
        expect(merged.single.contentHash, tombstone.contentHash);
        expect(merged.single.lastUpdated, clock.toString());
      }
    }
    final restored = engine.mergeResources(
      [tombstone],
      [
        wireOperation('UPDATE_RESOURCE', {
          'id': 'deleted',
          'name': 'Restored',
        }, Hlc.fromIntTimestamp(3000)),
      ],
    );
    expect(restored.single.isDeleted, isFalse);
    expect(restored.single.name, 'Restored');
  });
}
