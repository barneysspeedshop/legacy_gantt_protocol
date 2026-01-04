import 'dart:async';
import '../models/operation.dart';
import '../sync/hlc.dart';
import 'sync_stats.dart';

/// Interface for the synchronization client.
/// Users must implement this to provide their own backend.
abstract class GanttSyncClient {
  /// Stream of incoming operations from the server/peers.
  Stream<Operation> get operationStream;

  /// Sends an operation to the server/peers.
  Future<void> sendOperation(Operation operation);

  /// Sends multiple operations to the server/peers efficiently.
  Future<void> sendOperations(List<Operation> operations);

  /// Fetches the initial state or full state from the server.
  /// Returns a list of operations representing the history or current state.
  Future<List<Operation>> getInitialState();

  /// Stream of pending outbound operations count (e.g. offline queue size).
  Stream<int> get outboundPendingCount;

  /// Stream of inbound sync progress.
  Stream<SyncProgress> get inboundProgress;

  /// returns the current local Merkle Root hash.
  Future<String> getMerkleRoot();

  /// Initiates a Merkle-tree based synchronization with a remote peer/server.
  Future<void> syncWithMerkle({required String remoteRoot, required int depth});

  /// Returns the current Hybrid Logical Clock timestamp.
  /// Implementations should return the latest known HLC, creating one if necessary.
  Hlc get currentHlc;
}
