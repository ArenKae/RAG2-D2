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
DOCKER_COMPOSE = docker compose

### RULES ###

.PHONY: setup check-docker build run logs status stop clean fclean re ingest help

setup: check-docker build run
	@echo "$(GREEN)>>> $(NAME) setup completed successfully.$(DEF_COLOR)"
	@echo "$(CYAN)>>> Frontend: http://localhost:5173$(DEF_COLOR)"
	@echo "$(CYAN)>>> Backend:  http://localhost:8000$(DEF_COLOR)"
	@echo "$(CYAN)>>> Qdrant:   http://localhost:6333/dashboard$(DEF_COLOR)"

check-docker:
	@echo "$(YELLOW)>>> Checking Docker installation...$(DEF_COLOR)"
	@if ! command -v docker >/dev/null 2>&1; then \
		echo "$(RED)>>> Docker not found. Please install Docker first.$(DEF_COLOR)"; \
		exit 1; \
	fi
	@if ! docker compose version >/dev/null 2>&1; then \
		echo "$(RED)>>> Docker Compose plugin not found. Please install docker-compose-plugin.$(DEF_COLOR)"; \
		exit 1; \
	fi
	@echo "$(GREEN)>>> Docker and Docker Compose are ready.$(DEF_COLOR)"

build: check-docker
	@echo "$(YELLOW)>>> Building Docker images...$(DEF_COLOR)"
	@$(DOCKER_COMPOSE) build
	@echo "$(GREEN)>>> Docker images built.$(DEF_COLOR)"

run: check-docker
	@echo "$(YELLOW)>>> Starting $(NAME) stack in detached mode...$(DEF_COLOR)"
	@$(DOCKER_COMPOSE) up -d
	@echo "$(GREEN)>>> Stack is running.$(DEF_COLOR)"
	@$(DOCKER_COMPOSE) ps

logs:
	@echo "$(YELLOW)>>> Following container logs...$(DEF_COLOR)"
	@$(DOCKER_COMPOSE) logs -f

status:
	@echo "$(YELLOW)>>> Docker services status:$(DEF_COLOR)"
	@$(DOCKER_COMPOSE) ps

stop:
	@echo "$(YELLOW)>>> Stopping Docker services...$(DEF_COLOR)"
	@$(DOCKER_COMPOSE) down
	@echo "$(GREEN)>>> Docker services stopped.$(DEF_COLOR)"

ingest:
	@echo "$(YELLOW)>>> Running ingestion inside backend container...$(DEF_COLOR)"
	@$(DOCKER_COMPOSE) exec backend python -m app.scripts.ingest_sample
	@echo "$(GREEN)>>> Data ingested successfully.$(DEF_COLOR)"

clean:
	@echo "$(YELLOW)>>> Stopping containers...$(DEF_COLOR)"
	@$(DOCKER_COMPOSE) down
	@echo "$(GREEN)>>> Containers stopped.$(DEF_COLOR)"

fclean:
	@echo "$(YELLOW)>>> Removing containers, networks, volumes and local images...$(DEF_COLOR)"
	@$(DOCKER_COMPOSE) down --rmi local
	@echo "$(GREEN)>>> Full Docker cleanup completed.$(DEF_COLOR)"

re: fclean setup
	@echo "$(GREEN)>>> $(NAME) rebuilt successfully.$(DEF_COLOR)"

help:
	@echo "$(CYAN)Available commands for $(NAME):$(DEF_COLOR)"
	@echo "$(WHITE)  make setup$(DEF_COLOR)        Build and start the full Docker stack"
	@echo "$(WHITE)  make build$(DEF_COLOR)        Build Docker images"
	@echo "$(WHITE)  make run$(DEF_COLOR)          Start frontend, backend, Qdrant and Ollama in detached mode"
	@echo "$(WHITE)  make logs$(DEF_COLOR)         Follow logs from all containers"
	@echo "$(WHITE)  make status$(DEF_COLOR)       Show Docker service status"
	@echo "$(WHITE)  make ingest$(DEF_COLOR)       Run ingestion inside backend container"
	@echo "$(WHITE)  make stop$(DEF_COLOR)         Stop containers"
	@echo "$(WHITE)  make clean$(DEF_COLOR)        Stop containers"
	@echo "$(WHITE)  make fclean$(DEF_COLOR)       Stop containers and remove volumes/images"
	@echo "$(WHITE)  make re$(DEF_COLOR)           Full rebuild"