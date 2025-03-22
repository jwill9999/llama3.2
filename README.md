## Ollama with Fastapi running LLama3.2 inside a docker container


<div align="center">
<img src="./public/ollama.jpg" />
</div>


- Runs Ollama

- Runs LLama3.2:latest model (extendable)

- Open API Docs interface

## Clone
```
> git clone https://github.com/jwill9999/llama3.2.git

## Start the container
> docker compose up -d

## Stop the container
> docker compose down
```


## Start the container
> docker compose up -d

## Stop the container
> docker compose down

> Open API docs  http://localhost:8000/docs

> JSON response http://localhost:8000

# Makefile commands

```
# Build and start in development mode (with logs)
make dev

# Deploy with a specific version
make prod VERSION=1.0.0

# Pull latest images and restart
make update

# Build images locally
make build

# Just run the test environment
make test

# Shut down all services
make down

# Clean up everything including volumes
make clean

```