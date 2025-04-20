#!/bin/bash

# Colors for better readability
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print section header
print_header() {
    echo -e "\n${GREEN}=== $1 ===${NC}\n"
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for required system dependencies
check_dependencies() {
    print_header "Checking Dependencies"
    
    # Check for Git
    if command_exists git; then
        echo -e "${GREEN}✓${NC} Git installed: $(git --version)"
    else
        echo -e "${RED}✗${NC} Git is not installed. Please install Git."
        exit 1
    fi
    
    # Check for Python
    if command_exists python3; then
        echo -e "${GREEN}✓${NC} Python installed: $(python3 --version)"
    else
        echo -e "${YELLOW}!${NC} Python 3 is not installed. It's recommended for local development but not required for Docker."
    fi
    
    # Check for Docker
    if command_exists docker; then
        echo -e "${GREEN}✓${NC} Docker installed: $(docker --version)"
    else
        echo -e "${RED}✗${NC} Docker is not installed. Please install Docker."
        exit 1
    fi
    
    # Check for Docker Compose
    if command_exists docker-compose || command_exists "docker compose"; then
        echo -e "${GREEN}✓${NC} Docker Compose installed"
    else
        echo -e "${RED}✗${NC} Docker Compose is not installed. Please install Docker Compose."
        exit 1
    fi
}

# Set up Git submodules
setup_git_submodules() {
    print_header "Setting Up Git Submodules"
    
    echo "Initializing and updating Git submodules..."
    git submodule init
    if [ $? -eq 0 ]; then
        git submodule update --recursive
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓${NC} Git submodules initialized and updated successfully"
        else
            echo -e "${RED}✗${NC} Failed to update Git submodules"
            exit 1
        fi
    else
        echo -e "${RED}✗${NC} Failed to initialize Git submodules"
        exit 1
    fi
}

# Ensure trains service has Dockerfile and main.py
setup_trains_service() {
    print_header "Setting Up Trains Service"
    
    # Check if trains directory exists
    if [ ! -d "trains" ]; then
        echo -e "${RED}✗${NC} Trains directory not found. Creating it..."
        mkdir -p trains
    fi
    
    # Ensure Dockerfile exists in trains directory
    if [ ! -f "trains/Dockerfile" ]; then
        echo "Creating Dockerfile for trains service..."
        cat > trains/Dockerfile << EOL
FROM python:3.11-slim

WORKDIR /app

# Copy requirements from parent directory
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Ensure we have the train types module available
COPY train_types.py .

# Copy the trains application
COPY . .

# Set Python to not buffer output
ENV PYTHONUNBUFFERED=1

# Expose the port the app runs on
EXPOSE 4600

# Command to run the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "4600", "--reload"]
EOL
        echo -e "${GREEN}✓${NC} Created Dockerfile for trains service"
    else
        echo -e "${GREEN}✓${NC} Trains Dockerfile exists"
    fi
    
    # Ensure main.py exists in trains directory
    if [ ! -f "trains/main.py" ]; then
        echo "Creating main.py for trains service..."
        cat > trains/main.py << EOL
from typing import List
from fastapi import FastAPI
from f_train.f_train import router as f_train_router, f_train_manhattan_next
from g_train.g_train import router as g_train_router, g_train_next_queens
from train_types import DirectionalTrainArrival

app = FastAPI()

# Add routers
app.include_router(f_train_router)
app.include_router(g_train_router)

@app.get("/")
def root():
    return {"message": "Trains API Service"}

@app.get("/fg-northbound-next", response_model=List[DirectionalTrainArrival])
def fg_trains_northbound_next():
    f_trains = f_train_manhattan_next()
    g_trains = g_train_next_queens()
    all_trains = f_trains + g_trains
    
    # Sort by arrival time (using status string which is in format "X mins")
    sorted_trains = sorted(all_trains, key=lambda x: int(x.status.split()[0]))
    
    return sorted_trains[:2]
EOL
        echo -e "${GREEN}✓${NC} Created main.py for trains service"
    else
        echo -e "${GREEN}✓${NC} Trains main.py exists"
    fi
}

# Set up Docker environment
setup_docker() {
    print_header "Setting Up Docker Environment"
    
    # Create .env file if it doesn't exist
    if [ ! -f ".env" ]; then
        echo "Creating .env file with default values..."
        cat > .env << EOL
# Environment variables for the main service
PORT=4599
PYTHONPATH=/app

# Environment variables for the trains service
TRAINS_PORT=4600

# Add any additional environment variables here
EOL
        echo -e "${GREEN}✓${NC} Created .env file with default settings"
    else
        echo -e "${YELLOW}!${NC} .env file already exists, keeping existing configuration"
    fi
    
    echo -e "${GREEN}✓${NC} Docker environment setup complete"
}

# Build and run Docker containers
run_docker() {
    print_header "Building and Running Docker Containers"
    
    # Use the existing start.sh script
    echo "Running start.sh to build and start Docker containers..."
    bash start.sh
}

# Main function
main() {
    print_header "Project Setup"
    echo "This script will set up the required Git submodules, Docker environment, and ensure the trains service is properly configured."
    
    # Check dependencies
    check_dependencies
    
    # Set up Git submodules
    setup_git_submodules
    
    # Set up trains service
    setup_trains_service
    
    # Set up Docker environment
    setup_docker
    
    # Ask whether to start Docker containers
    echo -e "\nDo you want to build and start Docker containers now?"
    read -p "Enter your choice (y/n): " docker_choice
    
    if [ "$docker_choice" == "y" ] || [ "$docker_choice" == "Y" ]; then
        run_docker
    else
        echo -e "\n${GREEN}Setup completed!${NC}"
        echo "To start the application later, run: ./start.sh"
    fi
}

# Run main function
main