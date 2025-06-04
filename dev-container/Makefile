# Development Container Management
# Idiomatic automation for container lifecycle

.PHONY: help build up down ssh logs clean setup-key status rebuild install-buildx

# Default target
help: ## Display this help message
	@echo "Development Container Management"
	@echo "=============================="
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Configuration variables with sensible defaults
CONTAINER_NAME := dev-environment
IMAGE_NAME := dev-container:latest
SSH_PORT := 2222
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
		echo "BuildX already available: $(docker buildx version)"; \
	else \
		echo "Installing BuildX $(BUILDX_VERSION) for $(OS)/$(ARCH)..."; \
		mkdir -p ~/.docker/cli-plugins/; \
		curl -fsSL $(BUILDX_URL) -o ~/.docker/cli-plugins/docker-buildx; \
		chmod +x ~/.docker/cli-plugins/docker-buildx; \
		echo "BuildX installed successfully: $(docker buildx version)"; \
	fi

setup-key: ## Generate SSH key pair if it doesn't exist
	@if [ ! -f ~/.ssh/id_rsa_dev_container ]; then \
		echo "Generating SSH key pair for dev container..."; \
		ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_dev_container -N "" -C "dev-container"; \
		echo "SSH key generated: ~/.ssh/id_rsa_dev_container"; \
	else \
		echo "SSH key already exists: ~/.ssh/id_rsa_dev_container"; \
	fi

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
	@echo "Starting development container..."
	@export SSH_PUBLIC_KEY="$$(cat ~/.ssh/id_rsa_dev_container.pub 2>/dev/null || echo '')" && \
	export PROJECTS_DIR=$(PROJECTS_DIR) && \
	docker-compose up -d
	@echo "Container started. Connect via: ssh -p $(SSH_PORT) -i ~/.ssh/id_rsa_dev_container dev@localhost"

down: ## Stop the development container
	@echo "Stopping development container..."
	@docker-compose down
	@echo "Container stopped"

ssh: ## SSH into the running development container
	@if [ ! -f ~/.ssh/id_rsa_dev_container ]; then \
		echo "SSH key not found. Run 'make setup-key' first."; \
		exit 1; \
	fi
	@ssh -p $(SSH_PORT) -i ~/.ssh/id_rsa_dev_container -o StrictHostKeyChecking=no dev@localhost

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

rebuild: down build up ## Rebuild and restart the container

clean: down ## Clean up containers, images, and volumes
	@echo "Cleaning up development environment..."
	@docker-compose down -v --remove-orphans
	@docker image rm $(IMAGE_NAME) 2>/dev/null || true
	@docker volume prune -f
	@echo "Cleanup completed"

# Development workflow targets
init: install-buildx setup-key build up ## Initialize complete development environment
	@echo "Development environment initialized!"
	@echo "Connect with: make ssh"

test-connection: ## Test SSH connection to container
	@echo "Testing SSH connection..."
	@timeout 5 ssh -p $(SSH_PORT) -i ~/.ssh/id_rsa_dev_container -o StrictHostKeyChecking=no -o ConnectTimeout=5 dev@localhost "echo 'Connection successful'" || \
	echo "Connection failed. Ensure container is running with 'make up'"
