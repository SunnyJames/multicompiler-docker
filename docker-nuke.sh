#!/bin/bash

# Name of the container and image to destroy
CONTAINER_NAME="multicompiler-container"
IMAGE_NAME="multicompiler"

echo "Stopping container: $CONTAINER_NAME (if running)..."
docker stop "$CONTAINER_NAME" 2>/dev/null || echo "Container not running."

echo "Removing container: $CONTAINER_NAME..."
docker rm "$CONTAINER_NAME" 2>/dev/null || echo "Container already removed."

echo "Do you also want to remove the image '$IMAGE_NAME'? [y/N]"
read -r CONFIRM
if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "Removing image: $IMAGE_NAME..."
  docker rmi "$IMAGE_NAME" || echo "Image not found or already removed."
else
  echo "Skipping image removal."
fi

echo "Done."
