package protocol

import "encoding/json"

// OperationType constants
const (
	OpInsertTask  = "INSERT_TASK"
	OpUpdateTask  = "UPDATE_TASK"
	OpDeleteTask  = "DELETE_TASK"
	OpBatchUpdate = "BATCH_UPDATE"
	OpCreateTag   = "CREATE_TAG"
	OpDeleteTag   = "DELETE_TAG"
)

// Operation represents a causal event in the system.
type Operation struct {
	Type          string          `json:"type"`
	SchemaVersion int             `json:"schemaVersion,omitempty"` // Defaults to 1 if omitted
	Timestamp     string          `json:"timestamp"` // HLC String
	ActorID       string          `json:"actorId"`
	Data          json.RawMessage `json:"data"` // Flexible payload
}

// ProtocolTask represents the task data model.
type ProtocolTask struct {
	ID        string `json:"id"`
	RowID     string `json:"rowId"`
	Start     string `json:"start"` // ISO-8601
	End       string `json:"end"`   // ISO-8601
	Name      string `json:"name,omitempty"`
	IsDeleted bool   `json:"isDeleted"`
	// ... other fields as needed for validation logic
}

// ProtocolTag represents an immutable snapshot.
type ProtocolTag struct {
	ID         string `json:"id"`
	Name       string `json:"name"`
	MerkleRoot string `json:"merkleRoot"`
	Timestamp  string `json:"timestamp"`
	IsDeleted  bool   `json:"isDeleted"`
}
