### COLORS ###
DEF_COLOR = \033[0;39m
GRAY = \033[0;90m
RED = \033[0;91m
GREEN = \033[0;92m
YELLOW = \033[0;93m
BLUE = \033[0;94m
MAGENTA = \033[0;95m
CYAN = \033[0;96m
WHITE = \033[0;97m

### VARIABLES ###
NAME = RAG2-D2
PYTHON = python3
VENV = backend/.venv
PIP = $(VENV)/bin/pip
UVICORN = $(VENV)/bin/uvicorn
OLLAMA_MODEL = llama3.2
BACKEND_APP = app.main:app
DOCKER_COMPOSE = docker compose
QDRANT_SERVICE = qdrant

### RULES ###

.PHONY: setup resume check-python check-docker venv install-deps install-ollama pull-llm qdrant ingest run stop clean fclean re status help

# Full project setup
setup: check-python venv install-deps install-ollama pull-llm qdrant ingest run
	@echo "$(GREEN)>>> $(NAME) setup completed successfully.$(DEF_COLOR)"
	@echo "$(CYAN)>>> You can now run the API with: make run$(DEF_COLOR)"

# Resume project setup after reboot to apply docker permissions
resume: qdrant ingest run
	@echo "$(GREEN)>>> $(NAME) setup completed successfully.$(DEF_COLOR)"
	@echo "$(CYAN)>>> You can now run the API with: make run$(DEF_COLOR)"

# Ensure Python is installed
check-python:
	@echo "$(YELLOW)>>> Checking Python packages...$(DEF_COLOR)"
	@if ! command -v python3 >/dev/null 2>&1; then \
		echo "$(CYAN)>>> Python3 not found. Installing...$(DEF_COLOR)"; \
		sudo apt update; \
		sudo apt install -y python3 python3-venv python3-pip; \
	else \
		echo "$(GREEN)>>> Python3 already installed.$(DEF_COLOR)"; \
	fi
	@tmp_venv=$$(mktemp -d); \
	if ! python3 -m venv "$$tmp_venv/test-venv" >/dev/null 2>&1; then \
		echo "$(CYAN)>>> Python venv support incomplete. Installing python3-venv...$(DEF_COLOR)"; \
		sudo apt update; \
		sudo apt install -y python3-venv python3-pip; \
	fi; \
	rm -rf "$$tmp_venv"

# Create Python virtual environment
venv: check-python
	@echo "$(YELLOW)>>> Checking Python virtual environment...$(DEF_COLOR)"
	@if [ ! -d "$(VENV)" ]; then \
		echo "$(CYAN)>>> Creating virtual environment in $(VENV)...$(DEF_COLOR)"; \
		rm -rf "$(VENV)"; \
		$(PYTHON) -m venv "$(VENV)" || { \
			echo "$(RED)>>> Failed to create virtual environment.$(DEF_COLOR)"; \
			rm -rf "$(VENV)"; \
			exit 1; \
		}; \
		echo "$(GREEN)>>> Virtual environment created.$(DEF_COLOR)"; \
	else \
		echo "$(GREEN)>>> Virtual environment already exists.$(DEF_COLOR)"; \
	fi

# Install Python dependencies
install-deps: venv
	@echo "$(YELLOW)>>> Installing backend Python dependencies...$(DEF_COLOR)"
	@$(PIP) install --upgrade pip
	@$(PIP) install -r backend/requirements.txt
	@echo "$(GREEN)>>> Python dependencies installed.$(DEF_COLOR)"

# Install Ollama if missing
install-ollama:
	@echo "$(YELLOW)>>> Checking Ollama installation...$(DEF_COLOR)"
	@if ! command -v ollama >/dev/null 2>&1; then \
		echo "$(CYAN)>>> Ollama not found. Installing Ollama...$(DEF_COLOR)"; \
		curl -fsSL https://ollama.com/install.sh | sh; \
		echo "$(GREEN)>>> Ollama installed.$(DEF_COLOR)"; \
	else \
		echo "$(GREEN)>>> Ollama already installed.$(DEF_COLOR)"; \
	fi

# Pull local LLM model
pull-llm:
	@echo "$(YELLOW)>>> Pulling Ollama model: $(OLLAMA_MODEL)...$(DEF_COLOR)"
	@ollama pull $(OLLAMA_MODEL)
	@echo "$(GREEN)>>> Model $(OLLAMA_MODEL) is available.$(DEF_COLOR)"

# Ensure Docker and Docker Compose are installed
check-docker:
	@echo "$(YELLOW)>>> Checking Docker installation...$(DEF_COLOR)"
	@if ! command -v docker >/dev/null 2>&1; then \
		echo "$(CYAN)>>> Docker not found. Installing Docker...$(DEF_COLOR)"; \
		sudo apt-get update; \
		sudo apt-get install -y ca-certificates curl; \
		sudo install -m 0755 -d /etc/apt/keyrings; \
		sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc; \
		sudo chmod a+r /etc/apt/keyrings/docker.asc; \
		echo "deb [arch=$$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $$(. /etc/os-release && echo "$${UBUNTU_CODENAME:-$$VERSION_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null; \
		sudo apt-get update; \
		sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; \
		sudo usermod -aG docker $$USER; \
		echo "$(GREEN)>>> Docker installed.$(DEF_COLOR)"; \
		echo "$(YELLOW)>>> Reboot your system for Docker permissions to apply, then continue installation with $(CYAN)make resume$(DEF_COLOR)"; \
	else \
		echo "$(GREEN)>>> Docker already installed.$(DEF_COLOR)"; \
	fi
	@if ! docker compose version >/dev/null 2>&1; then \
		echo "$(CYAN)>>> Docker Compose plugin missing. Installing...$(DEF_COLOR)"; \
		sudo apt-get update; \
		sudo apt-get install -y docker-compose-plugin; \
	fi
	@if ! command -v docker-compose >/dev/null 2>&1; then \
		echo "$(CYAN)>>> Legacy docker-compose command missing. Installing...$(DEF_COLOR)"; \
		sudo curl -L "https://github.com/docker/compose/releases/download/v2.34.0/docker-compose-$$(uname -s)-$$(uname -m)" -o /usr/local/bin/docker-compose; \
		sudo chmod +x /usr/local/bin/docker-compose; \
	fi
	@echo "$(GREEN)>>> Docker and Docker Compose are ready.$(DEF_COLOR)"

# Start Qdrant vector database
qdrant: check-docker
	@echo "$(YELLOW)>>> Starting Qdrant service...$(DEF_COLOR)"
	@$(DOCKER_COMPOSE) up -d $(QDRANT_SERVICE)
	@echo "$(GREEN)>>> Qdrant is running.$(DEF_COLOR)"

# Ingest sample data into vector database
ingest:
	@echo "$(YELLOW)>>> Running sample ingestion script...$(DEF_COLOR)"
	@cd backend && .venv/bin/python -m app.scripts.ingest_sample
	@echo "$(GREEN)>>> Sample data ingested successfully.$(DEF_COLOR)"

# Run FastAPI backend
run:
	@echo "$(YELLOW)>>> Starting FastAPI backend...$(DEF_COLOR)"
	@echo "$(CYAN)>>> App: $(BACKEND_APP)$(DEF_COLOR)"
	@cd backend && ../$(UVICORN) $(BACKEND_APP) --reload

# Show Docker services status
status:
	@echo "$(YELLOW)>>> Docker services status:$(DEF_COLOR)"
	@$(DOCKER_COMPOSE) ps

# Stop Docker services
stop:
	@echo "$(YELLOW)>>> Stopping Docker services...$(DEF_COLOR)"
	@$(DOCKER_COMPOSE) down
	@echo "$(GREEN)>>> Docker services stopped.$(DEF_COLOR)"

# Remove Python virtual environment
clean:
	@echo "$(YELLOW)>>> Removing Python virtual environment...$(DEF_COLOR)"
	@rm -rf $(VENV)
	@echo "$(GREEN)>>> Virtual environment removed.$(DEF_COLOR)"

# Full cleanup: Docker services + Python virtual environment
fclean: stop clean
	@echo "$(YELLOW)>>> Full cleanup completed.$(DEF_COLOR)"

# Rebuild local environment from scratch
re: fclean setup
	@echo "$(GREEN)>>> $(NAME) rebuilt successfully.$(DEF_COLOR)"

# Display available commands
help:
	@echo "$(CYAN)Available commands for $(NAME):$(DEF_COLOR)"
	@echo "$(WHITE)  make setup$(DEF_COLOR)          Create venv, install deps, install Ollama, pull model, start Qdrant, ingest data"
	@echo "$(WHITE)  make resume$(DEF_COLOR)         Resume project setup after reboot to apply docker permissions"
	@echo "$(WHITE)  make check-python$(DEF_COLOR)   Install python packages if missing"
	@echo "$(WHITE)  make venv$(DEF_COLOR)           Create Python virtual environment"
	@echo "$(WHITE)  make install-deps$(DEF_COLOR)   Install backend Python dependencies"
	@echo "$(WHITE)  make install-ollama$(DEF_COLOR) Install Ollama if missing"
	@echo "$(WHITE)  make pull-llm$(DEF_COLOR)       Pull Ollama model: $(OLLAMA_MODEL)"
	@echo "$(WHITE)  make check-docker$(DEF_COLOR)   Install docker and docker-compose if missing"
	@echo "$(WHITE)  make qdrant$(DEF_COLOR)         Start Qdrant container"
	@echo "$(WHITE)  make ingest$(DEF_COLOR)         Ingest sample data"
	@echo "$(WHITE)  make run$(DEF_COLOR)            Run FastAPI backend"
	@echo "$(WHITE)  make status$(DEF_COLOR)         Show Docker service status"
	@echo "$(WHITE)  make stop$(DEF_COLOR)           Stop Docker services"
	@echo "$(WHITE)  make clean$(DEF_COLOR)          Remove Python virtual environment"
	@echo "$(WHITE)  make fclean$(DEF_COLOR)         Stop Docker and remove venv"
	@echo "$(WHITE)  make re$(DEF_COLOR)             Rebuild environment from scratch"