# Gantt-Sync Protocol Specification (v1.0)

This document defines the wire format and data structures for the **Gantt-Sync Protocol**. It is intended for developers implementing a client or server in any language (Rust, Python, Go, TypeScript, etc.).

---

## 1. Hybrid Logical Clock (HLC)

The HLC is the backbone of the protocol's causality. All timestamps transmitted over the wire MUST adhere to this format.

### 1.1 String Format
The canonical string representation of an HLC timestamp is:

```
<ISO-8601-Time>-<Counter-Hex>-<NodeId>
```

*   **ISO-8601-Time**: UTC timestamp with millisecond precision (e.g., `2023-10-27T10:00:00.123Z`).
*   **Counter-Hex**: 4-digit hexadecimal counter (e.g., `0000`, `000A`, `FFFF`). Used to distinguish events occurring within the same millisecond.
*   **NodeId**: A standard string identifier for the node/device generating the timestamp. Should not contain dashes if possible, though parsers should handle it.

### 1.2 Examples
*   `2023-10-27T10:00:00.123Z-0000-deviceA`
*   `2023-10-27T10:00:00.123Z-0001-deviceA` (Same ms, subsequent event)

### 1.3 Comparison Logic
To compare two HLCs, `A` and `B`:
1.  Compare `ISO-8601-Time`. Higher value wins.
2.  If equal due to millisecond collision, compare `Counter-Hex`. Higher value wins.
3.  If equal, compare `NodeId` lexicographically (arbitrary tie-breaker).

---

## 2. Operation Log

The synchronization stream consists of an ordered sequence of JSON **Operations**.

### 2.1 Schema

```json
{
  "type": "string",       // The type of operation
  "schemaVersion": 1,     // Protocol version (default: 1)
  "timestamp": "string",  // HLC string (see 1.1)
  "actorId": "string",    // The ID of the user/system performing the action
  "data": {               // The payload (depends on type)
    ...
  }
}

```

### 2.2 Operation Types

#### `UPDATE_TASK` / `INSERT_TASK`
Upserts a task. Fields present in `data` will be merged; missing fields are ignored.

```json
{
  "type": "UPDATE_TASK",
  "data": {
    "id": "task-uuid-123",
    "name": "New Task Name",
    "completion": 0.5,
    "start": "2023-11-01T09:00:00.000Z"
  }
  // ... metadata fields ...
}
```

#### `DELETE_TASK`
Logically deletes a task.

```json
{
  "type": "DELETE_TASK",
  "data": {
    "id": "task-uuid-123"
  }
}
```

#### `BATCH_UPDATE`
Carries a list of operations to be applied atomically.

```json
{
  "type": "BATCH_UPDATE",
  "data": {
    "operations": [
      { "type": "INSERT_TASK", ... },
      { "type": "UPDATE_TASK", ... }
    ]
  }
}
```

#### `CREATE_TAG`
Creates an immutable snapshot of the current state.

```json
{
  "type": "CREATE_TAG",
  "data": {
    "id": "tag-uuid-123",
    "name": "Release 1.0",
    "merkleRoot": "hash-abc-123",
    "timestamp": "2023-11-01T09:00:00.000Z-0000-node",
    "metadata": {}
  }
}
```

#### `DELETE_TAG`
Deletes a tag.

```json
{
  "type": "DELETE_TAG",
  "data": {
    "id": "tag-uuid-123"
  }
}
```

---

## 3. Data Models

These models define the "data" payload within operations or the state snapshot.

### 3.1 ProtocolTask (`ProtocolTask`)

| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | String | Unique UUID. |
| `rowId` | String | Logic row identifier for UI. |
| `start` | ISO-8601 | Start time (UTC). |
| `end` | ISO-8601 | End time (UTC). |
| `name` | String | Task label. |
| `completion` | Double | Progress (0.0 to 1.0). |
| `isSummary` | Boolean | If true, computed from children. |
| `isMilestone` | Boolean | Zero-duration event. |
| `resourceId` | String? | ID of assigned resource. |
| `parentId` | String? | ID of parent task (for hierarchy). |
| `isDeleted` | Boolean | Tombstone flag. |
| `metadata` | Map | Flexible standard JSON map for extra fields. |

**Example:**
```json
{
  "id": "t1",
  "name": "Planning",
  "start": "2023-01-01T09:00:00.000Z",
  "end": "2023-01-05T17:00:00.000Z",
  "isDeleted": false,
  "metadata": {
    "color": "#FF0000"
  }
}
```

### 3.2 ProtocolDependency (`ProtocolDependency`)

| Field | Type | Description |
| :--- | :--- | :--- |
| `predecessorTaskId` | String | The task that comes first. |
| `successorTaskId` | String | The task that follows. |
| `type` | String | Enum: `finishToStart`, `startToStart`, `finishToFinish`, `startToFinish`. |
| `lag` | Int? | Lag in milliseconds (optional). |

**Example:**
```json
{
  "predecessorTaskId": "t1",
  "successorTaskId": "t2",
  "type": "finishToStart",
  "lag": 3600000 // 1 hour
}
```

### 3.3 ProtocolResource (`ProtocolResource`)

| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | String | Unique UUID. |
| `name` | String | Resource name (e.g., "Alice"). |
| `type` | String | "person", "machine", etc. |
### 3.4 ProtocolTag (`ProtocolTag`)

| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | String | Unique UUID. |
| `name` | String | Tag label (e.g., "Baseline Q1"). |
| `merkleRoot` | String | The Merkle Root of the state at the time of tagging. |
| `timestamp` | HLC | When the tag was created. |
| `actorId` | String? | Who created the tag. |
| `isDeleted` | Boolean | Tombstone flag. |
| `metadata` | Map | Extra fields. |



---

## 4. Merkle Tree & Integrity

To verify state consistency, clients compute a Merkle Root.

### 4.1 Content Hashing
The content hash of a Task/Resource/Dependency is the **SHA-256** hash of its deterministic JSON representation.
1.  Create a JSON object containing all relevant fields.
2.  **Sort keys alphabetically** to ensure deterministic serialization (canonical JSON).
3.  Compute SHA-256 of the UTF-8 bytes.

### 4.2 Merkle Root
1.  Collect all content hashes for active (non-deleted) items.
2.  Sort hashes alphabetically.
3.  Combine them into a Merkle Tree structure (implementation specific, but standard binary tree).
4.  The root hash is the "Version State".
