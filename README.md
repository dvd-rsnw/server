# NYC Train Status Server

This repository contains a FastAPI application that provides real-time MTA train status information, with a focus on the F and G trains. The application is composed of two services: a main server and a trains service (which handles the MTA GTFS feed processing).

## Prerequisites

- [Git](https://git-scm.com/downloads) (version 2.13.0 or higher)
- [Docker](https://www.docker.com/products/docker-desktop) (version 20.10.0 or higher)
- [Docker Compose](https://docs.docker.com/compose/install/) (version 1.29.0 or higher)

Optional for local development outside Docker:
- Python 3.11 or higher

## Setup Instructions

### Step 1: Clone the Repository

```bash
git clone https://github.com/yourusername/server.git
cd server
```

### Step 2: Run the Setup Script

The setup script will handle everything for you, including Git submodule initialization:

```bash
chmod +x setup.sh  # Make sure the script is executable
./setup.sh
```

What the setup script does:
- Checks for required dependencies (Git, Docker, Docker Compose)
- Initializes and updates Git submodules (critical for the trains service)
- Creates environment configuration files if needed
- Offers to start the Docker containers

### Step 3: Verify the Setup

After running the setup script, verify that the application is running:

1. Open a web browser and navigate to http://localhost:4599
2. For API documentation, visit http://localhost:4599/docs

## Project Structure

- `/` - Main server service (FastAPI application)
- `trains/` - Train service with MTA GTFS feed processing (Git submodule)
  - `f_train/` - F train specific implementation
  - `g_train/` - G train specific implementation

## Manual Setup (if needed)

If you prefer to set up manually or if the setup script encounters issues:

1. Initialize and update Git submodules:
   ```bash
   git submodule init
   git submodule update --recursive
   ```

2. Create a `.env` file in the root directory with:
   ```
   PORT=4599
   PYTHONPATH=/app
   ```

3. Start the application:
   ```bash
   ./start.sh
   ```

## Troubleshooting

### Git Submodule Issues

If you're seeing errors related to missing files in the `trains/` directory:

```bash
# Reset and update the submodule
git submodule update --init --recursive --force
```

### Docker Issues

If Docker containers fail to start:

1. Check if the ports are already in use:
   ```bash
   sudo lsof -i :4599
   ```

2. Stop any conflicting services or change the port in docker-compose.yml

3. Rebuild the Docker containers:
   ```bash
   docker-compose down
   docker-compose up --build
   ```

### Cache Issues

If you're experiencing unexpected behavior, try clearing Docker cache:

```bash
docker-compose down
docker system prune -a --volumes  # WARNING: This removes all unused Docker resources
docker-compose up --build
```

## Development Environment

### VS Code Setup

For the best development experience with VS Code, install these extensions:

- [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- [Python](https://marketplace.visualstudio.com/items?itemName=ms-python.python)
- [Python Debugger](https://marketplace.visualstudio.com/items?itemName=ms-python.debugpy)
- [Pylance](https://marketplace.visualstudio.com/items?itemName=ms-python.vscode-pylance)

Recommended VS Code settings:
- Python > Analysis > **Type Checking Mode** : `basic`
- Python > Analysis > Inlay Hints: **Function Return Types** : `enable`
- Python > Analysis > Inlay Hints: **Variable Types** : `enable`

## Running Tests

```bash
# Using Docker
docker-compose exec server pytest

# Local development (if Python is installed)
cd /path/to/server
python -m pytest
```

## Making Changes

When making changes to the codebase:

1. Ensure you commit Docker files (Dockerfile, docker-compose.yml) when modifying Docker configuration
2. If modifying files in the trains/ directory, remember it's a Git submodule:
   ```bash
   cd trains
   git add .
   git commit -m "Your commit message"
   git push
   
   # Then update the submodule reference in the main repo
   cd ..
   git add trains
   git commit -m "Update trains submodule reference"
   git push
   ```
