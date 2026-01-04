import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../sync/hlc.dart';

/// Represents a task in the protocol layer (headless).
class ProtocolTask {
  final String id;
  final String rowId;
  final DateTime start;
  final DateTime end;
  final String? name;
  final double completion;
  final bool isSummary;
  final bool isMilestone;
  final String? resourceId;
  final String? parentId;
  final String? notes;
  final bool isDeleted;

  final Hlc lastUpdated;
  final String? lastUpdatedBy;
  final Map<String, Hlc> fieldTimestamps;

  /// Additional metadata for UI or implementation-specific fields (Color, etc).
  /// These are not part of the core comparison identity usually, but MIGHT be part of sync.
  final Map<String, dynamic> metadata;

  const ProtocolTask({
    required this.id,
    required this.rowId,
    required this.start,
    required this.end,
    this.name,
    this.completion = 0.0,
    this.isSummary = false,
    this.isMilestone = false,
    this.resourceId,
    this.parentId,
    this.notes,
    this.isDeleted = false,
    required this.lastUpdated,
    this.lastUpdatedBy,
    this.fieldTimestamps = const {},
    this.metadata = const {},
  });

  factory ProtocolTask.fromJson(Map<String, dynamic> json) {
    Hlc parsedHlc = Hlc.zero;
    if (json['lastUpdated'] is String) {
      parsedHlc = Hlc.parse(json['lastUpdated']);
    }

    Map<String, Hlc> parsedFieldTimestamps = {};
    if (json['fieldTimestamps'] != null) {
      (json['fieldTimestamps'] as Map).forEach((k, v) {
        if (v is String) parsedFieldTimestamps[k as String] = Hlc.parse(v);
      });
    }

    return ProtocolTask(
      id: json['id'],
      rowId: json['rowId'],
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
      name: json['name'],
      completion: (json['completion'] as num?)?.toDouble() ?? 0.0,
      isSummary: json['isSummary'] == true,
      isMilestone: json['isMilestone'] == true,
      resourceId: json['resourceId'],
      parentId: json['parentId'],
      notes: json['notes'],
      isDeleted: json['isDeleted'] == true,
      lastUpdated: parsedHlc,
      lastUpdatedBy: json['lastUpdatedBy'],
      fieldTimestamps: parsedFieldTimestamps,
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'rowId': rowId,
    'start': start.toUtc().toIso8601String(),
    'end': end.toUtc().toIso8601String(),
    'name': name,
    'completion': completion,
    'isSummary': isSummary,
    'isMilestone': isMilestone,
    'resourceId': resourceId,
    'parentId': parentId,
    'notes': notes,
    'isDeleted': isDeleted,
    'lastUpdated': lastUpdated.toString(),
    'lastUpdatedBy': lastUpdatedBy,
    'fieldTimestamps': fieldTimestamps.map((k, v) => MapEntry(k, v.toString())),
    'metadata': metadata,
  };

  String get contentHash {
    // Hashes core data and metadata.
    // Ensure map keys are sorted for deterministic hashing if needed.
    // For now, using standard map iteration which may not be sorted.
    // But usually contentHash is specific fields.

    final data = {
      'id': id,
      'rowId': rowId,
      'start': start.toUtc().toIso8601String(),
      'end': end.toUtc().toIso8601String(),
      'name': name,
      'completion': completion,
      'isSummary': isSummary,
      'isMilestone': isMilestone,
      'resourceId': resourceId,
      'parentId': parentId,
      'notes': notes,
      'isDeleted': isDeleted,
      'metadata': metadata, // Include metadata in hash!
    };
    final jsonString = jsonEncode(data);
    final bytes = utf8.encode(jsonString);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  ProtocolTask copyWith({
    String? id,
    String? rowId,
    DateTime? start,
    DateTime? end,
    String? name,
    double? completion,
    bool? isSummary,
    bool? isMilestone,
    String? resourceId,
    String? parentId,
    String? notes,
    bool? isDeleted,
    Hlc? lastUpdated,
    String? lastUpdatedBy,
    Map<String, Hlc>? fieldTimestamps,
    Map<String, dynamic>? metadata,
  }) {
    return ProtocolTask(
      id: id ?? this.id,
      rowId: rowId ?? this.rowId,
      start: start ?? this.start,
      end: end ?? this.end,
      name: name ?? this.name,
      completion: completion ?? this.completion,
      isSummary: isSummary ?? this.isSummary,
      isMilestone: isMilestone ?? this.isMilestone,
      resourceId: resourceId ?? this.resourceId,
      parentId: parentId ?? this.parentId,
      notes: notes ?? this.notes,
      isDeleted: isDeleted ?? this.isDeleted,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      lastUpdatedBy: lastUpdatedBy ?? this.lastUpdatedBy,
      fieldTimestamps: fieldTimestamps ?? this.fieldTimestamps,
      metadata: metadata ?? this.metadata,
    );
  }
}
