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

The synchronization stream consists of an ordered sequence of logical **Operations**, shown below in decoded JSON form. Production WebSocket frames encode them as Protobuf messages (see §5).

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

---

## 5. Transport Protocol (WebSocket)

The production Dart server and Flutter client exchange **binary WebSocket frames** containing `ProtocolMessage` from [`proto/gantt_protocol.proto`](proto/gantt_protocol.proto). JSON blocks in this document show the logical decoded messages, not text frames to send directly to the production server.

Use `ProtobufMapper.toProtobuf(message).writeToBuffer()` to encode logical operations and `ProtobufMapper.toJson(ProtocolMessage.fromBuffer(bytes))` to decode them. Generated task dates and HLC values are strings, dependency lag is an integer millisecond duration, and extensible metadata is carried in `metadataJson`. Domain models convert these values at their boundaries. Batch task/resource deletes set `isDeleted`; each entry retains its own HLC.

The minimal Go reference server retains a JSON text transport for logical protocol testing. It is not a drop-in transport peer for the binary production client. Clients targeting the production server must generate bindings from the schema above.

The wire schema has no `schemaVersion` field; the logical operation version remains an application concern.

### 5.1 Connection Handshake

1.  **Connect**: Client connects to the WebSocket endpoint (e.g., `ws://server/`).
2.  **Subscribe**: Client sends a subscription message to join a specific channel (tenant/project).

```json
{
  "type": "subscribe",
  "channel": "tenant-123"
}
```

3.  **Confirmation**: Server responds with `SUBSCRIBE_SUCCESS`.
    *   **CRITICAL**: This response MUST NOT include `timestamp` or `actorId` fields. The presence of these fields causes clients to interpret the message as a CRDT operation rather than a control message.

```json
{
  "type": "SUBSCRIBE_SUCCESS",
  "channel": "tenant-123"
}
```

### 5.2 Control Messages

*   **GET_MERKLE_ROOT**: Client requests the current server-side Merkle Root.

```json
{ "type": "GET_MERKLE_ROOT" }
```

*   **MERKLE_ROOT**: Server response containing the root hash.

```json
{
  "type": "MERKLE_ROOT",
  "data": {
    "root": "hash-abc-123"
  },
  "timestamp": "...", 
  "actorId": "server"
}
```


### Version 4 CRDT merge semantics

Tasks use per-field hybrid logical clocks and a separate `isDeleted` presence register in `fieldTimestamps`. A live write advances its presence clock to its operation clock. A deletion advances only the presence register; deletion wins an equal presence clock. Historical fields continue to merge while a task remains deleted. Full snapshots preserve field clocks so replay does not promote unchanged fields to the envelope clock. A `DELETE_TASK` payload with nonempty `fieldTimestamps` is a full tombstone snapshot; a deletion without field clocks is an identity-only presence command, so default Protobuf scalar values cannot erase existing task history. Legacy snapshot producers must materialize baseline field clocks before replay.

Resources are complete last-write-wins records. Every live write supplies its complete fields and metadata. Omitted properties use protocol defaults rather than inheriting an earlier record. Resource deletion produces a minimal tombstone: its ID, empty name and parent, `person` type, `isDeleted: true`, empty metadata, and deletion HLC. Dependency tombstones contain the predecessor and successor IDs, `DELETE` type, zero lag, and deletion HLC. These minimal tombstones make deletion independent of prior delivery order; applications that need historical resource metadata or lag must store that history separately.

A data reset registers deletion presence at its HLC. A task edited after the reset can remain live, while historical task fields still merge against their individual clocks. If an older task arrives after the reset, consumers first register a virtual tombstone at the reset HLC for its ID, then merge the historical fields without resurrecting it. Resources and dependencies arriving at or before a reset remain minimal reset tombstones. Clients and servers must apply the same rules before hashing canonical state.


Version 4 task Merkle hashes cover both canonical values and per-field causal clocks. Missing legacy clocks expand to the task's entity clock (or the zero clock for an unclocked task) for every known core field and normalized metadata field. Explicit clocks, including custom metadata clocks, take precedence and use canonical HLC encodings. The UI-only clock keys `startIsUtc`, `endIsUtc`, `baselineStartIsUtc`, `baselineEndIsUtc`, `segments`, and `hasCellBuilder` are excluded, matching their normalized display-only values. Actor identity is excluded.

Full task snapshots carry complete metadata defaults and causal field clocks so that replay preserves future merge behavior. Existing local metadata values, including UTC display flags, override filled defaults. Merkle recovery must merge local canonical records into the server before pulling the merged server state; a pull-only repair cannot recover a locally accepted register that the server never received. An existing envelope `channel` value correlates `GET_MERKLE_ROOT` requests and responses; unsolicited root broadcasts have no correlation channel. On a single WebSocket, a correlated root response is sent only after preceding repair operations have committed. This adds no Protobuf fields or operation types.


Entity clocks participate in task, resource, and dependency hashes even when values are unchanged within the same minute bucket. Project reset control participates as a synthetic Merkle entry: its key is the canonical reset HLC and its value is SHA-256 of `RESET_DATA:<canonical reset HLC>`. The optional `resetTimestamp` argument to `CRDTEngine.computeMerkleTree` and `computeMerkleRoot` supplies this control state; `CRDTEngine.resetMerkleEntry` exposes the shared entry encoding.

Range recovery uses a unique existing envelope `channel` correlation value on `GET_ENTITIES_IN_RANGE`. The server sends a matching reset control operation as a standalone `RESET_DATA` before the entity response, then exactly one `BATCH_UPDATE` with the request correlation channel, including an empty batch when necessary. The batch signals that the requested range has completed; unrelated broadcasts do not complete recovery. Legacy requests without a correlation channel retain their range-prefix response channel.
