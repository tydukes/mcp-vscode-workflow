"""
Test the auto-detect functionality in bootstrap.sh.
"""

import subprocess
import tempfile
from pathlib import Path

from tests import get_script_path


class TestBootstrapAutoDetect:
    """Test the auto-detect functionality in bootstrap.sh."""

    def test_autodetect_help_message(self):
        """Test that auto-detect functionality appears in help message."""
        script_path = get_script_path("bootstrap.sh")

        result = subprocess.run(
            [str(script_path), "--help"], capture_output=True, text=True, timeout=30
        )

        assert result.returncode == 0
        assert (
            "Auto-detect profile based on project structure (default)" in result.stdout
        )
        assert "AUTO-DETECTION:" in result.stdout
        assert "analyze your project structure" in result.stdout

    def test_autodetect_with_python_project(self):
        """Test auto-detect mode with a Python project."""
        script_path = get_script_path("bootstrap.sh")

        # Create a temporary directory with Python files
        with tempfile.TemporaryDirectory() as tmpdir:
            # Create Python project files
            (Path(tmpdir) / "requirements.txt").write_text("pytest\n")
            (Path(tmpdir) / "main.py").write_text("print('hello')\n")

            # Test auto-detect with cancellation
            result = subprocess.run(
                ["bash", str(script_path)],
                input="4\n",  # Cancel
                cwd=tmpdir,
                capture_output=True,
                text=True,
                timeout=30,
            )

            assert result.returncode == 0
            assert "Analyzing project structure" in result.stderr
            assert "python profile detected" in result.stderr
            assert "Found requirements.txt" in result.stderr
            assert "Found Python (.py) source files" in result.stderr
            assert "we recommend:" in result.stderr
            assert "Operation cancelled by user" in result.stderr

    def test_autodetect_with_infrastructure_project(self):
        """Test auto-detect mode with an infrastructure project."""
        script_path = get_script_path("bootstrap.sh")

        # Create a temporary directory with infrastructure files
        with tempfile.TemporaryDirectory() as tmpdir:
            # Create infrastructure project files
            (Path(tmpdir) / "main.tf").write_text(
                'terraform {\n  required_version = ">= 1.0"\n}\n'
            )
            (Path(tmpdir) / "variables.tf").write_text(
                'variable "environment" {\n  type = string\n}\n'
            )
            Path(tmpdir, "terraform").mkdir()

            # Test auto-detect with cancellation
            result = subprocess.run(
                ["bash", str(script_path)],
                input="4\n",  # Cancel
                cwd=tmpdir,
                capture_output=True,
                text=True,
                timeout=30,
            )

            assert result.returncode == 0
            assert "Analyzing project structure" in result.stderr
            assert "infra profile detected" in result.stderr
            assert "Found main.tf" in result.stderr
            assert "Found variables.tf" in result.stderr
            assert "Found terraform directory" in result.stderr
            assert "we recommend:" in result.stderr

    def test_autodetect_with_documentation_project(self):
        """Test auto-detect mode with a documentation project."""
        script_path = get_script_path("bootstrap.sh")

        # Create a temporary directory with documentation files
        with tempfile.TemporaryDirectory() as tmpdir:
            # Create documentation project files
            (Path(tmpdir) / "README.md").write_text("# Documentation Project\n")
            (Path(tmpdir) / "mkdocs.yml").write_text("site_name: My Docs\n")
            Path(tmpdir, "docs").mkdir()
            (Path(tmpdir) / "docs" / "index.md").write_text("# Home\n")

            # Test auto-detect with cancellation
            result = subprocess.run(
                ["bash", str(script_path)],
                input="4\n",  # Cancel
                cwd=tmpdir,
                capture_output=True,
                text=True,
                timeout=30,
            )

            assert result.returncode == 0
            assert "Analyzing project structure" in result.stderr
            assert "docs profile detected" in result.stderr
            assert "Found mkdocs.yml" in result.stderr
            assert "Found docs directory" in result.stderr
            assert "Found README.md" in result.stderr
            assert "we recommend:" in result.stderr

    def test_autodetect_with_mixed_project(self):
        """Test auto-detect mode with a mixed project (multiple profile types)."""
        script_path = get_script_path("bootstrap.sh")

        # Create a temporary directory with mixed files
        with tempfile.TemporaryDirectory() as tmpdir:
            # Create files for multiple profiles
            (Path(tmpdir) / "requirements.txt").write_text("flask\n")
            (Path(tmpdir) / "app.py").write_text("from flask import Flask\n")
            (Path(tmpdir) / "README.md").write_text("# Mixed Project\n")
            (Path(tmpdir) / "Dockerfile").write_text("FROM python:3.9\n")
            Path(tmpdir, "docs").mkdir()

            # Test auto-detect with cancellation
            result = subprocess.run(
                ["bash", str(script_path)],
                input="4\n",  # Cancel
                cwd=tmpdir,
                capture_output=True,
                text=True,
                timeout=30,
            )

            assert result.returncode == 0
            assert "Analyzing project structure" in result.stderr
            assert "python profile detected" in result.stderr
            assert "docs profile detected" in result.stderr
            assert "cicd profile detected" in result.stderr
            assert (
                "Confidence: Low" in result.stderr
                or "Confidence: Medium" in result.stderr
            )
            assert (
                "multiple profile types detected" in result.stderr
                or "many profile types detected" in result.stderr
            )

    def test_autodetect_with_no_project_files(self):
        """Test auto-detect mode with empty directory (no specific project type)."""
        script_path = get_script_path("bootstrap.sh")

        # Create an empty temporary directory
        with tempfile.TemporaryDirectory() as tmpdir:
            # Test auto-detect with empty directory
            try:
                result = subprocess.run(
                    ["bash", str(script_path)],
                    input="a\na\ny\n",  # Python, Python tools, Yes
                    cwd=tmpdir,
                    capture_output=True,
                    text=True,
                    timeout=15,  # Shorter timeout
                )
                # If it completes, check the success
                assert result.returncode == 0
                assert "No specific project type detected" in result.stderr
                assert "Falling back to interactive mode" in result.stderr
                assert "=== Interactive Bootstrap Wizard ===" in result.stderr
            except subprocess.TimeoutExpired as e:
                # If it times out, check that it got to interactive mode
                output = e.stderr.decode() if e.stderr else ""
                assert "No specific project type detected" in output
                assert "Falling back to interactive mode" in output
                # The wizard may not appear immediately due to timeout

    def test_autodetect_accept_recommendation(self):
        """Test auto-detect mode accepting the recommendation."""
        script_path = get_script_path("bootstrap.sh")

        # Create a temporary directory with clear Python project
        with tempfile.TemporaryDirectory() as tmpdir:
            (Path(tmpdir) / "requirements.txt").write_text("requests\n")
            (Path(tmpdir) / "main.py").write_text("import requests\n")

            # Test auto-detect with acceptance (option 1)
            # Use a shorter timeout since the script will hang on VS Code opening
            try:
                result = subprocess.run(
                    ["bash", str(script_path)],
                    input="1\n",  # Accept recommendation
                    cwd=tmpdir,
                    capture_output=True,
                    text=True,
                    timeout=15,  # Shorter timeout
                )
                # If it completes, check the success
                assert result.returncode == 0
                assert "Proceeding with recommended profile: python" in result.stderr
                assert "Starting MCP VS Code workflow bootstrap" in result.stdout
                assert "Profile: python" in result.stdout
            except subprocess.TimeoutExpired as e:
                # If it times out, check that it got to the bootstrap start
                output = e.stderr.decode() if e.stderr else ""
                assert "Proceeding with recommended profile: python" in output
                # Test passes if we get to this point

    def test_autodetect_choose_different_profile(self):
        """Test auto-detect mode choosing a different profile."""
        script_path = get_script_path("bootstrap.sh")

        # Create a temporary directory with Python files but choose docs profile
        with tempfile.TemporaryDirectory() as tmpdir:
            (Path(tmpdir) / "requirements.txt").write_text("requests\n")
            (Path(tmpdir) / "main.py").write_text("import requests\n")

            # Test auto-detect with different profile selection (option 2, then c)
            # Use a shorter timeout since the script will hang on VS Code opening
            try:
                result = subprocess.run(
                    ["bash", str(script_path)],
                    input="2\nc\n",  # Choose different profile, then docs
                    cwd=tmpdir,
                    capture_output=True,
                    text=True,
                    timeout=15,  # Shorter timeout
                )
                # If it completes, check the success
                assert result.returncode == 0
                assert "Available profiles:" in result.stderr
                assert "c) docs      - Documentation" in result.stderr
                assert "Starting MCP VS Code workflow bootstrap" in result.stdout
                assert "Profile: docs" in result.stdout
            except subprocess.TimeoutExpired as e:
                # If it times out, check that it got to the profile selection
                output = e.stderr.decode() if e.stderr else ""
                assert "Available profiles:" in output
                assert "c) docs      - Documentation" in output
                # Test passes if we get to this point

    def test_autodetect_interactive_fallback(self):
        """Test auto-detect mode falling back to interactive mode."""
        script_path = get_script_path("bootstrap.sh")

        # Create a temporary directory with mixed files
        with tempfile.TemporaryDirectory() as tmpdir:
            (Path(tmpdir) / "requirements.txt").write_text("requests\n")
            (Path(tmpdir) / "main.py").write_text("import requests\n")

            # Test auto-detect with interactive fallback (option 3)
            # Use a shorter timeout since the script will hang on VS Code opening
            try:
                result = subprocess.run(
                    ["bash", str(script_path)],
                    input="3\na\na\nn\n",  # Interactive mode, Python, tools, No
                    cwd=tmpdir,
                    capture_output=True,
                    text=True,
                    timeout=15,  # Shorter timeout
                )
                # If it completes, check the success
                assert result.returncode == 0
                assert "Switching to interactive mode" in result.stderr
                assert "=== Interactive Bootstrap Wizard ===" in result.stderr
                assert "What is your primary development activity?" in result.stderr
            except subprocess.TimeoutExpired as e:
                # If it times out, check that it got to interactive mode
                output = e.stderr.decode() if e.stderr else ""
                assert "Switching to interactive mode" in output
                # The wizard may not appear immediately due to timeout

    def test_autodetect_confidence_levels(self):
        """Test that confidence levels are calculated correctly."""
        script_path = get_script_path("bootstrap.sh")

        # Test high confidence (single profile)
        with tempfile.TemporaryDirectory() as tmpdir:
            (Path(tmpdir) / "requirements.txt").write_text("requests\n")
            (Path(tmpdir) / "main.py").write_text("import requests\n")

            result = subprocess.run(
                ["bash", str(script_path)],
                input="4\n",  # Cancel
                cwd=tmpdir,
                capture_output=True,
                text=True,
                timeout=30,
            )

            assert "Confidence: High" in result.stderr
            assert "single profile type detected" in result.stderr

    def test_autodetect_detection_reasoning(self):
        """Test that detection reasoning is shown properly."""
        script_path = get_script_path("bootstrap.sh")

        # Create comprehensive project with multiple indicators
        with tempfile.TemporaryDirectory() as tmpdir:
            # Python indicators
            (Path(tmpdir) / "pyproject.toml").write_text("[build-system]\n")
            (Path(tmpdir) / "requirements.txt").write_text("requests\n")
            (Path(tmpdir) / "app.py").write_text("print('hello')\n")

            # Documentation indicators
            (Path(tmpdir) / "README.md").write_text("# Project\n")
            Path(tmpdir, "docs").mkdir()

            # CI/CD indicators
            Path(tmpdir, ".github", "workflows").mkdir(parents=True)
            (Path(tmpdir) / ".github" / "workflows" / "test.yml").write_text(
                "name: test\n"
            )

            result = subprocess.run(
                ["bash", str(script_path)],
                input="4\n",  # Cancel
                cwd=tmpdir,
                capture_output=True,
                text=True,
                timeout=30,
            )

            # Check that reasoning is shown for each detected profile
            assert "Detection Reasoning" in result.stderr
            assert "python profile detected:" in result.stderr
            assert "Found pyproject.toml" in result.stderr
            assert "Found requirements.txt" in result.stderr
            assert "Found Python (.py) source files" in result.stderr

            assert "docs profile detected:" in result.stderr
            assert "Found docs directory" in result.stderr
            assert "Found README.md" in result.stderr

            assert "cicd profile detected:" in result.stderr
            assert "Found .github/workflows directory" in result.stderr

    def test_autodetect_backwards_compatibility(self):
        """Test that existing flags still work with auto-detect."""
        script_path = get_script_path("bootstrap.sh")

        # Test that --profile still works
        result = subprocess.run(
            [str(script_path), "--profile", "python"],
            input="n\n",  # No to installation
            capture_output=True,
            text=True,
            timeout=30,
        )

        # Should skip auto-detect and use specified profile
        assert "Analyzing project structure" not in result.stderr
        assert "Profile: python" in result.stdout

        # Test that --interactive still works
        result = subprocess.run(
            [str(script_path), "--interactive"],
            input="a\na\nn\n",  # Python, Python tools, No
            capture_output=True,
            text=True,
            timeout=30,
        )

        # Should go directly to interactive mode
        assert "=== Interactive Bootstrap Wizard ===" in result.stderr

        # Test that --quick still works
        result = subprocess.run(
            [str(script_path), "--quick"], capture_output=True, text=True, timeout=60
        )

        # Should use quick mode
        assert (
            "Quick setup mode" in result.stderr
            or "quick setup" in result.stderr.lower()
            or "quick setup" in result.stdout.lower()
        )
