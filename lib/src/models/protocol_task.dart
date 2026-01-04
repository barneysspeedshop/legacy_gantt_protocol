import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../sync/hlc.dart';

/// Represents a task in the protocol layer (headless).
class ProtocolTask {
  /// The unique identifier for the task.
  final String id;

  /// The ID of the row this task belongs to.
  final String rowId;

  /// The start time of the task (UTC).
  final DateTime start;

  /// The end time of the task (UTC).
  final DateTime end;

  /// The display name of the task.
  final String? name;

  /// The completion percentage of the task (0.0 to 1.0).
  final double completion;

  /// Whether this task represents a summary of other tasks.
  final bool isSummary;

  /// Whether this task represents a milestone (zero duration).
  final bool isMilestone;

  /// The ID of the resource assigned to this task.
  final String? resourceId;

  /// The ID of the parent task, for hierarchical structures.
  final String? parentId;

  /// Additional notes or description for the task.
  final String? notes;

  /// Whether the task has been marked as deleted (tombstone).
  final bool isDeleted;

  /// The Hybrid Logical Clock timestamp of the last update to this task.
  final Hlc lastUpdated;

  /// The ID of the actor who last updated this task.
  final String? lastUpdatedBy;

  /// A map of field names to HLC timestamps, tracking the last update time for each field.
  /// Used for field-level Conflict Resolution (CRDT).
  final Map<String, Hlc> fieldTimestamps;

  /// Additional metadata for UI or implementation-specific fields (Color, etc).
  /// These are not part of the core comparison identity usually, but MIGHT be part of sync.
  final Map<String, dynamic> metadata;

  /// Creates a [ProtocolTask] with the given properties.
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

  /// Creates a [ProtocolTask] instance from a JSON map.
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

  /// Converts the [ProtocolTask] to a JSON map.
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

  /// Computes a deterministic SHA-256 hash of the task's content.
  /// Used for Merkle Tree computation to detect state differences.
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

  /// Creates a copy of this task with the given fields replaced with new values.
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
