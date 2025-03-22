# Llama 3.2 FastAPI Integration

<div align="center">
<img src="./public/ollama.jpg" alt="Ollama with Llama 3.2"  />
</div>

A FastAPI service that interfaces with Ollama to provide a REST API for the Llama 3.2 model.

## Features

- REST API for text generation with Llama 3.2
- Docker container for easy deployment
- Integration with Ollama for model management

## Quick Start

```bash
# Clone the repository
git clone https://github.com/jwill9999/llama3.2.git
cd llama3.2

# Build the services
docker-compose build

# Start the services
docker-compose up -d

# Access the API at http://localhost:8000
# Use http://localhost:8000/docs for the OpenAPI documentation
```

## Alternative: Using Make Commands

```bash
# Build the services
make build

# Start the services
make up

# Access the API at http://localhost:8000
```

## API Endpoints

- `GET /`: Health check endpoint
- `GET /ask?prompt=YOUR_PROMPT`: Generate a response to the given prompt

## Docker Image

```bash
# Pull the image
docker pull jwill9999/llama3.2-web:latest

# Run the container
docker run -p 8000:8000 jwill9999/llama3.2-web:latest
```

## Available Commands

### Basic Operations

| Command      | Description                               |
|--------------|-------------------------------------------|
| `make build` | Build the Docker images                   |
| `make up`    | Start the services in detached mode       |
| `make dev`   | Start services with console output        |
| `make down`  | Stop the services                         |
| `make logs`  | View service logs                         |
| `make restart`| Restart all services                     |

### Advanced Operations

| Command                      | Description                                |
|------------------------------|--------------------------------------------|
| `make prod VERSION=1.2.0`    | Start services with specific version       |
| `make pull VERSION=1.2.0`    | Pull images with specific version          |
| `make clean`                 | Stop services and remove volumes           |
| `make test`                  | Build and start with test version          |
| `make build-web`             | Build only the web service                 |
| `make build-ollama`          | Build only the ollama service              |
| `make push`                  | Push images to Docker Hub                  |
| `make update VERSION=1.2.0`  | Pull and restart with specific version     |

### Versioning

| Command                         | Description                               |
|---------------------------------|-------------------------------------------|
| `make push-version`             | Tag and push with patch version bump      |
| `make push-version BUMP_TYPE=minor` | Bump minor version (1.0.0 → 1.1.0)   |
| `make push-version BUMP_TYPE=major` | Bump major version (1.0.0 → 2.0.0)   |

## Project Structure

```
llama3.2/
├── docker/
│   ├── fastapi/
│   │   └── Dockerfile
│   └── ollama/
│       └── Dockerfile
├── scripts/
│   ├── tag-version.sh     # Version tagging script
│   ├── build-and-tag.sh   # Build and tag script
│   └── pull-llama3.2.sh   # Pull Llama model script
├── public/
│   └── ollama.jpg         # Logo image
├── main.py                # FastAPI application
├── requirements.txt       # Python dependencies
├── compose.yml            # Docker Compose configuration
├── makefile               # Make commands
└── VERSION                # Current version file
```

## Requirements

- Docker and Docker Compose
- An Ollama instance with the Llama 3.2 model loaded

## License

[MIT License](LICENSE)