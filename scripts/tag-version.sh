#!/bin/bash
set -e



# Get the project root directory (parent of scripts directory)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd $PROJECT_ROOT

# Read current version
VERSION=$(cat VERSION)
echo "Current version: $VERSION"

# Parse version components
IFS='.' read -ra VERSION_PARTS <<< "$VERSION"
MAJOR=${VERSION_PARTS[0]}
MINOR=${VERSION_PARTS[1]}
PATCH=${VERSION_PARTS[2]}

# Define tag mode (major, minor, patch)
TAG_MODE=${1:-"patch"}  # Default to patch if no argument provided

# Increment version based on mode
case $TAG_MODE in
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    ;;
  patch)
    PATCH=$((PATCH + 1))
    ;;
  *)
    echo "Invalid mode. Use: major, minor, or patch"
    exit 1
    ;;
esac

# Generate new version
NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
echo "New version: $NEW_VERSION"

# Update version file
echo $NEW_VERSION > VERSION

# Tag Docker images
docker tag jwill9999/llama3.2-api:latest jwill9999/llama3.2-api:v${NEW_VERSION}
docker tag jwill9999/llama3.2-ollama:latest jwill9999/llama3.2-ollama:v${NEW_VERSION}

echo "Images tagged with version v${NEW_VERSION}"

# Ask if user wants to push the new tags
read -p "Push tags to Docker Hub? (y/n): " PUSH_CHOICE
if [[ $PUSH_CHOICE == "y" || $PUSH_CHOICE == "Y" ]]; then
  docker push jwill9999/llama3.2-api:v${NEW_VERSION}
  docker push jwill9999/llama3.2-ollama:v${NEW_VERSION}
  docker push jwill9999/llama3.2-api:latest
  docker push jwill9999/llama3.2-ollama:latest
  echo "Tags pushed to Docker Hub"
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
