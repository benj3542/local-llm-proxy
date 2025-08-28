# ---- Config ----
MODEL_NAME ?= $(shell grep -E '^MODEL_NAME=' .env 2>/dev/null | cut -d= -f2 | tr -d '[:space:]' || echo phi3:mini)
PROXY_PORT ?= $(shell grep -E '^PROXY_PORT=' .env 2>/dev/null | cut -d= -f2 | tr -d '[:space:]' || echo 4000)
OLLAMA_PORT ?= $(shell grep -E '^OLLAMA_PORT=' .env 2>/dev/null | cut -d= -f2 | tr -d '[:space:]' || echo 11434)

# ---- Targets ----
.PHONY: up down restart logs models test clean pull-model

up:
	@echo "Starting with MODEL_NAME=$(MODEL_NAME)"
	docker compose up -d
	@echo "Pulling model via helper..."
	docker compose run --rm puller || true
	@echo "Proxy ready on http://localhost:$(PROXY_PORT)/v1"

down:
	docker compose down

restart: down up

logs:
	docker compose logs -f

models:
	curl -sS http://localhost:$(PROXY_PORT)/v1/models | jq . || curl -sS http://localhost:$(PROXY_PORT)/v1/models

test:
	curl -sS http://localhost:$(PROXY_PORT)/v1/chat/completions \
	  -H "Content-Type: application/json" \
	  -d '{"model":"ollama/$(MODEL_NAME)","messages":[{"role":"user","content":"Say hi"}]}' | jq . || true

pull-model:
	docker compose run --rm -e MODEL_NAME=$(MODEL_NAME) puller

clean:
	docker compose down -v
