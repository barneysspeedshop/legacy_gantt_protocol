import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../sync/hlc.dart';

/// Represents an immutable snapshot (tag) of the project state.
///
/// A [ProtocolTag] captures the Merkle Root of the project at a specific point in time,
/// serving as a "Baseline" for regulatory compliance or versioning.
class ProtocolTag {
  /// The unique identifier of the tag.
  final String id;

  /// The human-readable name of the tag.
  final String name;

  /// The Merkle Root hash representing the state at this tag's creation time.
  final String merkleRoot;

  /// When the tag was created (HLC).
  final Hlc timestamp;

  /// The ID of the actor who created the tag.
  final String? actorId;

  /// Whether the tag is marked as deleted.
  final bool isDeleted;

  /// Arbitrary metadata associated with the tag.
  final Map<String, dynamic> metadata;

  /// Creates a [ProtocolTag].
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

  /// Creates a [ProtocolTag] from a JSON map.
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

  /// Converts the tag to a JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'merkleRoot': merkleRoot,
    'timestamp': timestamp.toString(),
    'actorId': actorId,
    'isDeleted': isDeleted,
    'metadata': metadata,
  };

  /// Creates a copy of this tag with the given fields replaced with new values.
  ProtocolTag copyWith({
    String? id,
    String? name,
    String? merkleRoot,
    Hlc? timestamp,
    String? actorId,
    bool? isDeleted,
    Map<String, dynamic>? metadata,
  }) {
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
