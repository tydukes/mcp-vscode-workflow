# Docker-based Workflow for MCP VS Code Workflow

This guide explains how to use the Docker-based development environment for MCP VS Code Workflow.

## Quick Start

1. **Build the Docker image:**
   ```sh
   docker-compose build
   ```
2. **Start the container:**
   ```sh
   docker-compose up -d
   docker exec -it mcp-vscode-workflow bash
   ```
   Your workspace is mounted at `/workspace` inside the container.

3. **VS Code Dev Container:**
   - Open the project in VS Code.
   - Install the "Dev Containers" extension.
   - Click "Reopen in Container" when prompted, or use the Command Palette: `Dev Containers: Reopen in Container`.

## Persisting Settings
- VS Code server and user settings are persisted via volume mounts (`~/.vscode-server`, `~/.config`).

## Using the `--docker` Flag
- If you use a CLI or script with a `--docker` flag, it should run commands inside the running container, e.g.:
  ```sh
  docker exec -it mcp-vscode-workflow <your-command>
  ```
- You can alias this in your shell for convenience.

## Customization
- The Dockerfile installs all MCP tools and Python dependencies.
- You can add more tools or extensions in `.devcontainer/devcontainer.json`.

## Stopping the Environment
```sh
docker-compose down
```
