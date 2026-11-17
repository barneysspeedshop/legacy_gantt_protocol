## 3.0.1

* Reject task and resource resurrection at or before their deletion clock. Preserve tombstone content during stale retries; strictly newer edits can still restore deleted entities.

## 3.0.0

* **BREAKING**: CRDT task and resource merge results retain tombstones. Filter deleted records for UI projections while retaining the full state for future merges and Merkle checks.

* **BREAKING**: Export generated Protobuf models and use binary production WebSocket frames. Dates and HLC model fields are strings; dependency lag uses Int64 and metadata uses metadataJson.
* Canonicalize RGB and ARGB colors for consistent hashes while preserving alpha. Six- and eight-digit strings are hexadecimal; other numeric strings retain legacy decimal support.
* Hash semantic scalar values and canonical metadata defaults independently of Protobuf field presence.
* Retain flat and nested resource metadata through binary serialization.
* Add the shared ProtobufMapper and preserve batch deletion markers and per-record clocks.
* Require Dart 3.8 or newer. Deploy production clients and server together; the Go JSON mock remains a separate test transport.

## 2.1.0

*   **FEAT**: Increased Merkle tree granularity to **Minute-level** (16-character bucket prefixes) for more precise data reconciliation.
*   **FEAT**: Updated `CRDTEngine.computeMerkleTree` to **include deleted items** (tombstones) in the state hash, ensuring absolute consistency between client and server.
*   **FIX**: Implemented **deterministic JSON encoding** (sorted keys) for all protocol model hashes to prevent root mismatches across different platforms.

## 2.0.0

*   **FEAT**: Improved Merkle Tree implementation with time-based bucketing (Hour/Day prefixes) and prefix-based traversal support.
*   **FEAT**: Added `computeMerkleTree` to `CRDTEngine` for deterministic synchronization of tasks, resources, and dependencies.
*   **FEAT**: Added `lastUpdated` (Hlc) to `ProtocolResource`.
*   **BREAKING CHANGE**: Updated `GanttSyncClient.syncWithMerkle` signature to require a `MerkleTree` object.
*   **BREAKING CHANGE**: Migrated `ProtocolDependency.lastUpdated` from `int` to `Hlc` for improved conflict resolution.
*   **FIX**: Improved JSON deserialization for `lastUpdated` fields to support both String and Integer formats for backward compatibility.

## 1.0.6

* **FIX**: Redo fix SDK version

## 1.0.5

* **FIX**: Fix SDK version compatibility.

## 1.0.4

* **DOCS**: Added 100% dartdoc coverage to public APIs.

## 1.0.3

* **CHORE**: Fix lint.

## 1.0.2

* **CHORE**: Fix lint.

## 1.0.1

- **CHORE**: Format code using `dart format`.

## 1.0.0

- **Initial Stable Release** of the Gantt-Sync Protocol.
- **Hybrid Logical Clocks (HLC)**: Industry-standard causality tracking with millisecond precision and drift handling.
- **CRDT Engine**: Field-level Last-Write-Wins (LWW) conflict resolution for Tasks, Dependencies, and Resources.
- **Merkle Tree integrity**: SHA-256 state hashing for instant consistency verification.
- **Immutable Snapshots**: "Tagging" system to freeze state for regulatory compliance (`CREATE_TAG`).
- **Reference Server**: Included minimal Go implementation (`reference_server_go/`) validating HLCs and WebSockets.
- **Wire Specification**: Full JSON schema for Operations and Data Models (`SPEC.md`).
- **Forward Compatibility**: Versioned Operation schema (`schemaVersion`) for long-term API stability.
