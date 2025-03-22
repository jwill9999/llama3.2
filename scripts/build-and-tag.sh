#!/bin/bash
set -e

# Get the project root directory (parent of scripts directory)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd $PROJECT_ROOT

# Get the current version
VERSION=$(cat VERSION)
echo "Current version: $VERSION"

# Build images first
echo "Building Docker images..."
docker-compose -f compose.yml build

# Tag images with explicit versions (with v prefix)
echo "Tagging images with version v${VERSION}..."
docker tag jwill9999/llama3.2-web:latest jwill9999/llama3.2-web:v${VERSION}
docker tag jwill9999/llama3.2-ollama:latest jwill9999/llama3.2-ollama:v${VERSION}

echo "Build and tag complete!"
echo "Images tagged with version v${VERSION}"
echo "Run ./scripts/tag-version.sh to increment version for next release"

# Ask if user wants to push
read -p "Push images to Docker Hub? (y/n): " PUSH_CHOICE
if [[ $PUSH_CHOICE == "y" || $PUSH_CHOICE == "Y" ]]; then
  # Push both latest and versioned tags
  docker push jwill9999/llama3.2-web:latest
  docker push jwill9999/llama3.2-ollama:latest
  docker push jwill9999/llama3.2-web:v${VERSION}
  docker push jwill9999/llama3.2-ollama:v${VERSION}
  echo "Images pushed to Docker Hub"
fi

# Check if git repository exists
if [ -d .git ]; then
  # Check if there are changes to commit
  if git diff --quiet HEAD -- VERSION; then
    echo "No changes to the VERSION file, skipping git operations."
  else
    git add VERSION
    git commit -m "Bump version to v${VERSION}"
    
    # Ask if user wants to create a git tag
    read -p "Create git tag v${VERSION}? (y/n): " TAG_CHOICE
    if [[ $TAG_CHOICE == "y" || $TAG_CHOICE == "Y" ]]; then
      git tag -a "v${VERSION}" -m "Version ${VERSION}"
      
      read -p "Push git tag to remote? (y/n): " PUSH_GIT_CHOICE
      if [[ $PUSH_GIT_CHOICE == "y" || $PUSH_GIT_CHOICE == "Y" ]]; then
        git push origin "v${VERSION}"
        git push
      fi
    fi
  fi
fi

echo "Version tagging complete!"
