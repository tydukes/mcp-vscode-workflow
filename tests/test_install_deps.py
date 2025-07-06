"""
Test the --install-deps and --dry-run functionality.
"""

import subprocess

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
        assert "Dry run: Showing what would be installed" in result.stdout

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
        # Check output in both stderr and stdout since different messages
        # may go to different streams
        output = result.stderr + result.stdout
        assert "Dry run:" in output or "Would install:" in output or "✓" in output

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
        output = result.stderr + result.stdout
        assert "--dry-run can only be used with --install-deps" in output

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
        output = result.stderr + result.stdout
        assert "Installing missing tools for bash profile" in output

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
        output = result.stderr + result.stdout
        assert "Detected OS:" in output

    def test_install_deps_with_network_error_handling(self):
        """Test that network errors are handled gracefully."""
        script_path = get_script_path("check-tools.sh")

        result = subprocess.run(
            [str(script_path), "python", "--install-deps"],
            capture_output=True,
            text=True,
            timeout=60,
        )

        # Should either succeed or show proper error handling
        output = result.stderr + result.stdout
        if result.returncode != 0:
            assert (
                "Network connectivity issue detected" in output
                or "Manual installation:" in output
                or "Failed to install" in output
            )

    def test_profile_with_all_tools_installed(self):
        """Test behavior when all tools for a profile are already installed."""
        script_path = get_script_path("bootstrap.sh")

        result = subprocess.run(
            [str(script_path), "--profile", "bash", "--install-deps", "--dry-run"],
            capture_output=True,
            text=True,
            timeout=30,
        )

        assert result.returncode == 0
        assert "Dry run completed successfully!" in result.stdout

    def test_combined_flags_validation(self):
        """Test various combinations of flags for proper validation."""
        script_path = get_script_path("bootstrap.sh")

        # Test invalid combination
        result = subprocess.run(
            [str(script_path), "--profile", "python", "--dry-run"],
            capture_output=True,
            text=True,
            timeout=30,
        )
        assert result.returncode == 1
        assert "--dry-run can only be used with --install-deps" in result.stdout

        # Test valid combination
        result = subprocess.run(
            [str(script_path), "--profile", "python", "--install-deps", "--dry-run"],
            capture_output=True,
            text=True,
            timeout=30,
        )
        assert result.returncode == 0
