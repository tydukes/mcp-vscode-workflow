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
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
        echo "windows"
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
        windows)
            case "$tool" in
                node) echo "winget install OpenJS.NodeJS" ;;
                npx) echo "npm install -g npx (after installing node)" ;;
                python) echo "winget install Python.Python.3.11" ;;
                uv) echo "winget install astral-sh.uv" ;;
                terraform) echo "winget install Hashicorp.Terraform" ;;
                terragrunt) echo "winget install Gruntwork.Terragrunt" ;;
                ansible) echo "pip install ansible (after installing python)" ;;
                docker) echo "winget install Docker.DockerDesktop" ;;
                jq) echo "winget install jqlang.jq" ;;
                shellcheck) echo "winget install koalaman.shellcheck" ;;
                *) echo "winget install $tool" ;;
            esac
            ;;
        *)
            echo "Please install $tool manually for your operating system"
            ;;
    esac
}

# Function to actually install a tool
install_tool() {
    local tool="$1"
    local os="$2"
    local cmd

    cmd=$(get_install_command "$tool" "$os")
    
    # Check if the command starts with "Please install" (unsupported OS)
    if [[ "$cmd" == "Please install"* ]]; then
        log_error "Automatic installation not supported for $tool on $os"
        return 1
    fi

    log_info "Executing: $cmd"
    
    # Handle different installation methods
    case "$os" in
        macos)
            if [[ "$cmd" == "brew install"* ]]; then
                if ! command_exists brew; then
                    log_error "Homebrew not found. Please install Homebrew first:"
                    log_install "Visit https://brew.sh or run: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
                    return 1
                fi
                # Execute the brew command
                if eval "$cmd" >/dev/null 2>&1; then
                    return 0
                else
                    log_error "Failed to install $tool with homebrew"
                    return 1
                fi
            elif [[ "$cmd" == "npm install"* ]]; then
                if ! command_exists npm; then
                    log_error "npm not found. Please install Node.js first"
                    return 1
                fi
                if eval "$cmd" >/dev/null 2>&1; then
                    return 0
                else
                    log_error "Failed to install $tool with npm"
                    return 1
                fi
            else
                log_error "Unsupported installation method for $tool on $os"
                return 1
            fi
            ;;
        ubuntu)
            if [[ "$cmd" == "sudo apt-get"* ]]; then
                if eval "$cmd" >/dev/null 2>&1; then
                    return 0
                else
                    log_error "Failed to install $tool with apt-get"
                    log_error "You may need to run 'sudo apt-get update' first or check permissions"
                    return 1
                fi
            elif [[ "$cmd" == "curl"* ]]; then
                if eval "$cmd" >/dev/null 2>&1; then
                    return 0
                else
                    local exit_code=$?
                    log_error "Failed to install $tool with curl (exit code: $exit_code)"
                    if [[ $exit_code == 6 ]]; then
                        log_error "Network connectivity issue detected"
                        log_error "Please check your internet connection and try again"
                    fi
                    return 1
                fi
            elif [[ "$cmd" == "wget"* ]]; then
                if eval "$cmd" >/dev/null 2>&1; then
                    return 0
                else
                    log_error "Failed to install $tool with wget"
                    return 1
                fi
            elif [[ "$cmd" == "npm install"* ]]; then
                if ! command_exists npm; then
                    log_error "npm not found. Please install Node.js first"
                    return 1
                fi
                if eval "$cmd" >/dev/null 2>&1; then
                    return 0
                else
                    log_error "Failed to install $tool with npm"
                    return 1
                fi
            else
                log_error "Unsupported installation method for $tool on $os"
                return 1
            fi
            ;;
        fedora|rhel)
            if [[ "$cmd" == "sudo dnf"* ]]; then
                if eval "$cmd" >/dev/null 2>&1; then
                    return 0
                else
                    log_error "Failed to install $tool with dnf"
                    log_error "You may need to check permissions or enable additional repositories"
                    return 1
                fi
            elif [[ "$cmd" == "curl"* ]]; then
                if eval "$cmd" >/dev/null 2>&1; then
                    return 0
                else
                    local exit_code=$?
                    log_error "Failed to install $tool with curl (exit code: $exit_code)"
                    if [[ $exit_code == 6 ]]; then
                        log_error "Network connectivity issue detected"
                        log_error "Please check your internet connection and try again"
                    fi
                    return 1
                fi
            elif [[ "$cmd" == "npm install"* ]]; then
                if ! command_exists npm; then
                    log_error "npm not found. Please install Node.js first"
                    return 1
                fi
                if eval "$cmd" >/dev/null 2>&1; then
                    return 0
                else
                    log_error "Failed to install $tool with npm"
                    return 1
                fi
            else
                log_error "Unsupported installation method for $tool on $os"
                return 1
            fi
            ;;
        windows)
            if [[ "$cmd" == "winget install"* ]]; then
                if ! command_exists winget; then
                    log_error "winget not found. Please install Windows Package Manager or update Windows"
                    return 1
                fi
                if eval "$cmd" >/dev/null 2>&1; then
                    return 0
                else
                    log_error "Failed to install $tool with winget"
                    return 1
                fi
            elif [[ "$cmd" == "pip install"* ]]; then
                if ! command_exists pip; then
                    log_error "pip not found. Please install Python first"
                    return 1
                fi
                if eval "$cmd" >/dev/null 2>&1; then
                    return 0
                else
                    log_error "Failed to install $tool with pip"
                    return 1
                fi
            elif [[ "$cmd" == "npm install"* ]]; then
                if ! command_exists npm; then
                    log_error "npm not found. Please install Node.js first"
                    return 1
                fi
                if eval "$cmd" >/dev/null 2>&1; then
                    return 0
                else
                    log_error "Failed to install $tool with npm"
                    return 1
                fi
            else
                log_error "Unsupported installation method for $tool on $os"
                return 1
            fi
            ;;
        *)
            log_error "Automatic installation not supported for $os"
            return 1
            ;;
    esac
}

# Function to check a single tool
check_tool() {
    local tool="$1"
    local required="$2"
    local os="$3"
    local install_deps="$4"
    local dry_run="$5"

    if command_exists "$tool"; then
        log_info "✓ $tool is installed"
        return 0
    else
        if [[ "$install_deps" == true ]]; then
            if [[ "$dry_run" == true ]]; then
                log_info "Would install: $tool"
                log_install "Command: $(get_install_command "$tool" "$os")"
                return 0
            else
                log_info "Installing $tool..."
                if install_tool "$tool" "$os"; then
                    log_info "✓ $tool installed successfully"
                    return 0
                else
                    log_error "✗ Failed to install $tool"
                    log_install "Manual installation: $(get_install_command "$tool" "$os")"
                    return 1
                fi
            fi
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
    fi
}

# Function to check tools for a specific profile
check_profile_tools() {
    local profile="$1"
    local os="$2"
    local install_deps="$3"
    local dry_run="$4"
    local missing_required=0

    if [[ "$install_deps" == true ]]; then
        if [[ "$dry_run" == true ]]; then
            log_info "Dry run: Checking what would be installed for $profile profile..."
        else
            log_info "Installing missing tools for $profile profile..."
        fi
    else
        log_info "Checking tools for $profile profile..."
    fi
    echo

    case "$profile" in
        bash)
            check_tool "jq" "true" "$os" "$install_deps" "$dry_run" || ((missing_required++))
            check_tool "shellcheck" "true" "$os" "$install_deps" "$dry_run" || ((missing_required++))
            ;;
        cicd)
            check_tool "docker" "true" "$os" "$install_deps" "$dry_run" || ((missing_required++))
            check_tool "jq" "true" "$os" "$install_deps" "$dry_run" || ((missing_required++))
            check_tool "shellcheck" "true" "$os" "$install_deps" "$dry_run" || ((missing_required++))
            ;;
        docs)
            check_tool "jq" "false" "$os" "$install_deps" "$dry_run"
            check_tool "shellcheck" "false" "$os" "$install_deps" "$dry_run"
            ;;
        infra)
            check_tool "terraform" "true" "$os" "$install_deps" "$dry_run" || ((missing_required++))
            check_tool "terragrunt" "false" "$os" "$install_deps" "$dry_run"
            check_tool "ansible" "true" "$os" "$install_deps" "$dry_run" || ((missing_required++))
            check_tool "docker" "true" "$os" "$install_deps" "$dry_run" || ((missing_required++))
            check_tool "jq" "true" "$os" "$install_deps" "$dry_run" || ((missing_required++))
            ;;
        python)
            check_tool "python" "true" "$os" "$install_deps" "$dry_run" || ((missing_required++))
            check_tool "uv" "true" "$os" "$install_deps" "$dry_run" || ((missing_required++))
            ;;
        node)
            check_tool "node" "true" "$os" "$install_deps" "$dry_run" || ((missing_required++))
            check_tool "npx" "true" "$os" "$install_deps" "$dry_run" || ((missing_required++))
            ;;
        all)
            log_info "Checking all tools..."
            echo
            check_tool "node" "false" "$os" "$install_deps" "$dry_run"
            check_tool "npx" "false" "$os" "$install_deps" "$dry_run"
            check_tool "python" "false" "$os" "$install_deps" "$dry_run"
            check_tool "uv" "false" "$os" "$install_deps" "$dry_run"
            check_tool "terraform" "false" "$os" "$install_deps" "$dry_run"
            check_tool "terragrunt" "false" "$os" "$install_deps" "$dry_run"
            check_tool "ansible" "false" "$os" "$install_deps" "$dry_run"
            check_tool "docker" "false" "$os" "$install_deps" "$dry_run"
            check_tool "jq" "false" "$os" "$install_deps" "$dry_run"
            check_tool "shellcheck" "false" "$os" "$install_deps" "$dry_run"
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
        if [[ "$install_deps" == true ]]; then
            if [[ "$dry_run" == true ]]; then
                log_info "Dry run completed for $profile profile"
            else
                log_info "All tools are available for $profile profile"
            fi
        else
            log_info "All required tools are available for $profile profile"
        fi
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
  --install-deps         Automatically install missing tools
  --dry-run             Show what would be installed without installing
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
  $0 python --install-deps  # Install missing Python tools
  $0 --dry-run python    # Show what would be installed for Python

INSTALLATION:
  The --install-deps flag automatically installs missing tools using the appropriate
  package manager for your operating system:
  • macOS: Homebrew (brew)
  • Linux: apt-get (Ubuntu), dnf (Fedora/RHEL)
  • Windows: winget (Windows Package Manager)
  
  Use --dry-run with --install-deps to preview installations without executing them.
  If automatic installation fails, manual installation commands are provided.

Exit codes:
  0 - All required tools are present
  1 - One or more required tools are missing
EOF
}

# Main function
main() {
    # Parse command line arguments
    local profile=""
    local install_deps=false
    local dry_run=false

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
            --install-deps)
                install_deps=true
                shift
                ;;
            --dry-run)
                dry_run=true
                shift
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

    # Validate flag combinations
    if [[ "$dry_run" == true && "$install_deps" == false ]]; then
        log_error "--dry-run can only be used with --install-deps"
        show_usage
        exit 1
    fi

    # If no profile specified, check all profiles
    if [[ -z "$profile" ]]; then
        local overall_status=0
        local profiles=("bash" "cicd" "docs" "infra" "python" "node")

        for p in "${profiles[@]}"; do
            if ! check_profile_tools "$p" "$os" "$install_deps" "$dry_run"; then
                overall_status=1
            fi
            echo "----------------------------------------"
        done

        echo
        if [[ $overall_status -eq 0 ]]; then
            if [[ "$install_deps" == true ]]; then
                if [[ "$dry_run" == true ]]; then
                    log_info "Dry run completed for all profiles"
                else
                    log_info "All profiles have their required tools installed"
                fi
            else
                log_info "All profiles have their required tools available"
            fi
        else
            log_error "One or more profiles have missing required tools"
        fi

        exit $overall_status
    else
        # Check specific profile
        check_profile_tools "$profile" "$os" "$install_deps" "$dry_run"
        exit $?
    fi
}

# Run main function with all arguments
main "$@"
