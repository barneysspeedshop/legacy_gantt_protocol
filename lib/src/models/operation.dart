import 'package:collection/collection.dart';
import '../sync/hlc.dart';

/// Represents a single operation in the CRDT system.
class Operation {
  final String type;
  final int schemaVersion;
  final Map<String, dynamic> data;
  final Hlc timestamp;
  final String actorId;

  Operation({
    required this.type,
    this.schemaVersion = 1,
    required this.data,
    required this.timestamp,
    required this.actorId,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'schemaVersion': schemaVersion,
    'data': data,
    'timestamp': timestamp.toString(),
    'actorId': actorId,
  };

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
