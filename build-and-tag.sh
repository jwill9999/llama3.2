#!/bin/bash
set -e

# Get the current version
VERSION=$(cat VERSION)

# Build images
echo "Building Docker images..."
VERSION=$VERSION docker-compose -f compose.yml build

# Tag with latest
echo "Tagging images with version v${VERSION}..."
docker tag jwill9999/llama3.2-web:$VERSION jwill9999/llama3.2-web:latest
docker tag jwill9999/llama3.2-ollama:$VERSION jwill9999/llama3.2-ollama:latest

echo "Build and tag complete!"
echo "Run ./tag-version.sh to increment version for next release"

# Ask if user wants to push
read -p "Push images to Docker Hub? (y/n): " PUSH_CHOICE
if [[ $PUSH_CHOICE == "y" || $PUSH_CHOICE == "Y" ]]; then
  docker push jwill9999/llama3.2-web:$VERSION
  docker push jwill9999/llama3.2-ollama:$VERSION
  docker push jwill9999/llama3.2-web:latest
  docker push jwill9999/llama3.2-ollama:latest
  echo "Images pushed to Docker Hub"
fi
