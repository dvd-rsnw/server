#!/bin/bash

# Colors for better readability
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Stop any existing containers
echo -e "${YELLOW}Stopping existing containers...${NC}"
docker compose down

# Remove any existing container images to ensure fresh build
echo -e "${YELLOW}Removing old container images...${NC}"
docker compose rm -f

# Check if trains directory has Dockerfile
if [ ! -f "trains/Dockerfile" ]; then
    echo -e "${RED}Trains Dockerfile not found. Running setup.sh to create it...${NC}"
    ./setup.sh
    exit 0
fi

# Build and start the containers
echo -e "${GREEN}Building and starting containers...${NC}"
docker compose up --build -d

echo -e "${GREEN}Containers are now running in the background.${NC}"
echo -e "Main server available at: http://localhost:4599"
echo -e "Trains service available through the main server at: http://localhost:4599/trains"
echo -e "\nTo view logs, run: docker compose logs -f"
echo -e "To stop containers, run: docker compose down"