import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../generated/gantt_protocol.pb.dart';
import '../sync/hlc.dart';
import '../sync/merkle_hash_normalizer.dart';
import '../sync/merkle_tree.dart';

String _contentHash(Map<String, dynamic> values) => sha256
    .convert(utf8.encode(MerkleTree.deterministicJsonEncode(values)))
    .toString();

String _canonicalMetadata(
  String encoded,
  Map<String, dynamic> Function(Map<String, dynamic>) normalize,
) {
  try {
    final metadata = encoded.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(encoded) as Map<String, dynamic>;
    return MerkleTree.deterministicJsonEncode(normalize(metadata));
  } catch (_) {
    return encoded;
  }
}

extension ProtocolTaskExtensions on ProtocolTask {
  String get contentHash => _contentHash({
    'id': id,
    'lastUpdated': parsedLastUpdated.toString(),
    'rowId': rowId,
    'start': start,
    'end': end,
    'name': name,
    'completion': completion,
    'isSummary': isSummary,
    'isMilestone': isMilestone,
    'resourceId': resourceId,
    'parentId': parentId,
    'notes': notes,
    'isDeleted': isDeleted,
    'fieldTimestamps': {
      for (final entry in normalizedFieldTimestamps.entries)
        if (!MerkleHashNormalizer.taskNonCausalFields.contains(entry.key))
          entry.key: entry.value,
    },
    'metadataJson': _canonicalMetadata(
      metadataJson,
      MerkleHashNormalizer.normalizeTaskMetadata,
    ),
  });

  Map<String, String> get normalizedFieldTimestamps {
    Map<String, dynamic> metadata;
    try {
      metadata = metadataJson.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(metadataJson) as Map<String, dynamic>;
    } catch (_) {
      metadata = <String, dynamic>{};
    }
    return MerkleHashNormalizer.normalizeTaskFieldTimestamps(
      fieldTimestamps: fieldTimestamps,
      lastUpdated: lastUpdated,
      metadata: metadata,
    );
  }

  Hlc get parsedLastUpdated {
    if (hasLastUpdated() && lastUpdated.isNotEmpty) {
      return Hlc.parse(lastUpdated);
    }
    return Hlc.zero;
  }
}

extension ProtocolDependencyExtensions on ProtocolDependency {
  String get contentHash => _contentHash({
    'lastUpdated': parsedLastUpdated.toString(),
    'predecessorTaskId': predecessorTaskId,
    'successorTaskId': successorTaskId,
    'type': type,
    'lag': lag.toString(),
  });

  Hlc get parsedLastUpdated {
    if (hasLastUpdated() && lastUpdated.isNotEmpty) {
      return Hlc.parse(lastUpdated);
    }
    return Hlc.zero;
  }
}

extension ProtocolResourceExtensions on ProtocolResource {
  String get contentHash {
    final resourceType = type.isEmpty ? 'person' : type;
    return _contentHash({
      'id': id,
      'lastUpdated': parsedLastUpdated.toString(),
      'name': name,
      'parentId': parentId,
      'type': resourceType,
      'isDeleted': isDeleted,
      'metadataJson': _canonicalMetadata(
        metadataJson,
        (metadata) => MerkleHashNormalizer.normalizeResourceMetadata(
          metadata,
          type: resourceType,
        ),
      ),
    });
  }

  Hlc get parsedLastUpdated {
    if (hasLastUpdated() && lastUpdated.isNotEmpty) {
      return Hlc.parse(lastUpdated);
    }
    return Hlc.zero;
  }
}
