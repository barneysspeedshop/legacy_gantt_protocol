# Gantt-Sync Reference Server (Go)

This is a minimal **Reference Implementation** of the Gantt-Sync Protocol v1.0.

It serves as a playground for developers to understand:
1.  **HLC Validation**: How to parse and verify Hybrid Logical Clock timestamps (See SPEC Section 1).
2.  **WebSocket Protocol**: How to implement the handshake and real-time syncing (See SPEC Section 5).
3.  **Operation Handling**: How to broadcast CRDT operations to connected clients.

> **WARNING**: This server stores state **in-memory only**. It is intended for testing compliance and prototyping, not for production use.

## Features

*   **WebSocket Sync (`/`)**: Full real-time synchronization support.
*   **Mock Authentication (`/auth/login`)**: Returns valid JWTs for testing.
*   **Validation API (`/validate-op`)**: Endpoint to test specific operations against the schema.
*   **Broadcasting**: Automatically relays operations to all other connected clients.

## Prerequisites

*   Go 1.21 or higher

## Running the Server

1.  Navigate to this directory:
    ```bash
    cd legacy_gantt_protocol/reference_server_go
    ```

2.  Run the server:
    ```bash
    go run cmd/server/main.go
    ```

The server will start on port `8080`.

## Connecting a Client

This server is fully compatible with the `legacy_gantt_chart` example app.

1.  Open the Example App.
2.  Go to **Server Sync** settings.
3.  **Server URI**: `ws://localhost:8080/`
4.  **Credentials**: Enter any username/password (Mock Auth accepts anything).
5.  **Connect**: You should see the status change to "Connected" and your operations will sync.

## Endpoints

### 1. WebSocket Sync
*   **URL**: `ws://localhost:8080/`
*   **Protocol**: See `SPEC.md`. Handles `subscribe`, `BATCH_UPDATE`, etc.

### 2. Mock Authentication
*   **URL**: `POST /auth/login`
*   **Body**: `{"username": "...", "password": "..."}`
*   **Response**: `{"accessToken": "mock-jwt-token-..."}`

### 3. Validate Operation
*   **URL**: `POST /validate-op`
*   **Body**: JSON `Operation` object.

```bash
curl -X POST http://localhost:8080/validate-op \
  -d '{
    "type": "UPDATE_TASK",
    "timestamp": "2023-11-01T12:00:00.000Z-0000-userA",
    "actorId": "userA",
    "data": { "id": "task-1", "name": "New Name" }
  }'
```
