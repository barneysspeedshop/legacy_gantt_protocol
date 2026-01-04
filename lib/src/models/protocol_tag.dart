import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../sync/hlc.dart';

/// Represents an immutable snapshot (tag) of the project state.
///
/// A [ProtocolTag] captures the Merkle Root of the project at a specific point in time,
/// serving as a "Baseline" for regulatory compliance or versioning.
class ProtocolTag {
  final String id;
  final String name;
  final String merkleRoot;
  final Hlc timestamp; // When the tag was created
  final String? actorId; // Who created it
  final bool isDeleted;
  final Map<String, dynamic> metadata;

  const ProtocolTag({
    required this.id,
    required this.name,
    required this.merkleRoot,
    required this.timestamp,
    this.actorId,
    this.isDeleted = false,
    this.metadata = const {},
  });

  /// Deterministic content hash for the tag itself.
  String get contentHash {
    final data = {
      'id': id,
      'name': name,
      'merkleRoot': merkleRoot,
      'timestamp': timestamp.toString(),
      'actorId': actorId,
      'isDeleted': isDeleted,
      'metadata': metadata,
    };
    // Sort keys if necessary for canonical JSON, but standard encoding usually stable enough for simple maps
    // Ideally we should use a canonical JSON serializer.
    final jsonString = jsonEncode(data);
    final bytes = utf8.encode(jsonString);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  factory ProtocolTag.fromJson(Map<String, dynamic> json) {
    Hlc parsedTimestamp = Hlc.zero;
    if (json['timestamp'] is String) {
      parsedTimestamp = Hlc.parse(json['timestamp']);
    }

    return ProtocolTag(
      id: json['id'],
      name: json['name'],
      merkleRoot: json['merkleRoot'],
      timestamp: parsedTimestamp,
      actorId: json['actorId'],
      isDeleted: json['isDeleted'] == true,
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'merkleRoot': merkleRoot,
    'timestamp': timestamp.toString(),
    'actorId': actorId,
    'isDeleted': isDeleted,
    'metadata': metadata,
  };

  ProtocolTag copyWith({String? id, String? name, String? merkleRoot, Hlc? timestamp, String? actorId, bool? isDeleted, Map<String, dynamic>? metadata}) {
    return ProtocolTag(
      id: id ?? this.id,
      name: name ?? this.name,
      merkleRoot: merkleRoot ?? this.merkleRoot,
      timestamp: timestamp ?? this.timestamp,
      actorId: actorId ?? this.actorId,
      isDeleted: isDeleted ?? this.isDeleted,
      metadata: metadata ?? this.metadata,
    );
  }
}
