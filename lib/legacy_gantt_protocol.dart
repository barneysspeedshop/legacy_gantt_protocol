/// The core protocol library for legacy_gantt_sync.
///
/// This library defines the data models (Tasks, Dependencies, Resources),
/// the synchronization primitives (HLCs, Merkle Trees, CRDT Engine), and
/// the client interface for building distributed Gantt Chart applications.
library legacy_gantt_protocol;

export 'src/models/operation.dart';
export 'src/models/protocol_task.dart';
export 'src/models/protocol_dependency.dart';
export 'src/models/protocol_resource.dart';
export 'src/models/protocol_tag.dart';

export 'src/sync/hlc.dart';
export 'src/sync/crdt_engine.dart';
export 'src/sync/merkle_tree.dart';

export 'src/client/gantt_sync_client.dart';
export 'src/client/sync_stats.dart';
