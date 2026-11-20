import 'dart:convert';

import 'package:legacy_gantt_protocol/legacy_gantt_protocol.dart';
import 'package:test/test.dart';

Hlc _clock(int value) => Hlc(millis: value, counter: 0, nodeId: 'fixture');
Operation _edit(int value, Map<String, dynamic> data) => Operation(
  type: 'UPDATE_TASK',
  data: {'id': 'task', ...data},
  timestamp: _clock(value),
  actorId: 'fixture',
);

void main() {
  test(
    'same values with different field clocks have different Merkle roots',
    () {
      final engine = CRDTEngine();
      final base = _edit(100, {'name': 'A'});
      final common = _edit(300, {'notes': 'Common'});
      final client = engine.mergeTasks([], [
        base,
        _edit(200, {'name': 'A'}),
        common,
      ]).single;
      final server = engine.mergeTasks([], [base, common]).single;
      expect(client.name, 'A');
      expect(server.name, 'A');
      expect(client.lastUpdated, server.lastUpdated);
      expect(client.contentHash, isNot(server.contentHash));
      expect(
        engine.computeMerkleRoot([client]),
        isNot(engine.computeMerkleRoot([server])),
      );

      final delayed = _edit(150, {'name': 'B'});
      final clientAfter = engine.mergeTasks([client], [delayed]).single;
      final serverAfter = engine.mergeTasks([server], [delayed]).single;
      expect(clientAfter.name, 'A');
      expect(serverAfter.name, 'B');
      final repairedServer = engine
          .mergeTasks(
            [serverAfter],
            [_edit(300, ProtobufMapper.taskToJson(clientAfter))],
          )
          .single;
      final repairedClient = engine
          .mergeTasks(
            [clientAfter],
            [_edit(300, ProtobufMapper.taskToJson(repairedServer))],
          )
          .single;
      expect(repairedClient.name, 'A');
      expect(repairedServer.name, 'A');
      expect(repairedClient.contentHash, repairedServer.contentHash);
    },
  );

  test('legacy missing clocks equal explicit normalized baseline clocks', () {
    final legacy = ProtocolTask(
      id: 'task',
      name: 'A',
      lastUpdated: _clock(200).toString(),
      metadataJson: '{}',
    );
    final explicit = legacy.deepCopy();
    explicit.fieldTimestamps.addAll(legacy.normalizedFieldTimestamps);
    explicit.metadataJson = jsonEncode(
      MerkleHashNormalizer.completeTaskMetadata({}),
    );
    expect(legacy.contentHash, explicit.contentHash);
    explicit.fieldTimestamps['name'] = _clock(100).toString();
    expect(legacy.contentHash, isNot(explicit.contentHash));
  });

  test(
    'clock order and equivalent HLC encodings normalize deterministically',
    () {
      final first = ProtocolTask(
        id: 'task',
        lastUpdated: '200',
        metadataJson: '{}',
      );
      first.fieldTimestamps.addAll({'name': '100', 'custom': '150'});
      final second = ProtocolTask(
        id: 'task',
        lastUpdated: Hlc.parse('200').toString(),
        metadataJson: '{}',
      );
      second.fieldTimestamps.addAll({
        'custom': Hlc.parse('150').toString(),
        'name': Hlc.parse('100').toString(),
      });
      expect(first.contentHash, second.contentHash);
      second.fieldTimestamps['custom'] = '151';
      expect(first.contentHash, isNot(second.contentHash));
    },
  );

  test(
    'UI-only clocks do not change causal hashes or UTC display metadata',
    () {
      final engine = CRDTEngine();
      final task = engine.mergeTasks([], [
        _edit(100, {'name': 'A', 'startIsUtc': false}),
      ]).single;
      expect(jsonDecode(task.metadataJson)['startIsUtc'], false);
      final other = task.deepCopy();
      other.fieldTimestamps['startIsUtc'] = _clock(200).toString();
      other.fieldTimestamps['segments'] = _clock(300).toString();
      expect(task.contentHash, other.contentHash);
      final recovered = engine.mergeTasks([], [
        _edit(100, ProtobufMapper.taskToJson(task)),
      ]).single;
      expect(jsonDecode(recovered.metadataJson)['startIsUtc'], false);
      expect(recovered.contentHash, task.contentHash);
    },
  );
  test('existing envelope channel correlates Merkle request and response', () {
    for (final type in ['GET_MERKLE_ROOT', 'MERKLE_ROOT']) {
      final message = ProtobufMapper.toProtobuf({
        'type': type,
        'channel': 'merkle-root:fixture:1',
        'data': {'root': 'causal-root'},
      });
      final decoded = ProtobufMapper.toJson(
        ProtocolMessage.fromBuffer(message.writeToBuffer()),
      );
      expect(decoded['channel'], 'merkle-root:fixture:1');
      expect(decoded['type'], type);
      if (type == 'MERKLE_ROOT') {
        expect(decoded['data'], {'root': 'causal-root'});
      }
    }
  });
  test(
    'whole-record clocks differ even inside the same Merkle minute bucket',
    () {
      final engine = CRDTEngine();
      final first = ProtocolResource(
        id: 'resource',
        name: 'A',
        lastUpdated: _clock(100).toString(),
      );
      final second = first.deepCopy()..lastUpdated = _clock(200).toString();
      expect(first.contentHash, isNot(second.contentHash));
      expect(
        engine.computeMerkleRoot([], resources: [first]),
        isNot(engine.computeMerkleRoot([], resources: [second])),
      );
      final dependency = ProtocolDependency(
        predecessorTaskId: 'p',
        successorTaskId: 's',
        type: 'finishToStart',
        lastUpdated: _clock(100).toString(),
      );
      final later = dependency.deepCopy()..lastUpdated = _clock(200).toString();
      expect(dependency.contentHash, isNot(later.contentHash));
      expect(
        engine.computeMerkleRoot([], dependencies: [dependency]),
        isNot(engine.computeMerkleRoot([], dependencies: [later])),
      );
    },
  );
  test(
    'empty project reset epochs have distinct recoverable Merkle leaves',
    () {
      final engine = CRDTEngine();
      final initial = engine.computeMerkleRoot([]);
      final earlier = engine.computeMerkleRoot([], resetTimestamp: _clock(200));
      final later = engine.computeMerkleRoot([], resetTimestamp: _clock(500));
      expect(earlier, isNot(initial));
      expect(later, isNot(earlier));
      final leaf = CRDTEngine.resetMerkleEntry(_clock(500));
      expect(MerkleTree.build([leaf]).root.hash, later);
      expect(leaf.key, _clock(500).toString());
    },
  );
}
