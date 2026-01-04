import 'dart:convert';
import 'package:crypto/crypto.dart';

class ProtocolResource {
  final String id;
  final String name;
  final String? parentId;
  final String type; // 'person', 'job', etc.
  final bool isDeleted;

  /// Extra properties (isExpanded, etc)
  final Map<String, dynamic> metadata;

  const ProtocolResource({required this.id, required this.name, this.parentId, this.type = 'person', this.isDeleted = false, this.metadata = const {}});

  String get contentHash {
    final data = {'id': id, 'name': name, 'parentId': parentId, 'type': type, 'isDeleted': isDeleted, 'metadata': metadata};
    final jsonString = jsonEncode(data);
    final bytes = utf8.encode(jsonString);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  factory ProtocolResource.fromJson(Map<String, dynamic> json) => ProtocolResource(
    id: json['id'],
    name: json['name'],
    parentId: json['parentId'],
    type: json['type'] ?? 'person',
    isDeleted: json['isDeleted'] == true,
    metadata: json['metadata'] ?? {},
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'parentId': parentId, 'type': type, 'isDeleted': isDeleted, 'metadata': metadata};

  ProtocolResource copyWith({String? id, String? name, String? parentId, String? type, bool? isDeleted, Map<String, dynamic>? metadata}) => ProtocolResource(
    id: id ?? this.id,
    name: name ?? this.name,
    parentId: parentId ?? this.parentId,
    type: type ?? this.type,
    isDeleted: isDeleted ?? this.isDeleted,
    metadata: metadata ?? this.metadata,
  );
}
