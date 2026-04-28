PYTHON := python3
VENV := backend/.venv
PIP := $(VENV)/bin/pip
UVICORN := $(VENV)/bin/uvicorn

OLLAMA_MODEL := llama3.2
BACKEND_APP := app.main:app

.PHONY: setup venv install-deps install-ollama pull-llm qdrant ingest run stop clean

setup: venv install-deps install-ollama pull-llm qdrant ingest
	@echo "Setup complete."

venv:
	test -d $(VENV) || $(PYTHON) -m venv $(VENV)

install-deps: venv
	$(PIP) install --upgrade pip
	$(PIP) install -r backend/requirements.txt

install-ollama:
	@if ! command -v ollama >/dev/null 2>&1; then \
		curl -fsSL https://ollama.com/install.sh | sh; \
	else \
		echo "Ollama already installed."; \
	fi

pull-llm:
	ollama pull $(OLLAMA_MODEL)

qdrant:
	docker compose up -d qdrant

ingest:
	cd backend && .venv/bin/python -m app.scripts.ingest_sample

run:
	cd backend && ../$(UVICORN) $(BACKEND_APP) --reload

stop:
	docker compose down

clean:
	rm -rf $(VENV)