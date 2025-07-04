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
Usage: $0 [OPTIONS]

Bootstrap MCP VS Code workflow environment for development.

OPTIONS:
  --profile <name>     Use specific profile (bash, cicd, docs, infra, python, node)
  --interactive        Launch interactive mode with auto-detection and wizard
  -h, --help           Show this help message

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
  $0 --interactive        # Launch interactive wizard with auto-detection

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

# Function to detect project type based on file patterns
detect_project_type() {
    local workspace_root="$1"
    local detected_profiles=()
    
    # Check for Python project indicators
    if [[ -f "$workspace_root/requirements.txt" ]] || \
       [[ -f "$workspace_root/pyproject.toml" ]] || \
       [[ -f "$workspace_root/setup.py" ]] || \
       [[ -f "$workspace_root/Pipfile" ]] || \
       [[ -f "$workspace_root/poetry.lock" ]] || \
       [[ -d "$workspace_root/venv" ]] || \
       [[ -d "$workspace_root/.venv" ]] || \
       [[ -n "$(find "$workspace_root" -name "*.py" -type f -not -path "*/.*" | head -1)" ]]; then
        detected_profiles+=("python")
    fi
    
    # Check for Infrastructure project indicators
    if [[ -f "$workspace_root/terraform.tf" ]] || \
       [[ -f "$workspace_root/main.tf" ]] || \
       [[ -f "$workspace_root/variables.tf" ]] || \
       [[ -d "$workspace_root/terraform" ]] || \
       [[ -d "$workspace_root/k8s" ]] || \
       [[ -d "$workspace_root/kubernetes" ]] || \
       [[ -d "$workspace_root/.terraform" ]] || \
       [[ -f "$workspace_root/ansible.cfg" ]] || \
       [[ -f "$workspace_root/playbook.yml" ]] || \
       [[ -n "$(find "$workspace_root" -name "*.tf" -o -name "*.hcl" -type f -not -path "*/.*" | head -1)" ]]; then
        detected_profiles+=("infra")
    fi
    
    # Check for Documentation project indicators
    if [[ -f "$workspace_root/mkdocs.yml" ]] || \
       [[ -f "$workspace_root/conf.py" ]] || \
       [[ -f "$workspace_root/sphinx.conf" ]] || \
       [[ -d "$workspace_root/docs" ]] || \
       [[ -f "$workspace_root/README.md" ]] || \
       [[ -n "$(find "$workspace_root" -name "*.md" -o -name "*.rst" -type f -not -path "*/.*" | head -1)" ]]; then
        detected_profiles+=("docs")
    fi
    
    # Check for CI/CD project indicators
    if [[ -d "$workspace_root/.github/workflows" ]] || \
       [[ -f "$workspace_root/Jenkinsfile" ]] || \
       [[ -f "$workspace_root/.gitlab-ci.yml" ]] || \
       [[ -f "$workspace_root/azure-pipelines.yml" ]] || \
       [[ -f "$workspace_root/docker-compose.yml" ]] || \
       [[ -f "$workspace_root/Dockerfile" ]] || \
       [[ -n "$(find "$workspace_root" -name "*.yml" -o -name "*.yaml" -type f -not -path "*/.*" | xargs grep -l "workflow\|pipeline\|ci\|cd" 2>/dev/null | head -1)" ]]; then
        detected_profiles+=("cicd")
    fi
    
    # Check for Node.js project indicators
    if [[ -f "$workspace_root/package.json" ]] || \
       [[ -f "$workspace_root/package-lock.json" ]] || \
       [[ -f "$workspace_root/yarn.lock" ]] || \
       [[ -f "$workspace_root/pnpm-lock.yaml" ]] || \
       [[ -d "$workspace_root/node_modules" ]] || \
       [[ -n "$(find "$workspace_root" -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" -type f -not -path "*/.*" -not -path "*/node_modules/*" | head -1)" ]]; then
        detected_profiles+=("node")
    fi
    
    # Check for Bash/Shell project indicators
    if [[ -n "$(find "$workspace_root" -name "*.sh" -o -name "*.bash" -type f -not -path "*/.*" | head -1)" ]]; then
        detected_profiles+=("bash")
    fi
    
    # Return the detected profiles
    echo "${detected_profiles[@]}"
}

# Function to ask user questions and determine preferences
ask_user_questions() {
    local detected_profiles=("$@")
    echo
    echo -e "${CYAN}=== Interactive Bootstrap Wizard ===${NC}"
    echo
    
    if [[ ${#detected_profiles[@]} -gt 0 ]]; then
        echo -e "${GREEN}✓ Auto-detected project types:${NC}"
        for profile in "${detected_profiles[@]}"; do
            echo "  • $profile"
        done
        echo
    else
        echo -e "${YELLOW}No specific project type detected. Let's determine your needs!${NC}"
        echo
    fi
    
    echo "Please answer a few questions to help us recommend the best profile:"
    echo
    
    # Question 1: Primary development activity
    echo -e "${BLUE}1. What is your primary development activity?${NC}"
    echo "   a) Writing Python code (web apps, data science, APIs)"
    echo "   b) Managing infrastructure (Terraform, Kubernetes, cloud)"
    echo "   c) Writing documentation (markdown, technical writing)"
    echo "   d) CI/CD pipelines and DevOps automation"
    echo "   e) Shell scripting and system administration"
    echo "   f) JavaScript/TypeScript development"
    echo
    while true; do
        read -p "Your choice (a/b/c/d/e/f): " primary_activity
        case $primary_activity in
            a|A) primary_activity="python"; break;;
            b|B) primary_activity="infra"; break;;
            c|C) primary_activity="docs"; break;;
            d|D) primary_activity="cicd"; break;;
            e|E) primary_activity="bash"; break;;
            f|F) primary_activity="node"; break;;
            *) echo "Please enter a valid option (a-f)";;
        esac
    done
    
    # Question 2: Tools preference
    echo
    echo -e "${BLUE}2. Which tools do you expect to use most?${NC}"
    echo "   a) Python, pip, virtual environments, pytest"
    echo "   b) Terraform, Docker, kubectl, cloud CLIs"
    echo "   c) Markdown editors, documentation generators"
    echo "   d) Docker, YAML, pipeline tools"
    echo "   e) Bash, shellcheck, system utilities"
    echo "   f) Node.js, npm, webpack, testing frameworks"
    echo
    while true; do
        read -p "Your choice (a/b/c/d/e/f): " tools_preference
        case $tools_preference in
            a|A) tools_preference="python"; break;;
            b|B) tools_preference="infra"; break;;
            c|C) tools_preference="docs"; break;;
            d|D) tools_preference="cicd"; break;;
            e|E) tools_preference="bash"; break;;
            f|F) tools_preference="node"; break;;
            *) echo "Please enter a valid option (a-f)";;
        esac
    done
    
    # Return the user's preferences
    echo "$primary_activity|$tools_preference"
}

# Function to recommend profile based on detection and user input
recommend_profile() {
    local detected_profiles=("$@")
    
    # Get user preferences
    local user_input
    user_input=$(ask_user_questions "${detected_profiles[@]}")
    local primary_activity
    local tools_preference
    primary_activity=$(echo "$user_input" | cut -d'|' -f1)
    tools_preference=$(echo "$user_input" | cut -d'|' -f2)
    
    # Score each profile
    declare -A profile_scores
    profile_scores["python"]=0
    profile_scores["infra"]=0
    profile_scores["docs"]=0
    profile_scores["cicd"]=0
    profile_scores["bash"]=0
    profile_scores["node"]=0
    
    # Add points for detected project types
    for profile in "${detected_profiles[@]}"; do
        ((profile_scores["$profile"] += 3))
    done
    
    # Add points for user preferences
    ((profile_scores["$primary_activity"] += 2))
    ((profile_scores["$tools_preference"] += 1))
    
    # Find the highest scoring profile
    local recommended_profile=""
    local max_score=0
    for profile in "${!profile_scores[@]}"; do
        if [[ ${profile_scores[$profile]} -gt $max_score ]]; then
            max_score=${profile_scores[$profile]}
            recommended_profile="$profile"
        fi
    done
    
    echo "$recommended_profile"
}

# Function to show profile description
show_profile_description() {
    local profile="$1"
    
    case $profile in
        python)
            echo "Python Development Profile - Full-stack Python development with testing, debugging, and deployment support"
            echo "  • Optimized for web development (Django, Flask, FastAPI)"
            echo "  • Data science and machine learning tools"
            echo "  • API development and testing"
            echo "  • Virtual environment management"
            ;;
        infra)
            echo "Infrastructure Profile - Infrastructure as Code (IaC) and cloud resource management"
            echo "  • Terraform development and validation"
            echo "  • AWS/Azure/GCP management tools"
            echo "  • Kubernetes operations"
            echo "  • Network and security configuration"
            ;;
        docs)
            echo "Documentation Profile - Technical writing and documentation management"
            echo "  • Markdown and reStructuredText support"
            echo "  • Documentation site generators"
            echo "  • Grammar and style checking"
            echo "  • Cross-reference validation"
            ;;
        cicd)
            echo "CI/CD Profile - Continuous Integration and Deployment automation"
            echo "  • Pipeline development and optimization"
            echo "  • Docker and containerization"
            echo "  • YAML and configuration management"
            echo "  • Deployment automation"
            ;;
        bash)
            echo "Bash/Shell Profile - Shell scripting and system administration"
            echo "  • Advanced shell scripting support"
            echo "  • System administration tools"
            echo "  • Script linting and validation"
            echo "  • Terminal and command-line optimization"
            ;;
        node)
            echo "Node.js Profile - JavaScript/TypeScript development"
            echo "  • Modern JavaScript and TypeScript support"
            echo "  • Package management and build tools"
            echo "  • Testing frameworks and debugging"
            echo "  • Frontend and backend development"
            ;;
    esac
}

# Function to show installation preview
show_installation_preview() {
    local profile="$1"
    
    echo
    echo -e "${CYAN}=== Installation Preview ===${NC}"
    echo
    echo -e "${GREEN}Profile: $profile${NC}"
    echo
    show_profile_description "$profile"
    echo
    echo -e "${BLUE}Tools and configurations that will be installed/configured:${NC}"
    
    case $profile in
        python)
            echo "  • Python extension pack for VS Code"
            echo "  • Pylance language server"
            echo "  • Python debugger and test explorer"
            echo "  • autoDocstring and type checking"
            echo "  • MCP servers: Sequential Thinking, Task Master, Context7"
            echo "  • Python-specific linting and formatting tools"
            ;;
        infra)
            echo "  • HashiCorp Terraform extension"
            echo "  • AWS, Azure, and GCP toolkits"
            echo "  • Kubernetes and YAML support"
            echo "  • Docker and container tools"
            echo "  • MCP servers with infrastructure focus"
            echo "  • Infrastructure validation and security tools"
            ;;
        docs)
            echo "  • Markdown and reStructuredText support"
            echo "  • Documentation generators and previewers"
            echo "  • Grammar and spell checking"
            echo "  • MCP servers for content assistance"
            echo "  • Cross-reference and link validation"
            ;;
        cicd)
            echo "  • YAML and pipeline syntax support"
            echo "  • Docker and containerization tools"
            echo "  • CI/CD pipeline validation"
            echo "  • MCP servers for automation guidance"
            echo "  • Security scanning and compliance tools"
            ;;
        bash)
            echo "  • Bash IDE and syntax highlighting"
            echo "  • shellcheck linting and validation"
            echo "  • Terminal integration and shortcuts"
            echo "  • MCP servers for script optimization"
            echo "  • Command runner and execution tools"
            ;;
        node)
            echo "  • Node.js and npm integration"
            echo "  • TypeScript and JavaScript support"
            echo "  • Package management and build tools"
            echo "  • Testing frameworks and debugging"
            echo "  • MCP servers for JavaScript development"
            ;;
    esac
    
    echo
    echo -e "${BLUE}VS Code Profile:${NC}"
    echo "  • Custom settings optimized for $profile development"
    echo "  • Recommended extensions for $profile workflows"
    echo "  • MCP integration for AI-powered assistance"
    echo "  • Role-based prompts and templates"
    echo
}

# Function to confirm installation
confirm_installation() {
    local profile="$1"
    
    echo -e "${YELLOW}Do you want to proceed with the $profile profile installation?${NC}"
    echo "This will:"
    echo "  • Validate required tools"
    echo "  • Install MCP packages"
    echo "  • Configure VS Code for $profile development"
    echo "  • Launch the development environment"
    echo
    
    while true; do
        read -p "Continue? (y/n): " confirm
        case $confirm in
            y|Y|yes|YES) 
                echo
                log_info "Starting installation for $profile profile..."
                return 0
                ;;
            n|N|no|NO)
                echo
                log_info "Installation cancelled by user"
                return 1
                ;;
            *)
                echo "Please enter 'y' for yes or 'n' for no"
                ;;
        esac
    done
}

# Function to run interactive mode
run_interactive_mode() {
    local workspace_root="$1"
    
    echo
    log_info "Starting interactive mode..."
    echo
    
    # Detect project type
    local detected_profiles
    detected_profiles=$(detect_project_type "$workspace_root")
    read -ra detected_profiles_array <<< "$detected_profiles"
    
    # Get recommendation
    local recommended_profile
    recommended_profile=$(recommend_profile "${detected_profiles_array[@]}")
    
    # Show recommendation
    echo
    echo -e "${GREEN}=== Recommendation ===${NC}"
    echo -e "${CYAN}Based on your project and preferences, we recommend: ${YELLOW}$recommended_profile${NC}"
    echo
    
    # Show installation preview
    show_installation_preview "$recommended_profile"
    
    # Confirm installation
    if confirm_installation "$recommended_profile"; then
        echo "$recommended_profile"
    else
        exit 0
    fi
}

# Function to get the script directory
get_script_dir() {
    local script_path="${BASH_SOURCE[0]}"
    # Resolve symlinks
    while [[ -L "$script_path" ]]; do
        local dir_path
        dir_path=$(dirname "$script_path")
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
    local interactive=false

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --profile)
                profile="$2"
                shift 2
                ;;
            --interactive)
                interactive=true
                shift
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

    # Get script directory and workspace root
    local script_dir
    script_dir=$(get_script_dir)
    local workspace_root
    workspace_root=$(dirname "$script_dir")

    # Handle interactive mode
    if [[ "$interactive" == true ]]; then
        if [[ -n "$profile" ]]; then
            log_error "Cannot use --profile and --interactive together"
            show_usage
            exit 1
        fi
        
        profile=$(run_interactive_mode "$workspace_root")
        if [[ -z "$profile" ]]; then
            log_error "Interactive mode failed to determine profile"
            exit 1
        fi
    else
        # Validate required arguments for non-interactive mode
        if [[ -z "$profile" ]]; then
            log_error "Profile is required (use --profile or --interactive)"
            show_usage
            exit 1
        fi
    fi

    # Validate profile name
    if ! validate_profile "$profile"; then
        exit 1
    fi

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
