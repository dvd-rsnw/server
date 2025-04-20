# FastAPI Template

This sample repo contains the recommended structure for a Python FastAPI project. In this sample, we use `fastapi` to build a web application and the `pytest` to run tests.

For a more in-depth tutorial, see our [Fast API tutorial](https://code.visualstudio.com/docs/python/tutorial-fastapi).

The code in this repo aims to follow Python style guidelines as outlined in [PEP 8](https://peps.python.org/pep-0008/).

## Set up instructions

### Prerequisites

- [Docker](https://www.docker.com/products/docker-desktop) and Docker Compose installed
- Python 3.x (recommended for local development, not required for Docker)

### Quick Setup

1. Clone this repository
2. Navigate to the project directory
3. Run the setup script:
   ```bash
   ./setup.sh
   ```
   The setup script will:
   - Check if required dependencies are installed
   - Create environment configuration files if needed
   - Offer to start the Docker containers

### Manual Setup

If you prefer to set up manually:

1. Ensure Docker and Docker Compose are installed
2. Create a `.env` file in the root directory with:
   ```
   PORT=4599
   PYTHONPATH=/app
   ```
3. Start the application:
   ```bash
   ./start.sh
   ```

### Project Structure

- `server/` - Main application service
- `trains/` - Train service with MTA GTFS feed processing
  - `f_train/` - F train specific implementation
  - `g_train/` - G train specific implementation

### Running in VS Code

To successfully run this example in VS Code, we recommend the following extensions:

- [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- [Python](https://marketplace.visualstudio.com/items?itemName=ms-python.python)
- [Python Debugger](https://marketplace.visualstudio.com/items?itemName=ms-python.debugpy)
- [Pylance](https://marketplace.visualstudio.com/items?itemName=ms-python.vscode-pylance) 

In addition to these extension there a few settings that are also useful to enable. You can enable to following settings by opening the Settings editor (`Ctrl+,`) and searching for the following settings:

- Python > Analysis > **Type Checking Mode** : `basic`
- Python > Analysis > Inlay Hints: **Function Return Types** : `enable`
- Python > Analysis > Inlay Hints: **Variable Types** : `enable`

## Running the sample
- Open the template folder in VS Code (**File** > **Open Folder...**)
- Open the Command Palette in VS Code (**View > Command Palette...**) and run the **Dev Container: Reopen in Container** command.
- Run the app using the Run and Debug view or by pressing `F5`
- `Ctrl + click` on the URL that shows up on the terminal to open the running application 
- Test the API functionality by navigating to `/docs` URL to view the Swagger UI
- Configure your Python test in the Test Panel or by triggering the **Python: Configure Tests** command from the Command Palette
- Run tests in the Test Panel or by clicking the Play Button next to the individual tests in the `test_main.py` file
