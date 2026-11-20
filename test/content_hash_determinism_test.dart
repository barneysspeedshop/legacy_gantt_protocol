import 'dart:convert';
import 'package:test/test.dart';
import 'package:legacy_gantt_protocol/legacy_gantt_protocol.dart';

void main() {
  group('Content Hash Determinism Tests', () {
    test(
      'ProtocolTask contentHash is independent of metadata map key insertion order',
      () {
        final t1 = ProtocolTask()
          ..id = 'task1'
          ..name = 'My Task'
          ..metadataJson = jsonEncode({
            'color': 'ffffff',
            'textColor': '000000',
            'stackIndex': 1,
          });

        final t2 = ProtocolTask()
          ..id = 'task1'
          ..name = 'My Task'
          ..metadataJson = jsonEncode({
            'stackIndex': 1,
            'textColor': '000000',
            'color': 'ffffff',
          });

        expect(t1.contentHash, equals(t2.contentHash));
      },
    );

    test(
      'ProtocolTask contentHash includes causal field clocks and ignores actor identity',
      () {
        final t1 = ProtocolTask()
          ..id = 'task1'
          ..name = 'My Task'
          ..lastUpdated = '2026-05-17T18:00:00.000Z'
          ..lastUpdatedBy = 'userA'
          ..fieldTimestamps['name'] = '2026-05-17T18:00:00.000Z';

        final t2 = ProtocolTask()
          ..id = 'task1'
          ..name = 'My Task'
          ..lastUpdated = '2026-05-17T19:00:00.000Z'
          ..lastUpdatedBy = 'userB'
          ..fieldTimestamps['name'] = '2026-05-17T19:00:00.000Z';

        expect(t1.contentHash, isNot(t2.contentHash));
        t2
          ..lastUpdated = t1.lastUpdated
          ..fieldTimestamps.clear()
          ..fieldTimestamps.addAll(t1.fieldTimestamps);
        expect(t1.contentHash, t2.contentHash);
      },
    );

    test(
      'ProtocolResource contentHash handles metadataJson deterministically',
      () {
        final r1 = ProtocolResource()
          ..id = 'res1'
          ..name = 'Resource 1'
          ..metadataJson = jsonEncode({'isExpanded': true, 'role': 'admin'});

        final r2 = ProtocolResource()
          ..id = 'res1'
          ..name = 'Resource 1'
          ..metadataJson = jsonEncode({'role': 'admin', 'isExpanded': true});

        expect(r1.contentHash, equals(r2.contentHash));
      },
    );
  });
}
