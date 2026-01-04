package hlc

import (
	"fmt"
	"regexp"
	"strconv"
	"strings"
	"time"
)

// HLC represents a Hybrid Logical Clock timestamp.
type HLC struct {
	Millis  int64
	Counter int
	NodeID  string
}

// Zero returns the epoch HLC.
func Zero() HLC {
	return HLC{Millis: 0, Counter: 0, NodeID: ""}
}

// Parse validates and parses an HLC string according to the SPEC.
// Format: <ISO-8601-Time>-<Counter-Hex>-<NodeId>
// Example: 2023-10-27T10:00:00.123Z-0000-deviceA
func Parse(s string) (HLC, error) {
	// Simple regex for the standard structure
	// Group 1: ISO time
	// Group 2: Counter
	// Group 3: NodeID
	re := regexp.MustCompile(`^(.+)-([0-9a-fA-F]{4})-(.+)$`)
	matches := re.FindStringSubmatch(s)

	if matches == nil {
		// Fallback/Legacy parsing could go here if needed, but SPEC demands standard format for v1.
		return Zero(), fmt.Errorf("invalid HLC format: %s", s)
	}

	isoTime := matches[1]
	counterHex := matches[2]
	nodeID := matches[3]

	// Parse Time
	t, err := time.Parse(time.RFC3339, isoTime)
	// Try parsing without Z if it fails, or flexible parsing logic
	if err != nil {
		// Try adding Z if missing
		if !strings.HasSuffix(isoTime, "Z") {
			t, err = time.Parse(time.RFC3339, isoTime+"Z")
		}
	}
	if err != nil {
		return Zero(), fmt.Errorf("invalid time component: %v", err)
	}

	// Parse Counter
	counter, err := strconv.ParseInt(counterHex, 16, 64)
	if err != nil {
		return Zero(), fmt.Errorf("invalid counter component: %v", err)
	}

	return HLC{
		Millis:  t.UnixMilli(),
		Counter: int(counter),
		NodeID:  nodeID,
	}, nil
}

// String returns the canonical string representation.
func (h HLC) String() string {
	t := time.UnixMilli(h.Millis).UTC()
	iso := t.Format("2006-01-02T15:04:05.000Z")
	counterHex := fmt.Sprintf("%04X", h.Counter)
	return fmt.Sprintf("%s-%s-%s", iso, counterHex, h.NodeID)
}

// Compare returns -1 if h < other, 1 if h > other, 0 if equal.
func (h HLC) Compare(other HLC) int {
	if h.Millis < other.Millis {
		return -1
	}
	if h.Millis > other.Millis {
		return 1
	}
	if h.Counter < other.Counter {
		return -1
	}
	if h.Counter > other.Counter {
		return 1
	}
	if h.NodeID < other.NodeID {
		return -1
	}
	if h.NodeID > other.NodeID {
		return 1
	}
	return 0
}
