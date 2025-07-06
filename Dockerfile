# MCP VS Code Workflow Dockerfile
FROM python:3.13-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install MCP Python dependencies
COPY pyproject.toml uv.lock ./
RUN pip install --upgrade pip && pip install uv && uv pip install -r uv.lock || pip install .

# Install additional tools (pre-commit, bandit, etc.)
RUN pip install pre-commit bandit flake8 black isort pytest

# Create a user to match host UID/GID for file permissions
ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=1000
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

# Set up workspace
WORKDIR /workspace

# Set user
USER $USERNAME

# Entrypoint
CMD ["/bin/bash"]
