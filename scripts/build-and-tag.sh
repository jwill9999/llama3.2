#!/bin/bash
set -e

# Get the project root directory (parent of scripts directory)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd $PROJECT_ROOT

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
echo "Run ./scripts/tag-version.sh to increment version for next release"

# Ask if user wants to push
read -p "Push images to Docker Hub? (y/n): " PUSH_CHOICE
if [[ $PUSH_CHOICE == "y" || $PUSH_CHOICE == "Y" ]]; then
  docker push jwill9999/llama3.2-web:$VERSION
  docker push jwill9999/llama3.2-ollama:$VERSION
  docker push jwill9999/llama3.2-web:latest
  docker push jwill9999/llama3.2-ollama:latest
  echo "Images pushed to Docker Hub"
fi

# Commit version change if git repository exists
if [ -d .git ]; then
  git add VERSION
  git commit -m "Bump version to v${NEW_VERSION}"
  
  # Ask if user wants to create a git tag
  read -p "Create git tag v${NEW_VERSION}? (y/n): " TAG_CHOICE
  if [[ $TAG_CHOICE == "y" || $TAG_CHOICE == "Y" ]]; then
    git tag -a "v${NEW_VERSION}" -m "Version ${NEW_VERSION}"
    
    read -p "Push git tag to remote? (y/n): " PUSH_GIT_CHOICE
    if [[ $PUSH_GIT_CHOICE == "y" || $PUSH_GIT_CHOICE == "Y" ]]; then
      git push origin "v${NEW_VERSION}"
      git push
    fi
  fi
fi

echo "Version tagging complete!"
