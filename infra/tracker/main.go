package main

import (
	"bytes"
	"encoding/json"
	"io"
	"log"
	"net/http"
	"os"
)

const (
	allowedType = "offon.challenge"
	dtAPIPath   = "/api/v2/bizevents/ingest"
)

var validActions = map[string]bool{
	"container.created":      true,
	"container.initialized":  true,
	"verification.completed": true,
}

type bizEvent struct {
	Type            string   `json:"type"`
	Action          string   `json:"action"`
	AdventureName   string   `json:"adventure.name"`
	AdventureNumber string   `json:"adventure.number"`
	AdventureMonth  string   `json:"adventure.month"`
	AdventureYear   string   `json:"adventure.year"`
	AdventureLevel  string   `json:"adventure.level"`
	SessionID       string   `json:"session.id"`
	GithubUsername  string   `json:"github.username,omitempty"`
	GithubRepo      string   `json:"github.repository,omitempty"`
	Status          string   `json:"verification.status,omitempty"`
	FailedChecks    []string `json:"verification.failed_checks,omitempty"`
}

func (e *bizEvent) validate() string {
	if e.Type != allowedType {
		return "type must be " + allowedType
	}
	if !validActions[e.Action] {
		return "unknown action: " + e.Action
	}
	if e.AdventureName == "" {
		return "adventure.name is required"
	}
	if e.AdventureLevel == "" {
		return "adventure.level is required"
	}
	if e.SessionID == "" {
		return "session.id is required"
	}
	if e.AdventureNumber == "" {
		return "adventure.number is required"
	}
	if e.AdventureMonth == "" {
		return "adventure.month is required"
	}
	if e.AdventureYear == "" {
		return "adventure.year is required"
	}
	if e.Action == "verification.completed" && e.Status == "" {
		return "verification.status is required for verification.completed"
	}
	return ""
}

func handler(dtURL, dtToken string) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
			return
		}

		body, err := io.ReadAll(r.Body)
		if err != nil {
			http.Error(w, "failed to read body", http.StatusBadRequest)
			return
		}

		var event bizEvent
		if err := json.Unmarshal(body, &event); err != nil {
			http.Error(w, "invalid JSON", http.StatusBadRequest)
			return
		}

		if msg := event.validate(); msg != "" {
			http.Error(w, msg, http.StatusBadRequest)
			return
		}

		req, err := http.NewRequestWithContext(r.Context(), http.MethodPost, dtURL+dtAPIPath, bytes.NewReader(body))
		if err != nil {
			http.Error(w, "internal error", http.StatusInternalServerError)
			return
		}
		req.Header.Set("Authorization", "Api-Token "+dtToken)
		req.Header.Set("Content-Type", "application/json")

		resp, err := http.DefaultClient.Do(req)
		if err != nil {
			log.Printf("dynatrace ingest error: %v", err)
			http.Error(w, "failed to forward event", http.StatusBadGateway)
			return
		}
		defer resp.Body.Close()

		if resp.StatusCode >= 400 {
			respBody, _ := io.ReadAll(resp.Body)
			log.Printf("dynatrace returned %d: %s", resp.StatusCode, respBody)
			http.Error(w, "dynatrace ingest failed", http.StatusBadGateway)
			return
		}

		w.WriteHeader(http.StatusNoContent)
	}
}

func main() {
	dtURL := os.Getenv("DT_TENANT_URL")
	dtToken := os.Getenv("DT_API_TOKEN")
	if dtURL == "" || dtToken == "" {
		log.Fatal("DT_TENANT_URL and DT_API_TOKEN must be set")
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	http.HandleFunc("/", handler(dtURL, dtToken))
	log.Printf("listening on :%s", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}
