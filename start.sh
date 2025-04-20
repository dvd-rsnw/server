#!/bin/bash

# Colors for better readability
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if running on Raspberry Pi
IS_RASPBERRY_PI=false
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ "$ID" == "raspbian" ]] || [[ "$ID_LIKE" == *"debian"* && $(grep -q "Raspberry Pi" /proc/cpuinfo) ]]; then
        IS_RASPBERRY_PI=true
    fi
fi

# Check hostname if on Raspberry Pi
if [ "$IS_RASPBERRY_PI" = true ]; then
    CURRENT_HOSTNAME=$(hostname)
    if [ "$CURRENT_HOSTNAME" != "server" ]; then
        echo -e "${YELLOW}Warning: Your hostname is not set to 'server'. For proper server.local configuration:${NC}"
        echo -e "Run: ${GREEN}sudo hostnamectl set-hostname server${NC}"
        echo -e "Edit: ${GREEN}sudo nano /etc/hosts${NC} and add '127.0.1.1 server server.local'"
        echo -e "${YELLOW}After these changes, you'll need to reboot.${NC}"
        echo -e "Continue anyway? (y/n)"
        read -r response
        if [[ "$response" =~ ^([nN][oO]|[nN])$ ]]; then
            exit 0
        fi
    fi
fi

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

# Display appropriate access URLs
echo -e "${GREEN}Containers are now running in the background.${NC}"
if [ "$IS_RASPBERRY_PI" = true ]; then
    IP_ADDRESS=$(hostname -I | awk '{print $1}')
    echo -e "Server available at: http://server.local:4599 or http://${IP_ADDRESS}:4599"
    echo -e "API documentation available at: http://server.local:4599/docs"
else
    echo -e "Main server available at: http://localhost:4599"
    echo -e "Trains service available through the main server at: http://localhost:4599/trains"
fi
echo -e "\nTo view logs, run: docker compose logs -f"
echo -e "To stop containers, run: docker compose down"