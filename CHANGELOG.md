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
