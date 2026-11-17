# AI Agent Instructions for `legacy_gantt_protocol`

This directory contains the **open-source Gantt-Sync Protocol** — the language-agnostic wire format, CRDT merge rules, and Dart reference implementation that underpins the entire monorepo's synchronization layer.

## 1. Licensing and Protocol Boundary

The entire ecosystem, including the Dart/Shelf production server and Rust solver, is MIT-licensed. Independently published packages retain their own LICENSE files. `SPEC.md` and `proto/gantt_protocol.proto` define the public protocol contract; production server internals do not extend that contract implicitly.

## 2. HLC Timestamp Format (Canonical Definition)

The **canonical HLC format for this entire monorepo** is defined in `SPEC.md §1.1`:

```
<ISO-8601-Time>-<Counter-Hex>-<NodeId>
```

- **ISO-8601-Time**: UTC timestamp with millisecond precision (e.g., `2023-10-27T10:00:00.123Z`)
- **Counter-Hex**: 4-digit hexadecimal counter (e.g., `0000`, `000A`, `FFFF`) — disambiguates events within the same millisecond
- **NodeId**: String identifier for the originating node/device; avoid dashes where possible, but parsers must tolerate them

**Example**: `2023-10-27T10:00:00.123Z-000A-deviceA`

If any other file in the monorepo (another `AGENTS.md`, `ARCHITECTURE.md`, etc.) describes the HLC format differently, **this definition takes precedence**. Raise the discrepancy rather than silently adopting an alternative format.

## 3. `SUBSCRIBE_SUCCESS` Invariant

> [!IMPORTANT]
> The `SUBSCRIBE_SUCCESS` response message **MUST NOT** include `timestamp` or `actorId` fields. This is a hard protocol invariant defined in `SPEC.md §5.1`.

```json
// CORRECT
{ "type": "SUBSCRIBE_SUCCESS", "channel": "tenant-123" }

// WRONG — do not add timestamp or actorId
{ "type": "SUBSCRIBE_SUCCESS", "channel": "tenant-123", "timestamp": "...", "actorId": "server" }
```

**Why this matters**: Clients distinguish control messages from CRDT operations by the absence of `timestamp`/`actorId`. Including these fields causes clients to attempt to merge `SUBSCRIBE_SUCCESS` as a data operation, corrupting local state.

This invariant applies to **all** server implementations — the Go reference server and the production Dart server alike.

## 4. `reference_server_go/` Directory

`legacy_gantt_protocol/reference_server_go/` is a minimal, **in-memory** Go server that exists solely for protocol compliance testing and developer onboarding. It is **not** a production server.

**What it provides:**
- `ws://localhost:8080/` — WebSocket sync endpoint implementing the full `SPEC.md §5` handshake
- `POST /auth/login` — mock authentication that accepts any credentials and returns a test JWT
- `POST /validate-op` — validates a single `Operation` JSON object against the protocol schema

**What it does NOT provide:**
- Persistence (all state is lost on restart)
- Multi-tenancy or RLS
- Redis pub/sub or horizontal scaling
- The Merkle Tree integrity check flow

Use this server to verify that a new client implementation speaks the protocol correctly before pointing it at the production server. Run it with:

```bash
cd legacy_gantt_protocol/reference_server_go
go run cmd/server/main.go
```

## 5. Proto Files

`proto/gantt_protocol.proto` is the **canonical Protobuf schema** for all data models (`ProtocolTask`, `ProtocolDependency`, `ProtocolResource`, `ProtocolMessage`, etc.). It is MIT-licensed and public.

The production Dart server and the Rust solver (`../gantt_solver_rs/`) both consume generated code derived from this schema. If you modify the `.proto` file, regenerate bindings in all consumers before testing.

## 6. Consistency Rules

- Do not modify `SPEC.md` operation schemas without updating `proto/gantt_protocol.proto` to match, and vice versa.
- The `README.md` and `SPEC.md` must remain consistent: every operation type, data model, and HLC format described in one must appear in the other. The property test in `test/docs/structural_properties_test.dart` (Property 11) enforces this.
- Do not add `timestamp` or `actorId` to `SUBSCRIBE_SUCCESS` in any server implementation.
