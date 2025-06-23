"""
Test the project configuration and structure.
"""

import json
import os
import subprocess

import pytest

from tests import get_mcp_config_path, get_project_root, get_script_path


class TestProjectStructure:
    """Test the basic project structure and configuration files."""

    def test_project_root_exists(self):
        """Test that the project root directory exists."""
        assert get_project_root().exists()

    def test_required_directories_exist(self):
        """Test that required directories exist."""
        project_root = get_project_root()
        required_dirs = [
            ".mcp",
            ".vscode/profiles",
            "scripts",
            "docs",
        ]

        for dir_path in required_dirs:
            assert (
                project_root / dir_path
            ).exists(), f"Directory {dir_path} should exist"

    def test_required_files_exist(self):
        """Test that required files exist."""
        project_root = get_project_root()
        required_files = [
            "README.md",
            "LICENSE",
            ".gitignore",
            "scripts/check-tools.sh",
            "scripts/bootstrap.sh",
        ]

        for file_path in required_files:
            assert (project_root / file_path).exists(), f"File {file_path} should exist"


class TestScripts:
    """Test the shell scripts in the scripts directory."""

    def test_scripts_are_executable(self):
        """Test that shell scripts are executable."""
        scripts_dir = get_project_root() / "scripts"
        shell_scripts = list(scripts_dir.glob("*.sh"))

        assert len(shell_scripts) > 0, "Should have at least one shell script"

        for script in shell_scripts:
            assert os.access(
                script, os.X_OK
            ), f"Script {script.name} should be executable"

    def test_check_tools_script_syntax(self):
        """Test that check-tools.sh has valid syntax."""
        script_path = get_script_path("check-tools.sh")

        # Use shellcheck if available, otherwise just check bash syntax
        try:
            result = subprocess.run(
                ["shellcheck", str(script_path)],
                capture_output=True,
                text=True,
                timeout=30,
            )
            # shellcheck might return warnings (exit code 1) but not errors
            assert result.returncode in [0, 1], f"shellcheck failed: {result.stderr}"
        except FileNotFoundError:
            # Fallback to bash syntax check if shellcheck not available
            result = subprocess.run(
                ["bash", "-n", str(script_path)],
                capture_output=True,
                text=True,
                timeout=30,
            )
            assert result.returncode == 0, f"Bash syntax check failed: {result.stderr}"

    @pytest.mark.skipif(
        not get_script_path("check-tools.sh").exists(),
        reason="check-tools.sh not found",
    )
    def test_check_tools_help(self):
        """Test that check-tools.sh shows help when called with --help."""
        script_path = get_script_path("check-tools.sh")

        result = subprocess.run(
            [str(script_path), "--help"], capture_output=True, text=True, timeout=30
        )

        # Help should return 0 and contain usage information
        assert result.returncode == 0
        assert "usage" in result.stdout.lower() or "help" in result.stdout.lower()


class TestMCPConfigurations:
    """Test MCP configuration files."""

    def test_mcp_config_files_are_valid_json(self):
        """Test that MCP configuration files are valid JSON."""
        mcp_dir = get_project_root() / ".mcp"
        json_files = list(mcp_dir.glob("*.json"))

        for json_file in json_files:
            with open(json_file, "r", encoding="utf-8") as f:
                try:
                    json.load(f)
                except json.JSONDecodeError as e:
                    pytest.fail(f"Invalid JSON in {json_file.name}: {e}")

    def test_roles_json_structure(self):
        """Test that roles.json has the expected structure."""
        roles_path = get_mcp_config_path("roles.json")

        if not roles_path.exists():
            pytest.skip("roles.json not found")

        with open(roles_path, "r", encoding="utf-8") as f:
            roles_config = json.load(f)

        # Check required top-level keys
        assert "mcpVersion" in roles_config
        assert "name" in roles_config
        assert "roles" in roles_config

        # Check that roles is a dictionary
        assert isinstance(roles_config["roles"], dict)


class TestVSCodeProfiles:
    """Test VS Code profile configurations."""

    def test_vscode_profiles_are_valid_json(self):
        """Test that VS Code profile files are valid JSON."""
        profiles_dir = get_project_root() / ".vscode" / "profiles"

        if not profiles_dir.exists():
            pytest.skip("VS Code profiles directory not found")

        json_files = list(profiles_dir.glob("*.json"))

        for json_file in json_files:
            with open(json_file, "r", encoding="utf-8") as f:
                try:
                    json.load(f)
                except json.JSONDecodeError as e:
                    pytest.fail(f"Invalid JSON in {json_file.name}: {e}")


class TestDocumentation:
    """Test documentation files."""

    def test_readme_exists_and_not_empty(self):
        """Test that README.md exists and is not empty."""
        readme_path = get_project_root() / "README.md"

        assert readme_path.exists(), "README.md should exist"
        assert readme_path.stat().st_size > 0, "README.md should not be empty"

    def test_docs_directory_has_content(self):
        """Test that docs directory has content."""
        docs_dir = get_project_root() / "docs"

        if not docs_dir.exists():
            pytest.skip("docs directory not found")

        md_files = list(docs_dir.glob("*.md"))
        assert len(md_files) > 0, "docs directory should contain markdown files"
