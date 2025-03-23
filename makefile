.PHONY: build up down pull clean logs restart dev prod test push push-version push-build-tag-version prune-all prune

# Default version tag
VERSION ?= latest

# Default version bump type (patch, minor, major)
BUMP_TYPE ?= patch

# Build the images
build:
	docker compose build

# Start the services
up:
	docker compose up -d

# Start the services in development mode with logs
dev:
	docker compose up

# Start the services with a specific version
prod:
	VERSION=$(VERSION) docker compose up -d

# Pull images from Docker Hub
pull:
	VERSION=$(VERSION) docker compose pull

# Stop the services
down:
	docker compose down

# Stop services and remove volumes
clean:
	docker compose down -v

# View logs
logs:
	docker compose logs -f

# Restart services
restart:
	docker compose restart

# Build and up with specific version for testing
test:
	VERSION=test docker compose up -d --build

# Build a specific service
build-web:
	docker compose build web

build-ollama:
	docker compose build ollama

# Push images to Docker Hub
push:
	docker compose push

# Push with versioning
push-version:
	./scripts/tag-version.sh $(BUMP_TYPE)

# Build, tag and push images without version increment
push-build-tag-version:
	./scripts/build-and-tag.sh

# Pull and restart with no build
update:
	VERSION=$(VERSION) docker compose pull && \
	VERSION=$(VERSION) docker compose up -d --no-build

# exec into containers
exec-ollama:
	  docker exec -it llama3.2-ollama sh 
exec-web:
	  docker exec -it llama3.2-web sh

# Completely clean Docker system including volumes
prune-all:
	docker system prune -a --volumes

# Prune just containers and networks (safer)
prune:
	docker system prune