import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'hlc.dart';

/// Represents a node in the Merkle Tree.
class MerkleNode {
  /// The hash content of this node.
  final String hash;

  /// The prefix (e.g. '2023-10-27') this node covers. Empty string for root.
  final String prefix;

  /// The inclusive start of the HLC range covered by this node.
  final Hlc? rangeStart;

  /// The exclusive end of the HLC range covered by this node.
  final Hlc? rangeEnd;

  /// The children nodes of this node. Empty for leaves.
  final Map<String, MerkleNode> children;

  /// The number of items (tasks/dependencies/resources) in this subtree.
  final int count;

  /// Creates a [MerkleNode].
  MerkleNode({
    required this.hash,
    required this.prefix,
    this.rangeStart,
    this.rangeEnd,
    this.children = const {},
    this.count = 0,
  });

  /// Converts the node to a JSON map.
  Map<String, dynamic> toJson() => {
        'hash': hash,
        'prefix': prefix,
        'rangeStart': rangeStart?.toString(),
        'rangeEnd': rangeEnd?.toString(),
        'children': children.map((key, value) => MapEntry(key, value.toJson())),
        'count': count,
      };
}

/// A time-based Merkle Tree implementation.
/// It buckets items based on their last updated HLC timestamp.
class MerkleTree {
  /// The root node of the tree.
  final MerkleNode root;

  /// Creates a [MerkleTree] with the given root node.
  MerkleTree(this.root);

  /// Computes a SHA-256 hash of the given string content.
  static String hash(String content) {
    if (content.isEmpty) {
      final bytes = utf8.encode('');
      return sha256.convert(bytes).toString();
    }
    final bytes = utf8.encode(content);
    return sha256.convert(bytes).toString();
  }

  /// Combines multiple hashes into a single hash.
  /// Sorts the input hashes to ensure the result is deterministic and order-independent.
  static String combineHashes(List<String> hashes) {
    if (hashes.isEmpty) return hash('');
    hashes.sort(); // Ensure deterministic order
    return hash(hashes.join(','));
  }

  /// Computes the Merkle Root for a list of content hashes (Legacy flat implementation logic).
  /// This is used for backward compatibility or simple lists without HLC available.
  static String computeRoot(List<String> validContentHashes) =>
      combineHashes(validContentHashes);

  /// Encodes a map into a JSON string with sorted keys to ensure deterministic results.
  static String deterministicJsonEncode(dynamic data) {
    if (data is Map) {
      final sortedMap = <String, dynamic>{};
      final keys = data.keys.map((e) => e.toString()).toList()..sort();
      for (final key in keys) {
        sortedMap[key] = deterministicJsonEncode(data[key]);
      }
      return jsonEncode(sortedMap);
    } else if (data is List) {
      return jsonEncode(
          data.map((item) => deterministicJsonEncode(item)).toList());
    }
    return jsonEncode(data);
  }

  /// Builds a Merkle Tree from a map of HLC strings to content hashes.
  static MerkleTree build(List<MapEntry<String, String>> items) {
    // 1. Group items by Hour prefix (length 13: YYYY-MM-DDTHH)
    final Map<String, List<String>> hourBuckets = {};

    for (final entry in items) {
      final hlcStr = entry.key;
      final contentHash = entry.value;

      // Extract ISO prefix "YYYY-MM-DDTHH:mm" (16 chars)
      // If invalid or too short, bucket into a default "0000-00-00T00:00"
      String minutePrefix = '0000-00-00T00:00';
      if (hlcStr.length >= 16 && hlcStr.contains('T') && hlcStr.contains(':')) {
        minutePrefix = hlcStr.substring(0, 16);
      }

      hourBuckets.putIfAbsent(minutePrefix, () => []).add(contentHash);
    }

    // 2. Build Hour Nodes (Leaves of the bucket tree)
    final Map<String, MerkleNode> hourNodes = {};
    for (final entry in hourBuckets.entries) {
      final prefix = entry.key;
      final hashes = entry.value;
      hourNodes[prefix] = MerkleNode(
        hash: combineHashes(hashes),
        prefix: prefix,
        count: hashes.length,
      );
    }

    // 3. Group Hour Nodes by Day prefix (length 10: YYYY-MM-DD)
    final Map<String, Map<String, MerkleNode>> dayBuckets = {};
    for (final entry in hourNodes.entries) {
      final hourPrefix = entry.key;
      final node = entry.value;

      String dayPrefix = '0000-00-00';
      if (hourPrefix.length >= 10) {
        dayPrefix = hourPrefix.substring(0, 10);
      }

      dayBuckets.putIfAbsent(dayPrefix, () => {})[hourPrefix] = node;
    }

    // 4. Build Day Nodes
    final Map<String, MerkleNode> dayNodes = {};
    for (final entry in dayBuckets.entries) {
      final prefix = entry.key;
      final children = entry.value;
      final childHashes = children.values.map((n) => n.hash).toList();
      final count = children.values.fold(0, (sum, n) => sum + n.count);

      dayNodes[prefix] = MerkleNode(
        hash: combineHashes(childHashes),
        prefix: prefix,
        children: children,
        count: count,
      );
    }

    // 5. Build Root Node
    final rootChildHashes = dayNodes.values.map((n) => n.hash).toList();
    final totalCount = dayNodes.values.fold(0, (sum, n) => sum + n.count);

    final rootNode = MerkleNode(
      hash: combineHashes(rootChildHashes),
      prefix: '',
      children: dayNodes,
      count: totalCount,
    );

    return MerkleTree(rootNode);
  }

  /// Get the node for a specific prefix inside this tree.
  MerkleNode? getNode(String prefix) {
    if (prefix.isEmpty) return root;

    if (prefix.length == 10) {
      return root.children[prefix];
    } else if (prefix.length == 16) {
      final dayPrefix = prefix.substring(0, 10);
      final dayNode = root.children[dayPrefix];
      return dayNode?.children[prefix];
    }

    return null;
  }
}
