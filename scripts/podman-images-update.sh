#!/bin/sh

# Get a list of unique image names with tags, excluding <none> entries
images=$(podman images --format '{{.Repository}}:{{.Tag}}' | grep -v "<none>")

echo "Updating Podman images and restarting dependent containers..."

# Pull latest images first
for image in $images; do
  echo "Pulling latest image for $image..."
  podman pull "$image"
done

# Collect containers that use the updated images
tmpfile=$(mktemp)
for image in $images; do
  podman ps -q --filter ancestor="$image" >> "$tmpfile"
done
# Remove duplicate container IDs
containers=$(sort -u "$tmpfile")
rm "$tmpfile"

# Stop the containers to free ports
for container in $containers; do
  echo "Stopping container $container..."
  podman stop "$container"
done

# Start the containers again with the new images
for container in $containers; do
  echo "Starting container $container..."
  podman start "$container" || true
done

echo "Update and restart complete."
