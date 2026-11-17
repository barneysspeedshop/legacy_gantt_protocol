/// The core protocol library for legacy_gantt_sync.
///
/// This library defines the data models (Tasks, Dependencies, Resources),
/// the synchronization primitives (HLCs, Merkle Trees, CRDT Engine), and
/// the client interface for building distributed Gantt Chart applications.
library;

export 'src/models/operation.dart';
export 'src/generated/gantt_protocol.pb.dart';
export 'src/models/protocol_tag.dart';
export 'src/models/protocol_extensions.dart';

export 'src/sync/hlc.dart';
export 'src/sync/crdt_engine.dart';
export 'src/sync/merkle_hash_normalizer.dart';
export 'src/sync/merkle_tree.dart' hide MerkleNode;

export 'src/audit/causal_integrity_audit.dart';

export 'src/client/gantt_sync_client.dart';
export 'src/client/sync_stats.dart';

export 'src/models/protobuf_mapper.dart';
