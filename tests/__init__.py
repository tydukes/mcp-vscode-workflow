# Test configuration for MCP VS Code Workflow
"""
Basic test setup for the MCP VS Code Workflow project.
This module provides test utilities and fixtures for testing
Python components if they are added to the project.
"""

import os
import sys
from pathlib import Path

# Add the project root to the Python path
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

# Test configuration
TEST_DATA_DIR = project_root / "tests" / "data"
SCRIPTS_DIR = project_root / "scripts"
MCP_CONFIG_DIR = project_root / ".mcp"
VSCODE_PROFILES_DIR = project_root / ".vscode" / "profiles"


def get_project_root():
    """Return the project root directory."""
    return project_root


def get_test_data_path(filename):
    """Get the path to a test data file."""
    return TEST_DATA_DIR / filename


def get_script_path(script_name):
    """Get the path to a script file."""
    return SCRIPTS_DIR / script_name


def get_mcp_config_path(config_name):
    """Get the path to an MCP configuration file."""
    return MCP_CONFIG_DIR / config_name


def get_vscode_profile_path(profile_name):
    """Get the path to a VS Code profile file."""
    return VSCODE_PROFILES_DIR / profile_name
