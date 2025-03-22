#!/bin/bash
set -e

# Wait for ollama service to be ready
echo "Waiting for Ollama service..."
sleep 5

# Pull the model
echo "Pulling Llama 3.2 model..."
ollama pull llama3.2
ollama list


echo "Model successfully pulled"

