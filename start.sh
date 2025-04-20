#!/bin/bash

# Stop any existing containers
echo "Stopping existing containers..."
docker compose down

# Remove any existing container images to ensure fresh build
echo "Removing old container images..."
docker compose rm -f

# Build and start the containers
echo "Building and starting containers..."
docker compose up --build

# The script will wait here while the containers run
# Press Ctrl+C to stop the containers