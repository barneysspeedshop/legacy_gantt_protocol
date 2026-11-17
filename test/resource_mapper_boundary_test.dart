import 'dart:convert';

import 'package:legacy_gantt_protocol/legacy_gantt_protocol.dart';
import 'package:test/test.dart';

void main() {
  test(
    'nested example resource payload retains its ID, legacy type and metadata on the wire',
    () {
      final encoded = ProtobufMapper.toProtobuf({
        'type': 'INSERT_RESOURCE',
        'data': <String, dynamic>{
          'gantt_type': 'job',
          'data': <String, dynamic>{
            'id': 'resource-1',
            'name': 'Equipment',
            'isExpanded': false,
            'category': 'equipment',
          },
        },
      }).writeToBuffer();
      final resource = ProtocolMessage.fromBuffer(
        encoded,
      ).singleOperation.resource;
      expect(resource.id, 'resource-1');
      expect(resource.name, 'Equipment');
      expect(resource.type, 'job');
      final metadata =
          jsonDecode(resource.metadataJson) as Map<String, dynamic>;
      expect(metadata['isExpanded'], isFalse);
      expect(metadata['category'], 'equipment');
      expect(metadata.containsKey('data'), isFalse);
    },
  );
}
