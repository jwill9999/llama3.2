#!/bin/sh
set -e

# Start Ollama server
ollama serve &

# Wait for it to initialize
sleep 5

# Optional: Pull or run models here
ollama run llama3.2 &

# Keep container running
tail -f /dev/null
