import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'hlc.dart';

/// Represents a node in the Merkle Tree.
/// Represents a node in the Merkle Tree.
class MerkleNode {
  /// The hash content of this node.
  final String hash;

  /// The inclusive start of the HLC range covered by this node.
  final Hlc?
  rangeStart; // Null for leaf nodes if we treat them specifically, but for time-based, it's the range

  /// The exclusive end of the HLC range covered by this node.
  final Hlc? rangeEnd;

  /// The children nodes of this node.
  final List<MerkleNode> children;

  /// The number of items (tasks/dependencies/resources) in this subtree.
  final int count; // Number of items in this subtree

  /// Creates a [MerkleNode].
  MerkleNode({
    required this.hash,
    this.rangeStart,
    this.rangeEnd,
    this.children = const [],
    this.count = 0,
  });

  /// Converts the node to a JSON map.
  Map<String, dynamic> toJson() => {
    'hash': hash,
    'rangeStart': rangeStart?.toString(),
    'rangeEnd': rangeEnd?.toString(),
    'children': children.map((c) => c.toJson()).toList(),
    'count': count,
  };
}

/// A simplified time-based Merkle Tree implementation.
/// It buckets items based on their last updated HLC timestamp.
class MerkleTree {
  // We'll use a fixed depth for simplicity in this initial version.
  // Depth 0 = Root (covers all time)
  // Depth 1 = Buckets (e.g., minutes/hours/days depending on implementation)

  // For this simplified version, let's just implement the hashing logic.
  // Real implementation will require building the tree from a list of tasks.

  /// Computes a SHA-256 hash of the given string content.
  static String hash(String content) {
    final bytes = utf8.encode(content);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Combines multiple hashes into a single hash.
  /// Sorts the input hashes to ensure the result is deterministic and order-independent.
  static String combineHashes(List<String> hashes) {
    if (hashes.isEmpty) return hash('');
    hashes.sort(); // Ensure deterministic order
    return hash(hashes.join(','));
  }

  /// Computes the Merkle Root for a list of content hashes.
  static String computeRoot(List<String> validContentHashes) =>
      combineHashes(validContentHashes);
}
