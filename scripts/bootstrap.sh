#!/bin/bash

# bootstrap.sh
# Master script to bootstrap MCP VS Code workflow environment
# 
# This script:
# 1. Validates CLI tools for the specified profile
# 2. Installs required MCP packages via NPX
# 3. Launches appropriate MCP servers
# 4. Opens VS Code with the specified profile
#
# Usage: ./bootstrap.sh --profile <profile-name>
# Available profiles: bash, cicd, docs, infra, python, node
#
# Exits non-zero on failure

set -euo pipefail  # Exit on error, undefined variables, and pipe failures

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

log_success() {
    echo -e "${CYAN}[SUCCESS]${NC} $1"
}

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 --profile <profile-name>

Bootstrap MCP VS Code workflow environment for development.

PROFILES:
  bash      - Basic shell development (jq, shellcheck)
  cicd      - CI/CD development (docker, jq, shellcheck)
  docs      - Documentation work (basic tools)
  infra     - Infrastructure/DevOps (terraform, ansible, docker)
  python    - Python development (python, uv)
  node      - Node.js development (node, npx)

EXAMPLES:
  $0 --profile python     # Bootstrap Python development environment
  $0 --profile infra      # Bootstrap Infrastructure development environment

EOF
}

# Function to validate profile name
validate_profile() {
    local profile="$1"
    local valid_profiles=("bash" "cicd" "docs" "infra" "python" "node")
    
    for valid_profile in "${valid_profiles[@]}"; do
        if [[ "$profile" == "$valid_profile" ]]; then
            return 0
        fi
    done
    
    log_error "Invalid profile: $profile"
    log_error "Valid profiles: ${valid_profiles[*]}"
    return 1
}

# Function to get the script directory
get_script_dir() {
    local script_path="${BASH_SOURCE[0]}"
    # Resolve symlinks
    while [[ -L "$script_path" ]]; do
        local dir_path=$(dirname "$script_path")
        script_path=$(readlink "$script_path")
        [[ "$script_path" != /* ]] && script_path="$dir_path/$script_path"
    done
    dirname "$script_path"
}

# Function to check if VS Code is installed
check_vscode() {
    log_step "Checking VS Code installation..."
    
    if command -v code >/dev/null 2>&1; then
        log_info "VS Code CLI found"
        return 0
    else
        log_warn "VS Code CLI not found in PATH"
        log_warn "Please ensure VS Code is installed and 'code' command is available"
        log_warn "Install VS Code from: https://code.visualstudio.com/"
        return 1
    fi
}

# Function to run tool validation
run_tool_validation() {
    local profile="$1"
    local script_dir="$2"
    
    log_step "Validating tools for $profile profile..."
    
    local check_tools_script="$script_dir/check-tools.sh"
    if [[ ! -f "$check_tools_script" ]]; then
        log_error "check-tools.sh not found at: $check_tools_script"
        return 1
    fi
    
    if [[ ! -x "$check_tools_script" ]]; then
        log_info "Making check-tools.sh executable..."
        chmod +x "$check_tools_script"
    fi
    
    if "$check_tools_script" "$profile"; then
        log_success "All required tools validated for $profile profile"
        return 0
    else
        log_error "Tool validation failed for $profile profile"
        log_error "Please install missing tools and try again"
        return 1
    fi
}

# Function to install MCP packages
install_mcp_packages() {
    local script_dir="$1"
    
    log_step "Installing MCP packages via NPX..."
    
    local install_mcp_script="$script_dir/install-mcp-npx.sh"
    if [[ ! -f "$install_mcp_script" ]]; then
        log_error "install-mcp-npx.sh not found at: $install_mcp_script"
        return 1
    fi
    
    if [[ ! -x "$install_mcp_script" ]]; then
        log_info "Making install-mcp-npx.sh executable..."
        chmod +x "$install_mcp_script"
    fi
    
    if "$install_mcp_script"; then
        log_success "MCP packages installed successfully"
        return 0
    else
        log_error "MCP package installation failed"
        return 1
    fi
}

# Function to launch profile-specific startup script
launch_profile_script() {
    local profile="$1"
    local script_dir="$2"
    
    log_step "Launching $profile profile startup script..."
    
    local profile_script="$script_dir/start-${profile}-profile.sh"
    if [[ ! -f "$profile_script" ]]; then
        log_warn "Profile script not found: $profile_script"
        log_warn "Skipping profile-specific startup"
        return 0
    fi
    
    if [[ ! -x "$profile_script" ]]; then
        log_info "Making profile script executable..."
        chmod +x "$profile_script"
    fi
    
    # Check if script has content
    if [[ ! -s "$profile_script" ]]; then
        log_warn "Profile script is empty: $profile_script"
        log_warn "Skipping profile-specific startup"
        return 0
    fi
    
    log_info "Executing profile startup script..."
    if "$profile_script"; then
        log_success "Profile startup script completed"
        return 0
    else
        log_error "Profile startup script failed"
        return 1
    fi
}

# Function to open VS Code with profile
open_vscode_with_profile() {
    local profile="$1"
    local workspace_root="$2"
    
    log_step "Opening VS Code with $profile profile..."
    
    # Check if there's a VS Code profile configuration
    local profile_config="$workspace_root/.vscode/profiles/${profile}.json"
    if [[ -f "$profile_config" ]]; then
        log_info "Found VS Code profile configuration: $profile_config"
        # For now, just open the workspace - VS Code profile switching would need extension support
        log_info "Opening workspace in VS Code..."
    else
        log_info "No specific VS Code profile found, opening with default settings..."
    fi
    
    # Open VS Code in the workspace directory
    if code "$workspace_root"; then
        log_success "VS Code opened successfully"
        log_info "Workspace: $workspace_root"
        if [[ -f "$profile_config" ]]; then
            log_info "Profile config available at: $profile_config"
        fi
        return 0
    else
        log_error "Failed to open VS Code"
        return 1
    fi
}

# Main function
main() {
    local profile=""
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --profile)
                profile="$2"
                shift 2
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Validate required arguments
    if [[ -z "$profile" ]]; then
        log_error "Profile is required"
        show_usage
        exit 1
    fi
    
    # Validate profile name
    if ! validate_profile "$profile"; then
        exit 1
    fi
    
    # Get script directory and workspace root
    local script_dir
    script_dir=$(get_script_dir)
    local workspace_root
    workspace_root=$(dirname "$script_dir")
    
    log_info "Starting MCP VS Code workflow bootstrap"
    log_info "Profile: $profile"
    log_info "Workspace: $workspace_root"
    echo
    
    # Step 1: Check VS Code installation
    if ! check_vscode; then
        log_warn "VS Code check failed, but continuing..."
    fi
    echo
    
    # Step 2: Validate tools for the profile
    if ! run_tool_validation "$profile" "$script_dir"; then
        exit 1
    fi
    echo
    
    # Step 3: Install MCP packages
    if ! install_mcp_packages "$script_dir"; then
        log_warn "MCP installation failed, but continuing..."
    fi
    echo
    
    # Step 4: Launch profile-specific startup script
    launch_profile_script "$profile" "$script_dir"
    echo
    
    # Step 5: Open VS Code with the appropriate profile
    if ! open_vscode_with_profile "$profile" "$workspace_root"; then
        log_error "Failed to open VS Code"
        exit 1
    fi
    
    echo
    log_success "Bootstrap completed successfully!"
    log_info "Your $profile development environment is ready"
    log_info "VS Code is now open with the appropriate configuration"
    
    # Show next steps
    echo
    echo -e "${BLUE}NEXT STEPS:${NC}"
    echo "  • Check the VS Code extensions recommended for $profile profile"
    echo "  • Review MCP prompt templates in .mcp/prompts/"
    echo "  • Customize your workflow in .vscode/profiles/${profile}.json"
    echo "  • Start coding! 🚀"
}

# Run main function with all arguments
main "$@"
