import 'package:collection/collection.dart';
import '../sync/hlc.dart';

/// Represents a single operation in the CRDT system.
class Operation {
  /// The type of operation (e.g., 'INSERT', 'UPDATE', 'DELETE').
  final String type;

  /// The version of the schema used for the data payload.
  final int schemaVersion;

  /// The payload of the operation.
  final Map<String, dynamic> data;

  /// The logical timestamp of the operation.
  final Hlc timestamp;

  /// The ID of the actor who originated the operation.
  final String actorId;

  /// Creates a new [Operation].
  Operation({
    required this.type,
    this.schemaVersion = 1,
    required this.data,
    required this.timestamp,
    required this.actorId,
  });

  /// Converts the operation to a JSON map.
  Map<String, dynamic> toJson() => {
    'type': type,
    'schemaVersion': schemaVersion,
    'data': data,
    'timestamp': timestamp.toString(),
    'actorId': actorId,
  };

  /// Creates an [Operation] from a JSON map.
  factory Operation.fromJson(Map<String, dynamic> json) {
    Hlc parsedTimestamp;
    final rawTimestamp = json['timestamp'];
    if (rawTimestamp is String) {
      parsedTimestamp = Hlc.parse(rawTimestamp);
    } else if (rawTimestamp is int) {
      parsedTimestamp = Hlc.fromIntTimestamp(rawTimestamp);
    } else {
      parsedTimestamp = Hlc.zero;
    }

    return Operation(
      type: json['type'] as String,
      schemaVersion: json['schemaVersion'] as int? ?? 1,
      data: json['data'] as Map<String, dynamic>,
      timestamp: parsedTimestamp,
      actorId: json['actorId'] as String,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Operation &&
        other.type == type &&
        const DeepCollectionEquality().equals(other.data, data) &&
        other.timestamp == timestamp &&
        other.actorId == actorId;
  }

  @override
  int get hashCode {
    return type.hashCode ^
        const DeepCollectionEquality().hash(data) ^
        timestamp.hashCode ^
        actorId.hashCode;
  }
}
