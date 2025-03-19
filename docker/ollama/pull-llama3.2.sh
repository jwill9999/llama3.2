./bin/ollama serve &

pid=$!

sleep 5

echo "Pulling LLama3.2:latest"
ollama pull llama3.2:latest

wait $pid