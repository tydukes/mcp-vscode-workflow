"""
Test the quick setup functionality in bootstrap.sh.
"""

import subprocess
import time
from pathlib import Path

import pytest

from tests import get_script_path


class TestBootstrapQuick:
    """Test the --quick flag functionality in bootstrap.sh."""

    def test_quick_flag_help_message(self):
        """Test that --quick flag appears in help message."""
        script_path = get_script_path("bootstrap.sh")
        
        result = subprocess.run(
            [str(script_path), "--help"], 
            capture_output=True, 
            text=True, 
            timeout=30
        )
        
        assert result.returncode == 0
        assert "--quick" in result.stdout
        assert "Quick setup with minimal validation" in result.stdout
        assert "under 60 seconds" in result.stdout

    def test_quick_setup_completes_fast(self):
        """Test that quick setup completes in under 60 seconds."""
        script_path = get_script_path("bootstrap.sh")
        
        start_time = time.time()
        result = subprocess.run(
            [str(script_path), "--quick"], 
            capture_output=True, 
            text=True, 
            timeout=60
        )
        end_time = time.time()
        
        execution_time = end_time - start_time
        
        # Should complete successfully
        assert result.returncode == 0
        # Should complete in under 60 seconds (requirement)
        assert execution_time < 60, f"Quick setup took {execution_time:.2f} seconds, should be under 60"
        # Should actually be much faster (under 10 seconds for typical cases)
        assert execution_time < 10, f"Quick setup took {execution_time:.2f} seconds, should be under 10"

    def test_quick_setup_uses_python_profile(self):
        """Test that quick setup uses Python profile by default."""
        script_path = get_script_path("bootstrap.sh")
        
        result = subprocess.run(
            [str(script_path), "--quick"], 
            capture_output=True, 
            text=True, 
            timeout=30
        )
        
        assert result.returncode == 0
        assert "Profile: python (default for quick mode)" in result.stdout
        assert "Python development environment" in result.stdout

    def test_quick_setup_shows_next_steps(self):
        """Test that quick setup shows next steps message."""
        script_path = get_script_path("bootstrap.sh")
        
        result = subprocess.run(
            [str(script_path), "--quick"], 
            capture_output=True, 
            text=True, 
            timeout=30
        )
        
        assert result.returncode == 0
        assert "WHAT'S NEXT:" in result.stdout
        assert "Open VS Code:" in result.stdout
        assert "Start developing with Python:" in result.stdout
        assert "python -m venv venv" in result.stdout
        assert "Happy coding!" in result.stdout

    def test_quick_setup_skips_validation(self):
        """Test that quick setup skips intensive validation."""
        script_path = get_script_path("bootstrap.sh")
        
        result = subprocess.run(
            [str(script_path), "--quick"], 
            capture_output=True, 
            text=True, 
            timeout=30
        )
        
        assert result.returncode == 0
        # Should mention quick/minimal validation
        assert "minimal validation" in result.stdout
        assert "Quick tool availability check" in result.stdout
        # Should NOT run full tool validation
        assert "Validating tools for python profile" not in result.stdout

    def test_quick_with_interactive_fails(self):
        """Test that --quick and --interactive cannot be used together."""
        script_path = get_script_path("bootstrap.sh")
        
        result = subprocess.run(
            [str(script_path), "--quick", "--interactive"], 
            capture_output=True, 
            text=True, 
            timeout=30
        )
        
        assert result.returncode == 1
        assert "Cannot use --quick and --interactive together" in result.stdout

    def test_quick_with_profile_fails(self):
        """Test that --quick and --profile cannot be used together."""
        script_path = get_script_path("bootstrap.sh")
        
        result = subprocess.run(
            [str(script_path), "--quick", "--profile", "python"], 
            capture_output=True, 
            text=True, 
            timeout=30
        )
        
        assert result.returncode == 1
        assert "Cannot use --quick and --profile together" in result.stdout
        assert "Quick mode automatically uses Python profile" in result.stdout

    def test_quick_setup_success_message(self):
        """Test that quick setup shows success message."""
        script_path = get_script_path("bootstrap.sh")
        
        result = subprocess.run(
            [str(script_path), "--quick"], 
            capture_output=True, 
            text=True, 
            timeout=30
        )
        
        assert result.returncode == 0
        assert "🚀 Quick setup completed successfully!" in result.stdout
        assert "ready in under 60 seconds" in result.stdout

    def test_quick_setup_basic_tool_check(self):
        """Test that quick setup performs basic tool availability check."""
        script_path = get_script_path("bootstrap.sh")
        
        result = subprocess.run(
            [str(script_path), "--quick"], 
            capture_output=True, 
            text=True, 
            timeout=30
        )
        
        assert result.returncode == 0
        # Should check for common tools
        assert "git" in result.stdout
        assert "node" in result.stdout  
        assert "python" in result.stdout
        # Should mention tool status
        assert "✓" in result.stdout or "✗" in result.stdout