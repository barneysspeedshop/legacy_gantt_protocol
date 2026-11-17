import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../generated/gantt_protocol.pb.dart';
import '../sync/hlc.dart';
import '../sync/merkle_hash_normalizer.dart';
import '../sync/merkle_tree.dart';

extension ProtocolTaskExtensions on ProtocolTask {
  String get contentHash {
    final pt = deepCopy()
      ..clearLastUpdated()
      ..clearLastUpdatedBy()
      ..fieldTimestamps.clear();

    if (pt.hasMetadataJson() && pt.metadataJson.isNotEmpty) {
      try {
        final meta = jsonDecode(pt.metadataJson) as Map<String, dynamic>;
        pt.metadataJson = MerkleTree.deterministicJsonEncode(
          MerkleHashNormalizer.normalizeTaskMetadata(meta),
        );
      } catch (_) {}
    }

    final jsonMap = pt.toProto3Json() as Map<String, dynamic>;
    final jsonStr = MerkleTree.deterministicJsonEncode(jsonMap);
    final bytes = utf8.encode(jsonStr);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Hlc get parsedLastUpdated {
    if (hasLastUpdated() && lastUpdated.isNotEmpty) {
      return Hlc.parse(lastUpdated);
    }
    return Hlc.zero;
  }
}

extension ProtocolDependencyExtensions on ProtocolDependency {
  String get contentHash {
    final pt = deepCopy()..clearLastUpdated();
    final jsonMap = pt.toProto3Json() as Map<String, dynamic>;
    final jsonStr = MerkleTree.deterministicJsonEncode(jsonMap);
    final bytes = utf8.encode(jsonStr);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Hlc get parsedLastUpdated {
    if (hasLastUpdated() && lastUpdated.isNotEmpty) {
      return Hlc.parse(lastUpdated);
    }
    return Hlc.zero;
  }
}

extension ProtocolResourceExtensions on ProtocolResource {
  String get contentHash {
    final pt = deepCopy()..clearLastUpdated();

    if (pt.hasMetadataJson() && pt.metadataJson.isNotEmpty) {
      try {
        final meta = jsonDecode(pt.metadataJson) as Map<String, dynamic>;
        pt.metadataJson = MerkleTree.deterministicJsonEncode(
          MerkleHashNormalizer.normalizeResourceMetadata(
            meta,
            type: pt.type.isNotEmpty ? pt.type : 'person',
          ),
        );
      } catch (_) {}
    }

    final jsonMap = pt.toProto3Json() as Map<String, dynamic>;
    final jsonStr = MerkleTree.deterministicJsonEncode(jsonMap);
    final bytes = utf8.encode(jsonStr);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Hlc get parsedLastUpdated {
    if (hasLastUpdated() && lastUpdated.isNotEmpty) {
      return Hlc.parse(lastUpdated);
    }
    return Hlc.zero;
  }
}
