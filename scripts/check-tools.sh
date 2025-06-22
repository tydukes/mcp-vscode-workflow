#!/bin/bash

# check-tools.sh
# Script to validate presence of CLI tools by profile
# 
# Validates CLI tools required for different development profiles:
# - Bash Profile: basic shell tools (jq, shellcheck)
# - CI/CD Profile: docker, jq, shellcheck
# - Documentation Profile: basic tools
# - Infrastructure Profile: terraform, terragrunt, ansible, docker
# - Python Profile: python, uv
# - Node Profile: node, npx
#
# Detects macOS vs Linux and offers appropriate installation commands
# Exits non-zero if required tools are missing

set -euo pipefail  # Exit on error, undefined variables, and pipe failures

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

log_install() {
    echo -e "${BLUE}[INSTALL]${NC} $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command_exists apt; then
            echo "ubuntu"
        elif command_exists dnf; then
            echo "fedora"
        elif command_exists yum; then
            echo "rhel"
        else
            echo "linux"
        fi
    else
        echo "unknown"
    fi
}

# Function to get installation command for a tool
get_install_command() {
    local tool="$1"
    local os="$2"
    
    case "$os" in
        macos)
            case "$tool" in
                node) echo "brew install node" ;;
                npx) echo "npm install -g npx (after installing node)" ;;
                python) echo "brew install python" ;;
                uv) echo "brew install uv" ;;
                terraform) echo "brew install terraform" ;;
                terragrunt) echo "brew install terragrunt" ;;
                ansible) echo "brew install ansible" ;;
                docker) echo "brew install --cask docker" ;;
                jq) echo "brew install jq" ;;
                shellcheck) echo "brew install shellcheck" ;;
                *) echo "brew install $tool" ;;
            esac
            ;;
        ubuntu)
            case "$tool" in
                node) echo "curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && sudo apt-get install -y nodejs" ;;
                npx) echo "npm install -g npx (after installing node)" ;;
                python) echo "sudo apt-get install python3 python3-pip" ;;
                uv) echo "curl -LsSf https://astral.sh/uv/install.sh | sh" ;;
                terraform) echo "wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && sudo apt-get install terraform" ;;
                terragrunt) echo "Download from https://github.com/gruntwork-io/terragrunt/releases" ;;
                ansible) echo "sudo apt-get install ansible" ;;
                docker) echo "sudo apt-get install docker.io" ;;
                jq) echo "sudo apt-get install jq" ;;
                shellcheck) echo "sudo apt-get install shellcheck" ;;
                *) echo "sudo apt-get install $tool" ;;
            esac
            ;;
        fedora|rhel)
            case "$tool" in
                node) echo "sudo dnf install nodejs npm" ;;
                npx) echo "npm install -g npx (after installing node)" ;;
                python) echo "sudo dnf install python3 python3-pip" ;;
                uv) echo "curl -LsSf https://astral.sh/uv/install.sh | sh" ;;
                terraform) echo "sudo dnf install terraform" ;;
                terragrunt) echo "Download from https://github.com/gruntwork-io/terragrunt/releases" ;;
                ansible) echo "sudo dnf install ansible" ;;
                docker) echo "sudo dnf install docker" ;;
                jq) echo "sudo dnf install jq" ;;
                shellcheck) echo "sudo dnf install shellcheck" ;;
                *) echo "sudo dnf install $tool" ;;
            esac
            ;;
        *)
            echo "Please install $tool manually for your operating system"
            ;;
    esac
}

# Function to check a single tool
check_tool() {
    local tool="$1"
    local required="$2"
    local os="$3"
    
    if command_exists "$tool"; then
        log_info "✓ $tool is installed"
        return 0
    else
        if [[ "$required" == "true" ]]; then
            log_error "✗ $tool is missing (required)"
            log_install "To install: $(get_install_command "$tool" "$os")"
            return 1
        else
            log_warn "✗ $tool is missing (optional)"
            log_install "To install: $(get_install_command "$tool" "$os")"
            return 0
        fi
    fi
}

# Function to check tools for a specific profile
check_profile_tools() {
    local profile="$1"
    local os="$2"
    local missing_required=0
    
    log_info "Checking tools for $profile profile..."
    echo
    
    case "$profile" in
        bash)
            check_tool "jq" "true" "$os" || ((missing_required++))
            check_tool "shellcheck" "true" "$os" || ((missing_required++))
            ;;
        cicd)
            check_tool "docker" "true" "$os" || ((missing_required++))
            check_tool "jq" "true" "$os" || ((missing_required++))
            check_tool "shellcheck" "true" "$os" || ((missing_required++))
            ;;
        docs)
            check_tool "jq" "false" "$os"
            check_tool "shellcheck" "false" "$os"
            ;;
        infra)
            check_tool "terraform" "true" "$os" || ((missing_required++))
            check_tool "terragrunt" "false" "$os"
            check_tool "ansible" "true" "$os" || ((missing_required++))
            check_tool "docker" "true" "$os" || ((missing_required++))
            check_tool "jq" "true" "$os" || ((missing_required++))
            ;;
        python)
            check_tool "python" "true" "$os" || ((missing_required++))
            check_tool "uv" "true" "$os" || ((missing_required++))
            ;;
        node)
            check_tool "node" "true" "$os" || ((missing_required++))
            check_tool "npx" "true" "$os" || ((missing_required++))
            ;;
        all)
            log_info "Checking all tools..."
            echo
            check_tool "node" "false" "$os"
            check_tool "npx" "false" "$os"
            check_tool "python" "false" "$os"
            check_tool "uv" "false" "$os"
            check_tool "terraform" "false" "$os"
            check_tool "terragrunt" "false" "$os"
            check_tool "ansible" "false" "$os"
            check_tool "docker" "false" "$os"
            check_tool "jq" "false" "$os"
            check_tool "shellcheck" "false" "$os"
            ;;
        *)
            log_error "Unknown profile: $profile"
            log_error "Available profiles: bash, cicd, docs, infra, python, node, all"
            return 1
            ;;
    esac
    
    echo
    if [[ $missing_required -gt 0 ]]; then
        log_error "$missing_required required tool(s) missing for $profile profile"
        return 1
    else
        log_info "All required tools are available for $profile profile"
        return 0
    fi
}

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS] [PROFILE]
       $0 --profile PROFILE
       $0 -p PROFILE

Validates presence of CLI tools required for different development profiles.

OPTIONS:
  --profile, -p PROFILE  Specify the profile to check
  -h, --help            Show this help message

PROFILES:
  bash      - Shell scripting tools (jq, shellcheck)
  cicd      - CI/CD tools (docker, jq, shellcheck)
  docs      - Documentation tools (basic tools)
  infra     - Infrastructure tools (terraform, terragrunt, ansible, docker, jq)
  python    - Python development tools (python, uv)
  node      - Node.js development tools (node, npx)
  all       - Check all tools (non-required mode)

If no profile is specified, checks all profiles.

Examples:
  $0 python              # Check Python profile tools
  $0 --profile bash      # Check bash profile tools
  $0 -p infra           # Check Infrastructure profile tools
  $0 all                # Check all tools (overview mode)
  $0                    # Check all profiles

Exit codes:
  0 - All required tools are present
  1 - One or more required tools are missing
EOF
}

# Main function
main() {
    # Parse command line arguments
    local profile=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --profile)
                profile="$2"
                shift 2
                ;;
            -p)
                profile="$2"
                shift 2
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                # If no flag is provided, treat the first argument as the profile
                if [[ -z "$profile" ]]; then
                    profile="$1"
                fi
                shift
                ;;
        esac
    done
    
    # Detect operating system
    local os
    os=$(detect_os)
    log_info "Detected OS: $os"
    echo
    
    # If no profile specified, check all profiles
    if [[ -z "$profile" ]]; then
        local overall_status=0
        local profiles=("bash" "cicd" "docs" "infra" "python" "node")
        
        for p in "${profiles[@]}"; do
            if ! check_profile_tools "$p" "$os"; then
                overall_status=1
            fi
            echo "----------------------------------------"
        done
        
        echo
        if [[ $overall_status -eq 0 ]]; then
            log_info "All profiles have their required tools available"
        else
            log_error "One or more profiles have missing required tools"
        fi
        
        exit $overall_status
    else
        # Check specific profile
        check_profile_tools "$profile" "$os"
        exit $?
    fi
}

# Run main function with all arguments
main "$@"
