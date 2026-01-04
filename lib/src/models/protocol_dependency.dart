import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Defines the type of dependency between two tasks.
enum ProtocolDependencyType {
  /// The successor cannot start until the predecessor finishes.
  finishToStart,

  /// The successor cannot start until the predecessor starts.
  startToStart,

  /// The successor cannot finish until the predecessor finishes.
  finishToFinish,

  /// The successor cannot finish until the predecessor starts.
  startToFinish,

  /// The successor must happen entirely within the duration of the predecessor.
  contained,
}

/// Represents a dependency relation between two tasks.
class ProtocolDependency {
  /// The ID of the predecessor task (the one that controls the timing).
  final String predecessorTaskId;

  /// The ID of the successor task (the one being controlled).
  final String successorTaskId;

  /// The type of dependency relationship.
  final ProtocolDependencyType type;

  /// The lag time between the two tasks.
  final Duration? lag;

  /// optional metadata field for last updated timestamp.
  final int? lastUpdated; // Optional metadata

  /// Creates a [ProtocolDependency].
  const ProtocolDependency({
    required this.predecessorTaskId,
    required this.successorTaskId,
    this.type = ProtocolDependencyType.finishToStart,
    this.lag,
    this.lastUpdated,
  });

  /// Computes a deterministic SHA-256 hash of the dependency content.
  String get contentHash {
    final data = {
      'predecessorTaskId': predecessorTaskId,
      'successorTaskId': successorTaskId,
      'type': type.name,
      'lag': lag?.inMilliseconds,
    };
    final jsonString = jsonEncode(data);
    final bytes = utf8.encode(jsonString);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Creates a [ProtocolDependency] from a JSON map.
  factory ProtocolDependency.fromJson(Map<String, dynamic> json) {
    return ProtocolDependency(
      predecessorTaskId: json['predecessorTaskId'],
      successorTaskId: json['successorTaskId'],
      type: ProtocolDependencyType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ProtocolDependencyType.finishToStart,
      ),
      lag: json['lag'] != null ? Duration(milliseconds: json['lag']) : null,
      lastUpdated: json['lastUpdated'],
    );
  }

  /// Converts the dependency to a JSON map.
  Map<String, dynamic> toJson() => {
    'predecessorTaskId': predecessorTaskId,
    'successorTaskId': successorTaskId,
    'type': type.name,
    'lag': lag?.inMilliseconds,
    'lastUpdated': lastUpdated,
  };
}
