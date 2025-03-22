#!/bin/bash
set -e

# Wait for ollama service to be ready
echo "Waiting for Ollama service..."
sleep 5

# Pull the model
echo "Pulling Llama 3.2 model..."
ollama pull llama3.2


echo "Model successfully pulled"
docker exec -it llama32-ollama ollama pull llama3.2
