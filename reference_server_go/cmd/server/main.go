package main

// Gantt-Sync Reference Server (Go)
//
// This is a minimal, in-memory reference implementation of the Gantt-Sync Protocol v1.0.
// It demonstrates:
// 1. HLC (Hybrid Logical Clock) Validation (See SPEC.md Section 1)
// 2. WebSocket Handshake and Protocol (See SPEC.md Section 5)
// 3. Operation Verification and Broadcasting
//
// WARNING: This server stores state in memory only, and offers no security (any user can login with any password).
// It is intended for testing, prototyping, and verifying client compliance. Do not use in production.

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"sync"

	"github.com/barneysspeedshop/legacy_gantt_protocol/reference_server_go/internal/hlc"
	"github.com/barneysspeedshop/legacy_gantt_protocol/reference_server_go/internal/protocol"
	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true // Allow all origins for reference server
	},
}

// Hub maintains the set of active clients and broadcasts messages to the
// clients.
type Hub struct {
	clients    map[*websocket.Conn]bool
	broadcast  chan []byte
	register   chan *websocket.Conn
	unregister chan *websocket.Conn
	mutex      sync.Mutex
}

func newHub() *Hub {
	return &Hub{
		clients:    make(map[*websocket.Conn]bool),
		broadcast:  make(chan []byte),
		register:   make(chan *websocket.Conn),
		unregister: make(chan *websocket.Conn),
	}
}

func (h *Hub) run() {
	for {
		select {
		case conn := <-h.register:
			h.mutex.Lock()
			h.clients[conn] = true
			h.mutex.Unlock()
		case conn := <-h.unregister:
			h.mutex.Lock()
			if _, ok := h.clients[conn]; ok {
				delete(h.clients, conn)
				conn.Close()
			}
			h.mutex.Unlock()
		case message := <-h.broadcast:
			h.mutex.Lock()
			for conn := range h.clients {
				err := conn.WriteMessage(websocket.TextMessage, message)
				if err != nil {
					conn.Close()
					delete(h.clients, conn)
				}
			}
			h.mutex.Unlock()
		}
	}
}

var hub = newHub()

func main() {
	go hub.run()

	http.HandleFunc("/", handleRoot)
	http.HandleFunc("/auth/login", handleLogin)
	http.HandleFunc("/validate-op", handleValidateOp)

	fmt.Println("Gantt-Sync Reference Server (Go) listening on :8080")
	fmt.Println(" - POST /auth/login (returns mock token)")
	fmt.Println(" - WS   / (sync functionality)")
	fmt.Println(" - POST /validate-op (validation only)")
	log.Fatal(http.ListenAndServe(":8080", nil))
}

func handleRoot(w http.ResponseWriter, r *http.Request) {
	// Upgrade to WebSocket if requested
	if r.Header.Get("Upgrade") == "websocket" {
		handleWebSocket(w, r)
		return
	}

	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("Gantt-Sync Reference Server\n\nEndpoints:\n - POST /auth/login\n - WS /\n - POST /validate-op\n"))
}

func handleLogin(w http.ResponseWriter, r *http.Request) {
	// Mock login: Accept any credentials and return a dummy token
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{
		"accessToken": "mock-jwt-token-12345",
	})
}

func handleWebSocket(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println("Upgrade error:", err)
		return
	}

	hub.register <- conn

	defer func() {
		hub.unregister <- conn
	}()

	for {
		_, message, err := conn.ReadMessage()
		if err != nil {
			log.Println("Read error:", err)
			break
		}

		var envelope map[string]interface{}
		if err := json.Unmarshal(message, &envelope); err != nil {
			log.Println("JSON error:", err)
			continue
		}

		msgType, _ := envelope["type"].(string)

		switch msgType {
		case "subscribe":
			// Reply with SUBSCRIBE_SUCCESS
			// Note: Timestamp and ActorID are intentionally omitted to indicate
			// a control message rather than a data operation.
			response := map[string]string{
				"type":    "SUBSCRIBE_SUCCESS",
				"channel": envelope["channel"].(string),
			}
			jsonResponse, _ := json.Marshal(response)
			conn.WriteMessage(websocket.TextMessage, jsonResponse)

		case "GET_MERKLE_ROOT":
			// Reply with a dummy root for this reference implementation
			response := map[string]interface{}{
				"type": "MERKLE_ROOT",
				"data": map[string]string{
					"root": "hash-empty-tree",
				},
				"timestamp": hlc.Zero().String(),
				"actorId":   "server",
			}
			jsonResponse, _ := json.Marshal(response)
			conn.WriteMessage(websocket.TextMessage, jsonResponse)

		case "BATCH_UPDATE", "INSERT_TASK", "UPDATE_TASK", "DELETE_TASK", "CREATE_TAG", "DELETE_TAG":
			// Validate HLC format if present
			if ts, ok := envelope["timestamp"].(string); ok {
				if _, err := hlc.Parse(ts); err != nil {
					log.Println("Invalid HLC in stream:", ts)
					continue
				}
			}
			// Broadcast the operation to all connected clients
			hub.broadcast <- message

		case "PRESENCE_UPDATE", "CURSOR_MOVE", "GHOST_UPDATE":
			// Transient ephemeral messages; broadcast without validation or storage
			hub.broadcast <- message

		default:
			log.Printf("Unknown message type: %s\n", msgType)
		}
	}
}

func handleValidateOp(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	body, err := io.ReadAll(r.Body)
	if err != nil {
		http.Error(w, "Failed to read body", http.StatusBadRequest)
		return
	}
	defer r.Body.Close()

	var op protocol.Operation
	if err := json.Unmarshal(body, &op); err != nil {
		http.Error(w, fmt.Sprintf("JSON Decode Error: %v", err), http.StatusBadRequest)
		return
	}

	// 1. Validate Schema Version
	if op.SchemaVersion < 1 {
		op.SchemaVersion = 1
	}
	fmt.Printf("Validating Operation: %s (v%d)\n", op.Type, op.SchemaVersion)

	// 2. Validate Timestamp (HLC)
	parsedHlc, err := hlc.Parse(op.Timestamp)
	if err != nil {
		errMsg := fmt.Sprintf("Invalid HLC Timestamp: %s (%v)", op.Timestamp, err)
		fmt.Println("❌ " + errMsg)
		http.Error(w, errMsg, http.StatusBadRequest)
		return
	}
	fmt.Printf("✅ Timestamp Valid: %s (Millis: %d, Node: %s)\n", parsedHlc.String(), parsedHlc.Millis, parsedHlc.NodeID)

	// 3. Validate Payload based on Type
	switch op.Type {
	case protocol.OpInsertTask, protocol.OpUpdateTask:
		var task protocol.ProtocolTask
		if err := json.Unmarshal(op.Data, &task); err != nil {
			http.Error(w, "Invalid Task Data structure", http.StatusBadRequest)
			return
		}
		if task.ID == "" {
			http.Error(w, "Task ID is required", http.StatusBadRequest)
			return
		}
		fmt.Printf("✅ Task Payload Valid: %s\n", task.ID)

	case protocol.OpCreateTag:
		var tag protocol.ProtocolTag
		if err := json.Unmarshal(op.Data, &tag); err != nil {
			http.Error(w, "Invalid Tag Data structure", http.StatusBadRequest)
			return
		}
		if tag.MerkleRoot == "" {
			http.Error(w, "Tag MerkleRoot is required", http.StatusBadRequest)
			return
		}
		fmt.Printf("✅ Tag Payload Valid: %s (Root: %s)\n", tag.Name, tag.MerkleRoot)
	}

	w.WriteHeader(http.StatusOK)
	w.Write([]byte("Operation Valid"))
}
