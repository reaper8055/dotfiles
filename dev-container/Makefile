# Development Container Management
# Idiomatic automation for container lifecycle

.PHONY: help build up down shell logs clean setup-env status rebuild install-buildx restart exec

# Default target
help: ## Display this help message
	@echo "Development Container Management"
	@echo "=============================="
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Configuration variables with sensible defaults
CONTAINER_NAME := dev-environment
CONTAINER_USER := dev
IMAGE_NAME := dev-container:latest
PROJECTS_DIR := $(HOME)/Projects

# Platform detection
UNAME_S := $(shell uname -s)
UNAME_M := $(shell uname -m)

# Map architecture names
ifeq ($(UNAME_M),x86_64)
    ARCH := amd64
else ifeq ($(UNAME_M),aarch64)
    ARCH := arm64
else ifeq ($(UNAME_M),arm64)
    ARCH := arm64
else
    ARCH := $(UNAME_M)
endif

# Map OS names
ifeq ($(UNAME_S),Linux)
    OS := linux
else ifeq ($(UNAME_S),Darwin)
    OS := darwin
else
    OS := $(shell echo $(UNAME_S) | tr '[:upper:]' '[:lower:]')
endif

BUILDX_VERSION := v0.12.1
BUILDX_URL := https://github.com/docker/buildx/releases/download/$(BUILDX_VERSION)/buildx-$(BUILDX_VERSION).$(OS)-$(ARCH)

# Ensure Projects directory exists
$(PROJECTS_DIR):
	@mkdir -p $(PROJECTS_DIR)

install-buildx: ## Install Docker BuildX for current platform
	@echo "Detecting platform: $(OS)/$(ARCH)"
	@if command -v docker buildx >/dev/null 2>&1; then \
		echo "BuildX already available: $$(docker buildx version)"; \
	else \
		echo "Installing BuildX $(BUILDX_VERSION) for $(OS)/$(ARCH)..."; \
		mkdir -p ~/.docker/cli-plugins/; \
		curl -fsSL $(BUILDX_URL) -o ~/.docker/cli-plugins/docker-buildx; \
		chmod +x ~/.docker/cli-plugins/docker-buildx; \
		echo "BuildX installed successfully: $$(docker buildx version)"; \
	fi

setup-env: ## Generate .env.local from template with current settings
	@echo "Generating .env.local from template..."
	@echo "Creating .env.local with current settings..."
	@echo "# Development Container Environment Variables" > .env.local
	@echo "# Auto-generated on $(date)" >> .env.local
	@echo "" >> .env.local
	@echo "# Directory Mounts" >> .env.local
	@echo "PROJECTS_DIR=$(PROJECTS_DIR)" >> .env.local
	@echo "" >> .env.local
	@echo "# Container Configuration" >> .env.local
	@echo "TZ=UTC" >> .env.local
	@echo ".env.local file created successfully"
	@echo ""
	@echo "Configuration:"
	@echo "  PROJECTS_DIR: $(PROJECTS_DIR)"

build: ## Build the development container image
	@echo "Building development container..."
	@if command -v docker buildx >/dev/null 2>&1; then \
		echo "Using BuildKit..."; \
		docker buildx build -t $(IMAGE_NAME) --load .; \
	else \
		echo "BuildX not found. Installing..."; \
		if $(MAKE) install-buildx 2>/dev/null; then \
			echo "Using BuildKit..."; \
			docker buildx build -t $(IMAGE_NAME) --load .; \
		else \
			echo "BuildX installation failed. Falling back to legacy builder..."; \
			DOCKER_BUILDKIT=0 docker build -t $(IMAGE_NAME) .; \
		fi; \
	fi
	@echo "Build completed: $(IMAGE_NAME)"

up: $(PROJECTS_DIR) ## Start the development container
	@if [ ! -f .env.local ]; then \
		echo "No .env.local found. Creating it now..."; \
		$(MAKE) setup-env; \
	fi
	@echo "Starting development container..."
	@docker-compose --env-file .env.local up -d
	@echo "Container started. Connect via: make shell"

down: ## Stop the development container
	@echo "Stopping development container..."
	@docker-compose down
	@echo "Container stopped"

shell: ## Open an interactive shell in the development container
	@if ! docker ps --format "table {{.Names}}" | grep -q "^$(CONTAINER_NAME)$$"; then \
		echo "Container '$(CONTAINER_NAME)' is not running. Start it with 'make up'"; \
		exit 1; \
	fi
	@echo "Opening shell in development container..."
	@docker exec -u $(CONTAINER_USER) -it $(CONTAINER_NAME) zsh

exec: ## Execute a command in the development container (usage: make exec CMD="command")
	@if [ -z "$(CMD)" ]; then \
		echo "Usage: make exec CMD=\"your command here\""; \
		echo "Example: make exec CMD=\"ls -la\""; \
		exit 1; \
	fi
	@if ! docker ps --format "table {{.Names}}" | grep -q "^$(CONTAINER_NAME)$$"; then \
		echo "Container '$(CONTAINER_NAME)' is not running. Start it with 'make up'"; \
		exit 1; \
	fi
	@echo "Executing: $(CMD)"
	@docker exec -it $(CONTAINER_NAME) zsh -c "$(CMD)"

logs: ## View container logs
	@docker-compose logs -f dev-env

status: ## Check container status and health
	@echo "Container Status:"
	@echo "==============="
	@docker-compose ps
	@echo ""
	@echo "Health Check:"
	@echo "============"
	@docker inspect $(CONTAINER_NAME) --format='{{.State.Health.Status}}' 2>/dev/null || echo "Container not running"
	@echo ""
	@echo "Resource Usage:"
	@echo "============="
	@if docker ps --format "table {{.Names}}" | grep -q "^$(CONTAINER_NAME)$$"; then \
		docker stats $(CONTAINER_NAME) --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"; \
	else \
		echo "Container not running"; \
	fi

rebuild: down build up ## Rebuild and restart the container

restart: down up ## Restart the container without rebuilding

clean: down ## Clean up containers, images, volumes, and configuration
	@echo "Cleaning up development environment..."
	@docker-compose down -v --remove-orphans
	@docker image rm $(IMAGE_NAME) 2>/dev/null || true
	@docker volume prune -f
	@rm -f .env.local
	@echo "Cleanup completed"

# Development workflow targets
init: install-buildx setup-env build up ## Initialize complete development environment
	@echo "Development environment initialized!"
	@echo "Connect with: make shell"

test-connection: ## Test connection to container
	@echo "Testing container connection..."
	@if docker exec $(CONTAINER_NAME) echo "Connection successful" >/dev/null 2>&1; then \
		echo "✓ Container connection successful"; \
		docker exec $(CONTAINER_NAME) zsh -c "echo 'Shell: '\$$0 && echo 'User: '\$$USER && echo 'Working directory: '\$$PWD"; \
	else \
		echo "✗ Connection failed. Ensure container is running with 'make up'"; \
		exit 1; \
	fi

debug: ## Debug container configuration and connection
	@echo "Development Container Debug Information:"
	@echo "======================================"
	@echo "1. Environment Configuration:"
	@if [ -f .env.local ]; then \
		echo "   ✓ .env.local exists"; \
		echo "   PROJECTS_DIR: $(grep PROJECTS_DIR .env.local | cut -d'=' -f2)"; \
	else \
		echo "   ✗ .env.local missing - run 'make setup-env'"; \
	fi
	@echo ""
	@echo "2. Container Status:"
	@if docker ps --format "table {{.Names}}\t{{.Status}}" | grep -q "^$(CONTAINER_NAME)"; then \
		echo "   ✓ Container running"; \
		echo "   Status: $$(docker ps --format "{{.Status}}" --filter name=$(CONTAINER_NAME))"; \
	else \
		echo "   ✗ Container not running - run 'make up'"; \
	fi
	@echo ""
	@echo "3. Health Check:"
	@if docker ps --format "table {{.Names}}" | grep -q "^$(CONTAINER_NAME)$$"; then \
		health=$$(docker inspect $(CONTAINER_NAME) --format='{{.State.Health.Status}}' 2>/dev/null); \
		if [ "$$health" = "healthy" ]; then \
			echo "   ✓ Container healthy"; \
		else \
			echo "   ⚠ Container status: $$health"; \
		fi; \
	else \
		echo "   ✗ Cannot check health - container not running"; \
	fi
	@echo ""
	@echo "4. Directory Mounts:"
	@if docker ps --format "table {{.Names}}" | grep -q "^$(CONTAINER_NAME)$$"; then \
		echo "   Projects directory:"; \
		docker exec $(CONTAINER_NAME) ls -la /home/dev/Projects 2>/dev/null || echo "   ✗ Projects directory not accessible"; \
		echo "   Config directory:"; \
		docker exec $(CONTAINER_NAME) ls -la /home/dev/.config 2>/dev/null || echo "   ✗ Config directory not accessible"; \
	else \
		echo "   ✗ Cannot check mounts - container not running"; \
	fi
	@echo ""
	@echo "5. Container Readiness:"
	@if docker ps --format "table {{.Names}}" | grep -q "^$(CONTAINER_NAME)$$"; then \
		if docker exec $(CONTAINER_NAME) test -f /tmp/.container-ready 2>/dev/null; then \
			echo "   ✓ Container initialization complete"; \
		else \
			echo "   ⚠ Container still initializing"; \
		fi; \
	else \
		echo "   ✗ Cannot check readiness - container not running"; \
	fi

# Quick access commands
nvim: ## Open Neovim in the container
	@$(MAKE) exec CMD="nvim"

htop: ## Open htop in the container
	@$(MAKE) exec CMD="htop"

# Project navigation helpers
projects: ## List projects directory
	@$(MAKE) exec CMD="ls -la /home/dev/Projects"

cd-projects: ## Open shell in projects directory
	@if ! docker ps --format "table {{.Names}}" | grep -q "^$(CONTAINER_NAME)$"; then \
		echo "Container '$(CONTAINER_NAME)' is not running. Start it with 'make up'"; \
		exit 1; \
	fi
	@echo "Opening shell in Projects directory..."
	@docker exec -it $(CONTAINER_NAME) zsh -c "cd /home/dev/Projects && zsh"

# Optional dotfiles setup
setup-dotfiles: ## Clone and setup dotfiles manually (usage: make setup-dotfiles REPO=github.com/user/dotfiles)
	@if [ -z "$(REPO)" ]; then \
		echo "Usage: make setup-dotfiles REPO=github.com/user/dotfiles"; \
		echo "Example: make setup-dotfiles REPO=github.com/myuser/dotfiles"; \
		exit 1; \
	fi
	@if ! docker ps --format "table {{.Names}}" | grep -q "^$(CONTAINER_NAME)$"; then \
		echo "Container '$(CONTAINER_NAME)' is not running. Start it with 'make up'"; \
		exit 1; \
	fi
	@echo "Cloning dotfiles from $(REPO)..."
	@$(MAKE) exec CMD="cd /home/dev && git clone https://$(REPO) dotfiles"
	@echo "Setting up Neovim configuration..."
	@$(MAKE) exec CMD="if [ -d /home/dev/dotfiles/.config/nvim ]; then cp -r /home/dev/dotfiles/.config/nvim/. /home/dev/.config/nvim/; echo 'Neovim config copied'; else echo 'No Neovim config found in dotfiles'; fi"
	@echo "Dotfiles setup complete. You may need to install additional dependencies."
