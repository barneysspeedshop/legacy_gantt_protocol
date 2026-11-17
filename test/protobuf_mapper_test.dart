import 'package:legacy_gantt_protocol/legacy_gantt_protocol.dart';
import 'package:test/test.dart';

void main() {
  Map<String, dynamic> roundTrip(Map<String, dynamic> message) =>
      ProtobufMapper.toJson(ProtocolMessage.fromBuffer(
          ProtobufMapper.toProtobuf(message).writeToBuffer()));

  test('binary task messages retain dates, custom metadata and field clocks',
      () {
    final decoded = roundTrip({
      'type': 'UPDATE_TASK',
      'timestamp': '2026-11-17T12:00:00.000Z-0001-client',
      'actorId': 'client',
      'data': {
        'id': 'task',
        'rowId': 'row',
        'start': 0,
        'end': '1970-01-02T00:00:00.000Z',
        'color': 'ffff0000',
        'customField': {'value': 42},
        'fieldTimestamps': {'name': '2026-11-17T12:00:00.000Z-0001-client'},
      },
    });
    expect(decoded['type'], 'UPDATE_TASK');
    final data = decoded['data'] as Map<String, dynamic>;
    expect(data['start'], '1970-01-01T00:00:00.000Z');
    expect(data['end'], '1970-01-02T00:00:00.000Z');
    expect(data['color'], 'ffff0000');
    expect(data['customField'], {'value': 42});
    expect(data['fieldTimestamps'],
        {'name': '2026-11-17T12:00:00.000Z-0001-client'});
    expect(data.containsKey('metadataJson'), isFalse);
    expect(roundTrip(decoded), decoded);
  });

  test('batch deletes preserve tombstones and each operation clock', () {
    final decoded = roundTrip({
      'type': 'BATCH_UPDATE',
      'timestamp': '2026-11-17T12:00:00.000Z-0003-client',
      'actorId': 'client',
      'data': {
        'operations': [
          {
            'type': 'DELETE_TASK',
            'data': {'id': 'task'},
            'timestamp': '2026-11-17T12:00:00.000Z-0001-client',
            'actorId': 'client'
          },
          {
            'type': 'DELETE_RESOURCE',
            'data': {'id': 'resource'},
            'timestamp': '2026-11-17T12:00:00.000Z-0002-client',
            'actorId': 'client'
          },
        ]
      },
    });
    final ops = decoded['data']['operations'] as List;
    expect(ops.map((op) => op['type']).toList(),
        ['DELETE_TASK', 'DELETE_RESOURCE']);
    expect(ops.map((op) => op['data']['isDeleted']).toList(), [true, true]);
    expect(ops.map((op) => op['timestamp']).toList(), [
      '2026-11-17T12:00:00.000Z-0001-client',
      '2026-11-17T12:00:00.000Z-0002-client',
    ]);
  });

  test('subscription acknowledgements do not become CRDT operations', () {
    expect(roundTrip({'type': 'SUBSCRIBE_SUCCESS', 'channel': 'tenant'}),
        {'type': 'SUBSCRIBE_SUCCESS', 'channel': 'tenant'});
  });
}
