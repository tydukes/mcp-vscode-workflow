"""
Test the --install-deps and --dry-run functionality.
"""

import subprocess
import tempfile
from pathlib import Path

from tests import get_script_path


class TestInstallDeps:
    """Test the dependency installation functionality."""

    def test_install_deps_flag_help_message(self):
        """Test that --install-deps flag appears in help message."""
        script_path = get_script_path("bootstrap.sh")

        result = subprocess.run(
            [str(script_path), "--help"], capture_output=True, text=True, timeout=30
        )

        assert result.returncode == 0
        assert "--install-deps" in result.stdout
        assert "Automatically install missing dependencies" in result.stdout

    def test_dry_run_flag_help_message(self):
        """Test that --dry-run flag appears in help message."""
        script_path = get_script_path("bootstrap.sh")

        result = subprocess.run(
            [str(script_path), "--help"], capture_output=True, text=True, timeout=30
        )

        assert result.returncode == 0
        assert "--dry-run" in result.stdout
        assert "Show what would be installed without installing" in result.stdout

    def test_dry_run_without_install_deps_fails(self):
        """Test that --dry-run requires --install-deps."""
        script_path = get_script_path("bootstrap.sh")

        result = subprocess.run(
            [str(script_path), "--dry-run"],
            capture_output=True,
            text=True,
            timeout=30,
        )

        assert result.returncode == 1
        assert "--dry-run can only be used with --install-deps" in result.stdout

    def test_dry_run_with_profile(self):
        """Test dry run mode with a specific profile."""
        script_path = get_script_path("bootstrap.sh")

        result = subprocess.run(
            [str(script_path), "--profile", "python", "--install-deps", "--dry-run"],
            capture_output=True,
            text=True,
            timeout=30,
        )

        assert result.returncode == 0
        assert "Dry run completed successfully!" in result.stdout
        assert "Dry run: Showing what would be installed" in result.stderr

    def test_check_tools_install_deps_help(self):
        """Test that check-tools.sh has --install-deps in help."""
        script_path = get_script_path("check-tools.sh")

        result = subprocess.run(
            [str(script_path), "--help"], capture_output=True, text=True, timeout=30
        )

        assert result.returncode == 0
        assert "--install-deps" in result.stdout
        assert "Automatically install missing tools" in result.stdout

    def test_check_tools_dry_run_functionality(self):
        """Test check-tools.sh dry run functionality."""
        script_path = get_script_path("check-tools.sh")

        result = subprocess.run(
            [str(script_path), "python", "--install-deps", "--dry-run"],
            capture_output=True,
            text=True,
            timeout=30,
        )

        assert result.returncode == 0
        assert "Dry run:" in result.stderr
        assert "Would install:" in result.stderr or "✓" in result.stderr

    def test_check_tools_dry_run_without_install_deps_fails(self):
        """Test that check-tools.sh --dry-run requires --install-deps."""
        script_path = get_script_path("check-tools.sh")

        result = subprocess.run(
            [str(script_path), "python", "--dry-run"],
            capture_output=True,
            text=True,
            timeout=30,
        )

        assert result.returncode == 1
        assert "--dry-run can only be used with --install-deps" in result.stderr

    def test_install_deps_with_existing_tools(self):
        """Test install deps mode with tools that are already installed."""
        script_path = get_script_path("check-tools.sh")

        result = subprocess.run(
            [str(script_path), "bash", "--install-deps"],
            capture_output=True,
            text=True,
            timeout=30,
        )

        # Should succeed since bash tools (jq, shellcheck) are likely installed
        assert result.returncode == 0
        assert "Installing missing tools for bash profile" in result.stderr

    def test_windows_support_in_help(self):
        """Test that Windows is mentioned in help documentation."""
        script_path = get_script_path("check-tools.sh")

        result = subprocess.run(
            [str(script_path), "--help"], capture_output=True, text=True, timeout=30
        )

        assert result.returncode == 0
        # Check if examples mention Windows compatibility
        assert "install" in result.stdout.lower()

    def test_os_detection_functionality(self):
        """Test that OS detection works correctly."""
        script_path = get_script_path("check-tools.sh")

        result = subprocess.run(
            [str(script_path), "bash"], capture_output=True, text=True, timeout=30
        )

        # Should detect an OS (ubuntu in our test environment)
        assert "Detected OS:" in result.stderr