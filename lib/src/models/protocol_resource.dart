import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Represents a resource (person, equipment, etc.) in the Gantt project.
class ProtocolResource {
  /// The unique identifier of the resource.
  final String id;

  /// The display name of the resource.
  final String name;

  /// The ID of the parent resource, if any.
  final String? parentId;

  /// The type of resource ('person', 'equipment', etc.).
  final String type; // 'person', 'job', etc.

  /// Whether the resource is marked as deleted.
  final bool isDeleted;

  /// Extra properties (isExpanded, etc) or implementation-specific metadata.
  final Map<String, dynamic> metadata;

  /// Creates a [ProtocolResource].
  const ProtocolResource({
    required this.id,
    required this.name,
    this.parentId,
    this.type = 'person',
    this.isDeleted = false,
    this.metadata = const {},
  });

  /// Computes a deterministic SHA-256 hash of the resource content.
  String get contentHash {
    final data = {
      'id': id,
      'name': name,
      'parentId': parentId,
      'type': type,
      'isDeleted': isDeleted,
      'metadata': metadata,
    };
    final jsonString = jsonEncode(data);
    final bytes = utf8.encode(jsonString);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Creates a [ProtocolResource] from a JSON map.
  factory ProtocolResource.fromJson(Map<String, dynamic> json) =>
      ProtocolResource(
        id: json['id'],
        name: json['name'],
        parentId: json['parentId'],
        type: json['type'] ?? 'person',
        isDeleted: json['isDeleted'] == true,
        metadata: json['metadata'] ?? {},
      );

  /// Converts the resource to a JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'parentId': parentId,
        'type': type,
        'isDeleted': isDeleted,
        'metadata': metadata,
      };

  /// Creates a copy of this resource with the given fields replaced with new values.
  ProtocolResource copyWith({
    String? id,
    String? name,
    String? parentId,
    String? type,
    bool? isDeleted,
    Map<String, dynamic>? metadata,
  }) =>
      ProtocolResource(
        id: id ?? this.id,
        name: name ?? this.name,
        parentId: parentId ?? this.parentId,
        type: type ?? this.type,
        isDeleted: isDeleted ?? this.isDeleted,
        metadata: metadata ?? this.metadata,
      );
}
