import 'dart:convert';
import 'package:crypto/crypto.dart';

enum ProtocolDependencyType { finishToStart, startToStart, finishToFinish, startToFinish, contained }

class ProtocolDependency {
  final String predecessorTaskId;
  final String successorTaskId;
  final ProtocolDependencyType type;
  final Duration? lag;
  final int? lastUpdated; // Optional metadata

  const ProtocolDependency({
    required this.predecessorTaskId,
    required this.successorTaskId,
    this.type = ProtocolDependencyType.finishToStart,
    this.lag,
    this.lastUpdated,
  });

  String get contentHash {
    final data = {'predecessorTaskId': predecessorTaskId, 'successorTaskId': successorTaskId, 'type': type.name, 'lag': lag?.inMilliseconds};
    final jsonString = jsonEncode(data);
    final bytes = utf8.encode(jsonString);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  factory ProtocolDependency.fromJson(Map<String, dynamic> json) {
    return ProtocolDependency(
      predecessorTaskId: json['predecessorTaskId'],
      successorTaskId: json['successorTaskId'],
      type: ProtocolDependencyType.values.firstWhere((e) => e.name == json['type'], orElse: () => ProtocolDependencyType.finishToStart),
      lag: json['lag'] != null ? Duration(milliseconds: json['lag']) : null,
      lastUpdated: json['lastUpdated'],
    );
  }

  Map<String, dynamic> toJson() => {
    'predecessorTaskId': predecessorTaskId,
    'successorTaskId': successorTaskId,
    'type': type.name,
    'lag': lag?.inMilliseconds,
    'lastUpdated': lastUpdated,
  };
}
