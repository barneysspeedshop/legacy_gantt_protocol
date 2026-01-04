# Gantt-Sync: The Causal Standard for Project Data

**Gantt-Sync** is an industry-standard specification and reference implementation for **decentralized, causal, and immutable project management data**.

While this specific package (`legacy_gantt_protocol`) serves as the reference implementation in Dart, the **Gantt-Sync Protocol** is language-agnostic. It provides the mathematical and logical foundation for building "unbreakable" project management tools that work offline, peer-to-peer, or with any backend (Postgres, SQLite, Firebase, flat files).

---

## Why Gantt-Sync?

Project management data is inherently complex and hierarchical. Traditional "Last-Write-Wins" strategies at a row level destroy user intent ("The Git of Project Management"). Gantt-Sync solves this by treating every field change as a causal event.

*   **Backend Agnostic**: The protocol operates on a stream of JSON `Operations`. It does not care if your database is SQLite, MongoDB, or a JSON file on S3.
*   **Language Portable**: The schemas (Operations, HLC timestamps, Merkle Trees) are simple JSON structures. A client can be written in Rust, Go, Python, or TypeScript and fully participate in the synchronization cluster.
*   **Audit-Grade Immutability**: All state changes are tied to a Hybrid Logical Clock (HLC). By hashing the Merkle Roots of the state, organizations can create "Baseline Snapshots" that are legally and technically verifiable representations of the project at any point in time.
*   **Offline-First by Design**: The "Hybrid Sovereignty" engine assumes network partitions are the norm, not the exception.

---

## Hybrid Sovereignty: Solving "Silent Corruption"

Most collaboration tools overwrite entire records when a user saves. If User A changes the **Start Date** and User B changes the **Task Name** at the exact same second, one of them usually loses their work.

Gantt-Sync employs a **Hybrid Sovereignty CRDT Engine**:

1.  **Field-Level LWW (Last-Write-Wins)**: Every property (name, start, end) acts as its own independent register.
2.  **Add-Wins Existence**: Validates task existence via Tombstones.

### Conflict Resolution Example

Imagine two users editing the same task simultaneously offline, then syncing:

| User | Action | Field | Timestamp (HLC) | Result |
| :--- | :--- | :--- | :--- | :--- |
| **Alice** | Renames to "Fix Bug" | `name` | `12:00:01-001` | **Accepted** (Latest `name`) |
| **Bob** | Moves to "Oct 5" | `start_date` | `12:00:01-002` | **Accepted** (Latest `start_date`) |
| **Bob** | Renames to "Bug Fix" | `name` | `12:00:00-999` | **Rejected** (Older than Alice's edit) |

**Result**: The task becomes **"Fix Bug"** starting on **"Oct 5"**. Both intentions are preserved mathematically.

---

## Core Components

### 1. The HLC (Hybrid Logical Clock)
Standard wall clocks cannot be trusted in distributed systems. The HLC combines physical time with a logical counter to guarantee a strict ordering of events (`timestamp > last_seen_timestamp`), even if a device's system clock drifts.

### 2. The Operation Log
The "Source of Truth" is not the current state, but the log of operations.
```json
{
  "type": "UPDATE_TASK",
  "data": {
    "id": "task-88a",
    "name": "Refactor CRDT", 
    "notes": "Critical fix"
  },
  "timestamp": "2024-10-05T14:30:00.001Z-0000",
  "actorId": "dev-alice"
}
```

### 3. Merkle Trees for Delta Sync
To avoid sending the entire database over the wire, Gantt-Sync uses Merkle Trees. Clients compare their root hash with the server. If they match, they are in sync. If not, they exchange branch hashes to identify *exactly* which tasks differ, reducing bandwidth by 99% for large projects.

---

## Implementation Checklist (Minimum Viable Implementation)

To build a compatible client (e.g., a **Python data-science script**, **Rust CLI**, or **generic web dashboard**) that interacts with a Gantt-Sync cluster, you must implement these three pillars:

### 1. Causality (The Clock)
*   [ ] **HLC Implementation**: Must generate timestamps that are monotonically increasing.
*   [ ] **Receive Logic**: When receiving a message, update the local clock: `local_hlc = max(local_hlc, msg_hlc)`.

### 2. Convergence (The Merge)
*   [ ] **CRDT Engine**: Implement the merge logic.
*   [ ] **Tombstones**: Never delete data physically; mark `isDeleted: true`.
*   [ ] **Field Granularity**: Ensure `UPDATE` operations only modify the specific fields present in the payload.

### 3. Integrity (The Hash)
*   [ ] **Content Hashing**: Deterministically hash task content (JSON keys sorted alphabetically).
*   [ ] **Merkle Root**: Build the tree from all active task/resource hashes.

---

## Usage (Reference Implementation)

This package implements the protocol for the Dart/Flutter ecosystem.

### Merging Operations 

```dart
final engine = CRDTEngine();

// 1. Load local state
List<ProtocolTask> localState = database.loadTasks();

// 2. Buffer incoming JSON operations (from WebSocket, File, etc.)
List<Operation> remoteOps = buffer.read();

// 3. Merge to get the mathematically correct new state
List<ProtocolTask> convergedState = engine.mergeTasks(localState, remoteOps);

// 4. Update UI
```

### Generating an Operation

```dart
// Create a causal timestamp
final hlc = Hlc.now(); 

final op = Operation(
  type: 'UPDATE_TASK',
  timestamp: hlc,
  actorId: 'user-portable-id',
  data: {
    'id': 'task-abc',
    'completion': 100.0, // Floating point precision
  },
);

// Serialize to JSON and send to any Gantt-Sync compliant peer
transport.send(op.toJson());
```

---

## Moat & Ecosystem

By adopting the **Gantt-Sync Standard**, you are not just using a library; you are adopting a data architecture that guarantees:
1.  **Offline Resilience**: Work continues when the internet breaks.
2.  **Data Ownership**: The data format is open, human-readable, and fundamentally portable.
3.  **Future Proofing**: The protocol allows for infinite extension via the `metadata` field, which is also CRDT-merged.
