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
  --quick              Quick setup with minimal validation (uses Python profile)
  -h, --help           Show this help message

PROFILES:
  bash      - Basic shell development (jq, shellcheck)
  cicd      - CI/CD development (docker, jq, shellcheck)
  docs      - Documentation work (basic tools)
  infra     - Infrastructure/DevOps (terraform, ansible, docker)
  python    - Python development (python, uv)
  node      - Node.js development (node, npx)

EXAMPLES:
  $0                      # Auto-detect profile based on project structure (default)
  $0 --profile python     # Bootstrap Python development environment
  $0 --profile infra      # Bootstrap Infrastructure development environment
  $0 --interactive        # Launch interactive wizard with auto-detection
  $0 --quick              # Quick setup with Python profile (under 60 seconds)

AUTO-DETECTION:
  When no options are provided, the script will analyze your project structure
  and suggest the most appropriate profile based on detected files and patterns.
  You can accept the suggestion, choose a different profile, or use interactive mode.

EOF
}

# Function to validate profile name
validate_profile() {
    local profile="$1"
    local valid_profiles=("bash" "cicd" "docs" "infra" "python" "node")

    # Handle empty profile
    if [[ -z "$profile" ]]; then
        log_error "Profile cannot be empty"
        return 1
    fi

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
       [[ -n "$(find "$workspace_root" -name "*.yml" -o -name "*.yaml" -type f -not -path "*/.*" -exec grep -l "workflow\|pipeline\|ci\|cd" {} + 2>/dev/null | head -1)" ]]; then
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
    echo "${detected_profiles[@]:-}"
}

# Function to show detection reasoning for each detected profile
show_detection_reasoning() {
    local workspace_root="$1"
    shift
    local detected_profiles=("$@")

    if [[ ${#detected_profiles[@]} -eq 0 ]]; then
        echo -e "${YELLOW}No specific project indicators detected${NC}"
        return 0
    fi

    echo -e "${CYAN}=== Detection Reasoning ===${NC}"
    echo

    for profile in "${detected_profiles[@]}"; do
        echo -e "${GREEN}✓ $profile profile detected:${NC}"
        case $profile in
            python)
                [[ -f "$workspace_root/requirements.txt" ]] && echo "  • Found requirements.txt"
                [[ -f "$workspace_root/pyproject.toml" ]] && echo "  • Found pyproject.toml"
                [[ -f "$workspace_root/setup.py" ]] && echo "  • Found setup.py"
                [[ -f "$workspace_root/Pipfile" ]] && echo "  • Found Pipfile"
                [[ -f "$workspace_root/poetry.lock" ]] && echo "  • Found poetry.lock"
                [[ -d "$workspace_root/venv" ]] && echo "  • Found venv directory"
                [[ -d "$workspace_root/.venv" ]] && echo "  • Found .venv directory"
                [[ -n "$(find "$workspace_root" -name "*.py" -type f -not -path "*/.*" | head -1)" ]] && echo "  • Found Python (.py) source files"
                ;;
            infra)
                [[ -f "$workspace_root/terraform.tf" ]] && echo "  • Found terraform.tf"
                [[ -f "$workspace_root/main.tf" ]] && echo "  • Found main.tf"
                [[ -f "$workspace_root/variables.tf" ]] && echo "  • Found variables.tf"
                [[ -d "$workspace_root/terraform" ]] && echo "  • Found terraform directory"
                [[ -d "$workspace_root/k8s" ]] && echo "  • Found k8s directory"
                [[ -d "$workspace_root/kubernetes" ]] && echo "  • Found kubernetes directory"
                [[ -d "$workspace_root/.terraform" ]] && echo "  • Found .terraform directory"
                [[ -f "$workspace_root/ansible.cfg" ]] && echo "  • Found ansible.cfg"
                [[ -f "$workspace_root/playbook.yml" ]] && echo "  • Found playbook.yml"
                [[ -n "$(find "$workspace_root" -name "*.tf" -o -name "*.hcl" -type f -not -path "*/.*" | head -1)" ]] && echo "  • Found Terraform/HCL files"
                ;;
            docs)
                [[ -f "$workspace_root/mkdocs.yml" ]] && echo "  • Found mkdocs.yml"
                [[ -f "$workspace_root/conf.py" ]] && echo "  • Found conf.py (Sphinx)"
                [[ -f "$workspace_root/sphinx.conf" ]] && echo "  • Found sphinx.conf"
                [[ -d "$workspace_root/docs" ]] && echo "  • Found docs directory"
                [[ -f "$workspace_root/README.md" ]] && echo "  • Found README.md"
                [[ -n "$(find "$workspace_root" -name "*.md" -o -name "*.rst" -type f -not -path "*/.*" | head -1)" ]] && echo "  • Found documentation files (.md/.rst)"
                ;;
            cicd)
                [[ -d "$workspace_root/.github/workflows" ]] && echo "  • Found .github/workflows directory"
                [[ -f "$workspace_root/Jenkinsfile" ]] && echo "  • Found Jenkinsfile"
                [[ -f "$workspace_root/.gitlab-ci.yml" ]] && echo "  • Found .gitlab-ci.yml"
                [[ -f "$workspace_root/azure-pipelines.yml" ]] && echo "  • Found azure-pipelines.yml"
                [[ -f "$workspace_root/docker-compose.yml" ]] && echo "  • Found docker-compose.yml"
                [[ -f "$workspace_root/Dockerfile" ]] && echo "  • Found Dockerfile"
                [[ -n "$(find "$workspace_root" -name "*.yml" -o -name "*.yaml" -type f -not -path "*/.*" -exec grep -l "workflow\|pipeline\|ci\|cd" {} + 2>/dev/null | head -1)" ]] && echo "  • Found CI/CD pipeline files"
                ;;
            node)
                [[ -f "$workspace_root/package.json" ]] && echo "  • Found package.json"
                [[ -f "$workspace_root/package-lock.json" ]] && echo "  • Found package-lock.json"
                [[ -f "$workspace_root/yarn.lock" ]] && echo "  • Found yarn.lock"
                [[ -f "$workspace_root/pnpm-lock.yaml" ]] && echo "  • Found pnpm-lock.yaml"
                [[ -d "$workspace_root/node_modules" ]] && echo "  • Found node_modules directory"
                [[ -n "$(find "$workspace_root" -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" -type f -not -path "*/.*" -not -path "*/node_modules/*" | head -1)" ]] && echo "  • Found JavaScript/TypeScript source files"
                ;;
            bash)
                [[ -n "$(find "$workspace_root" -name "*.sh" -o -name "*.bash" -type f -not -path "*/.*" | head -1)" ]] && echo "  • Found shell script files (.sh/.bash)"
                ;;
        esac
        echo
    done
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

    echo -e "${YELLOW}Do you want to proceed with the $profile profile installation?${NC}" >&2
    echo "This will:" >&2
    echo "  • Validate required tools" >&2
    echo "  • Install MCP packages" >&2
    echo "  • Configure VS Code for $profile development" >&2
    echo "  • Launch the development environment" >&2
    echo >&2

    while true; do
        read -r -p "Continue? (y/n): " confirm
        case $confirm in
            y|Y|yes|YES)
                echo >&2
                log_info "Starting installation for $profile profile..." >&2
                return 0
                ;;
            n|N|no|NO)
                echo >&2
                log_info "Installation cancelled by user" >&2
                return 1
                ;;
            *)
                echo "Please enter 'y' for yes or 'n' for no" >&2
                ;;
        esac
    done
}

# Function to run auto-detect mode
run_auto_detect_mode() {
    local workspace_root="$1"

    echo >&2
    log_info "Analyzing project structure..." >&2
    echo >&2

    # Detect project type
    local detected_profiles
    detected_profiles=$(detect_project_type "$workspace_root")
    local detected_profiles_array=()
    if [[ -n "$detected_profiles" ]]; then
        read -ra detected_profiles_array <<< "$detected_profiles"
    fi

    # Show detection results
    echo -e "${CYAN}=== Project Analysis ===${NC}" >&2
    echo >&2

    # Show detection reasoning
    if [[ ${#detected_profiles_array[@]} -gt 0 ]]; then
        show_detection_reasoning "$workspace_root" "${detected_profiles_array[@]}" >&2
    else
        echo -e "${YELLOW}No specific project indicators detected${NC}" >&2
    fi

    # Check if we have clear detection
    if [[ ${#detected_profiles_array[@]} -eq 0 ]]; then
        echo -e "${YELLOW}No specific project type detected.${NC}" >&2
        echo -e "${BLUE}Falling back to interactive mode to determine your needs...${NC}" >&2
        echo >&2
        local interactive_result
        interactive_result=$(run_interactive_mode "$workspace_root")
        if [[ -n "$interactive_result" ]]; then
            echo "$interactive_result"
        else
            echo "CANCELLED"
        fi
        return
    fi

    # Calculate recommendation based on detection only (no user input)
    local recommended_profile
    if [[ ${#detected_profiles_array[@]} -gt 0 ]]; then
        recommended_profile=$(calculate_recommendation "unknown" "unknown" "${detected_profiles_array[@]}")
    else
        recommended_profile=$(calculate_recommendation "unknown" "unknown")
    fi

    # Determine confidence level
    local confidence_level
    if [[ ${#detected_profiles_array[@]} -eq 1 ]]; then
        confidence_level="high"
    elif [[ ${#detected_profiles_array[@]} -le 3 ]]; then
        confidence_level="medium"
    else
        confidence_level="low"
    fi

    # Show recommendation
    echo -e "${GREEN}=== Recommendation ===${NC}" >&2
    echo -e "${CYAN}Based on your project structure, we recommend: ${YELLOW}$recommended_profile${NC}" >&2
    echo >&2

    # Show confidence level and detected alternatives
    case $confidence_level in
        high)
            echo -e "${GREEN}Confidence: High${NC} (single profile type detected)" >&2
            ;;
        medium)
            echo -e "${YELLOW}Confidence: Medium${NC} (multiple profile types detected: ${detected_profiles_array[*]:-})" >&2
            ;;
        low)
            echo -e "${RED}Confidence: Low${NC} (many profile types detected)" >&2
            echo -e "${BLUE}You might want to use interactive mode for better guidance${NC}" >&2
            ;;
    esac
    echo >&2

    # Show installation preview
    show_installation_preview "$recommended_profile" >&2

    # Ask user for confirmation or override
    echo -e "${BLUE}Choose an option:${NC}" >&2
    echo "  1) Accept recommendation ($recommended_profile)" >&2
    echo "  2) Choose different profile" >&2
    echo "  3) Use interactive mode for detailed guidance" >&2
    echo "  4) Cancel" >&2
    echo >&2

    while true; do
        read -r -p "Your choice (1-4): " choice
        case $choice in
            1)
                echo >&2
                log_info "Proceeding with recommended profile: $recommended_profile" >&2
                echo "$recommended_profile"
                return
                ;;
            2)
                echo >&2
                echo -e "${BLUE}Available profiles:${NC}" >&2
                echo "  a) python    - Python development" >&2
                echo "  b) infra     - Infrastructure/DevOps" >&2
                echo "  c) docs      - Documentation" >&2
                echo "  d) cicd      - CI/CD pipelines" >&2
                echo "  e) bash      - Shell scripting" >&2
                echo "  f) node      - Node.js development" >&2
                echo >&2

                while true; do
                    read -r -p "Select profile (a-f): " profile_choice
                    case $profile_choice in
                        a|A) echo "python"; return;;
                        b|B) echo "infra"; return;;
                        c|C) echo "docs"; return;;
                        d|D) echo "cicd"; return;;
                        e|E) echo "bash"; return;;
                        f|F) echo "node"; return;;
                        *) echo "Please enter a valid option (a-f)" >&2;;
                    esac
                done
                ;;
            3)
                echo >&2
                log_info "Switching to interactive mode..." >&2
                run_interactive_mode "$workspace_root"
                return
                ;;
            4)
                echo >&2
                log_info "Operation cancelled by user" >&2
                echo "CANCELLED"
                return
                ;;
            *)
                echo "Please enter a valid option (1-4)" >&2
                ;;
        esac
    done
}

# Function to run interactive mode
run_interactive_mode() {
    local workspace_root="$1"

    echo >&2
    log_info "Starting interactive mode..." >&2
    echo >&2

    # Detect project type
    local detected_profiles
    detected_profiles=$(detect_project_type "$workspace_root")
    local detected_profiles_array=()
    if [[ -n "$detected_profiles" ]]; then
        read -ra detected_profiles_array <<< "$detected_profiles"
    fi

    # Show detected profiles
    echo -e "${CYAN}=== Interactive Bootstrap Wizard ===${NC}" >&2
    echo >&2

    if [[ ${#detected_profiles_array[@]} -gt 0 ]]; then
        echo -e "${GREEN}✓ Auto-detected project types:${NC}" >&2
        for profile in "${detected_profiles_array[@]:-}"; do
            echo "  • $profile" >&2
        done
        echo >&2
    else
        echo -e "${YELLOW}No specific project type detected. Let's determine your needs!${NC}" >&2
        echo >&2
    fi

    # Ask user questions
    echo "Please answer a few questions to help us recommend the best profile:" >&2
    echo >&2

    # Question 1: Primary development activity
    echo -e "${BLUE}1. What is your primary development activity?${NC}" >&2
    echo "   a) Writing Python code (web apps, data science, APIs)" >&2
    echo "   b) Managing infrastructure (Terraform, Kubernetes, cloud)" >&2
    echo "   c) Writing documentation (markdown, technical writing)" >&2
    echo "   d) CI/CD pipelines and DevOps automation" >&2
    echo "   e) Shell scripting and system administration" >&2
    echo "   f) JavaScript/TypeScript development" >&2
    echo >&2
    local primary_activity
    while true; do
        read -r -p "Your choice (a/b/c/d/e/f): " primary_activity
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
    echo >&2
    echo -e "${BLUE}2. Which tools do you expect to use most?${NC}" >&2
    echo "   a) Python, pip, virtual environments, pytest" >&2
    echo "   b) Terraform, Docker, kubectl, cloud CLIs" >&2
    echo "   c) Markdown editors, documentation generators" >&2
    echo "   d) Docker, YAML, pipeline tools" >&2
    echo "   e) Bash, shellcheck, system utilities" >&2
    echo "   f) Node.js, npm, webpack, testing frameworks" >&2
    echo >&2
    local tools_preference
    while true; do
        read -r -p "Your choice (a/b/c/d/e/f): " tools_preference
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

    # Calculate recommendation
    local recommended_profile
    if [[ ${#detected_profiles_array[@]} -gt 0 ]]; then
        recommended_profile=$(calculate_recommendation "$primary_activity" "$tools_preference" "${detected_profiles_array[@]}")
    else
        recommended_profile=$(calculate_recommendation "$primary_activity" "$tools_preference")
    fi

    # Show recommendation
    echo >&2
    echo -e "${GREEN}=== Recommendation ===${NC}" >&2
    echo -e "${CYAN}Based on your project and preferences, we recommend: ${YELLOW}$recommended_profile${NC}" >&2
    echo >&2

    # Show installation preview
    show_installation_preview "$recommended_profile" >&2

    # Confirm installation
    if confirm_installation "$recommended_profile"; then
        echo "$recommended_profile"
    else
        return
    fi
}

# Function to calculate recommendation based on inputs
calculate_recommendation() {
    local primary_activity="$1"
    local tools_preference="$2"
    shift 2
    local detected_profiles=("$@")

    # Score each profile using simple variables
    local python_score=0
    local infra_score=0
    local docs_score=0
    local cicd_score=0
    local bash_score=0
    local node_score=0

    # Add points for detected project types
    for profile in "${detected_profiles[@]:-}"; do
        case $profile in
            python) ((python_score += 3));;
            infra) ((infra_score += 3));;
            docs) ((docs_score += 3));;
            cicd) ((cicd_score += 3));;
            bash) ((bash_score += 3));;
            node) ((node_score += 3));;
        esac
    done

    # Add points for user preferences
    case $primary_activity in
        python) ((python_score += 2));;
        infra) ((infra_score += 2));;
        docs) ((docs_score += 2));;
        cicd) ((cicd_score += 2));;
        bash) ((bash_score += 2));;
        node) ((node_score += 2));;
    esac

    case $tools_preference in
        python) ((python_score += 1));;
        infra) ((infra_score += 1));;
        docs) ((docs_score += 1));;
        cicd) ((cicd_score += 1));;
        bash) ((bash_score += 1));;
        node) ((node_score += 1));;
    esac

    # Find the highest scoring profile
    local recommended_profile="python"
    local max_score=$python_score

    if [[ $infra_score -gt $max_score ]]; then
        max_score=$infra_score
        recommended_profile="infra"
    fi
    if [[ $docs_score -gt $max_score ]]; then
        max_score=$docs_score
        recommended_profile="docs"
    fi
    if [[ $cicd_score -gt $max_score ]]; then
        max_score=$cicd_score
        recommended_profile="cicd"
    fi
    if [[ $bash_score -gt $max_score ]]; then
        max_score=$bash_score
        recommended_profile="bash"
    fi
    if [[ $node_score -gt $max_score ]]; then
        max_score=$node_score
        recommended_profile="node"
    fi

    # If no profile scored, default to the first detected profile or python
    if [[ $max_score -eq 0 ]]; then
        if [[ ${#detected_profiles[@]:-0} -gt 0 ]]; then
            recommended_profile="${detected_profiles[0]}"
        else
            recommended_profile="python"
        fi
    fi

    echo "$recommended_profile"
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
    if command -v code >/dev/null 2>&1; then
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
    else
        log_warn "VS Code CLI not available, skipping VS Code opening"
        log_info "Workspace configured at: $workspace_root"
        if [[ -f "$profile_config" ]]; then
            log_info "Profile config available at: $profile_config"
        fi
        return 0
    fi
}

# Function to run quick setup mode
run_quick_setup() {
    local script_dir="$1"
    local workspace_root="$2"

    log_info "Starting quick setup mode for fast development environment"
    log_info "Using Python profile with minimal validation"
    echo

    # Step 1: Quick VS Code check (don't fail if not found)
    log_step "Quick VS Code check..."
    if command -v code >/dev/null 2>&1; then
        log_info "✓ VS Code CLI available"
    else
        log_warn "VS Code CLI not found - you may need to install it later"
    fi

    # Step 2: Basic tool check for common tools (quick check, don't fail)
    log_step "Quick tool availability check..."
    local tools_status=()

    # Check git
    if command -v git >/dev/null 2>&1; then
        log_info "✓ git available"
        tools_status+=("git: ✓")
    else
        log_warn "git not found - consider installing for version control"
        tools_status+=("git: ✗")
    fi

    # Check node
    if command -v node >/dev/null 2>&1; then
        log_info "✓ node available"
        tools_status+=("node: ✓")
    else
        log_warn "node not found - some MCP features may be limited"
        tools_status+=("node: ✗")
    fi

    # Check python
    if command -v python >/dev/null 2>&1 || command -v python3 >/dev/null 2>&1; then
        log_info "✓ python available"
        tools_status+=("python: ✓")
    else
        log_warn "python not found - may need to install for Python development"
        tools_status+=("python: ✗")
    fi

    # Step 3: Quick MCP package check (don't install, just verify npm is available)
    log_step "Quick MCP package check..."
    if command -v npm >/dev/null 2>&1; then
        log_info "✓ npm available for MCP package management"
    else
        log_warn "npm not found - MCP packages may need manual installation"
    fi

    # Step 4: Launch Python profile script (lightweight)
    log_step "Setting up Python profile..."
    local profile_script="$script_dir/start-python-profile.sh"
    if [[ -f "$profile_script" ]] && [[ -s "$profile_script" ]]; then
        if [[ ! -x "$profile_script" ]]; then
            chmod +x "$profile_script"
        fi
        log_info "Running Python profile setup..."
        "$profile_script" || log_warn "Profile script completed with warnings"
    else
        log_info "Python profile script not found or empty - using default setup"
    fi

    # Step 5: Quick VS Code setup (don't fail on errors)
    log_step "Quick VS Code setup..."
    if command -v code >/dev/null 2>&1; then
        log_info "Preparing VS Code workspace..."
        # Don't actually open VS Code in quick mode to keep it fast
        log_info "VS Code setup ready - workspace: $workspace_root"
    else
        log_info "VS Code setup skipped - CLI not available"
    fi

    return 0
}

# Function to show quick setup success message
show_quick_success_message() {
    local workspace_root="$1"

    echo
    log_success "🚀 Quick setup completed successfully!"
    log_info "Your Python development environment is ready in under 60 seconds"
    echo

    echo -e "${BLUE}WHAT'S NEXT:${NC}"
    echo "  1. Open VS Code:"
    echo "     ${CYAN}code $workspace_root${NC}"
    echo
    echo "  2. Start developing with Python:"
    echo "     ${CYAN}# Create a new Python file${NC}"
    echo "     ${CYAN}touch main.py${NC}"
    echo "     ${CYAN}# Create a virtual environment${NC}"
    echo "     ${CYAN}python -m venv venv${NC}"
    echo "     ${CYAN}# Activate it${NC}"
    echo "     ${CYAN}source venv/bin/activate  # (Linux/Mac)${NC}"
    printf "     %s# or: venv\\Scripts\\activate  # (Windows)%s\n" "${CYAN}" "${NC}"
    echo
    echo "  3. Install MCP packages when needed:"
    echo "     ${CYAN}./scripts/install-mcp-npx.sh${NC}"
    echo
    echo "  4. Full tool validation (optional):"
    echo "     ${CYAN}./scripts/check-tools.sh python${NC}"
    echo
    echo "  5. Switch to interactive mode for advanced setup:"
    echo "     ${CYAN}./scripts/bootstrap.sh --interactive${NC}"
    echo
    echo -e "${GREEN}Happy coding! 🎉${NC}"
}

# Main function
main() {
    local profile=""
    local interactive=false
    local quick=false

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
            --quick)
                quick=true
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
    # Use current directory as workspace root for auto-detection
    workspace_root=$(pwd)

    # Handle quick mode
    if [[ "$quick" == true ]]; then
        # Quick mode validation
        if [[ "$interactive" == true ]]; then
            log_error "Cannot use --quick and --interactive together"
            show_usage
            exit 1
        fi

        if [[ -n "$profile" ]]; then
            log_error "Cannot use --quick and --profile together"
            log_error "Quick mode automatically uses Python profile"
            show_usage
            exit 1
        fi

        # Run quick setup
        log_info "Starting MCP VS Code workflow quick setup"
        log_info "Profile: python (default for quick mode)"
        log_info "Workspace: $workspace_root"
        echo

        if run_quick_setup "$script_dir" "$workspace_root"; then
            show_quick_success_message "$workspace_root"
            exit 0
        else
            log_error "Quick setup failed"
            exit 1
        fi
    fi

    # Handle interactive mode
    if [[ "$interactive" == true ]]; then
        if [[ -n "$profile" ]]; then
            log_error "Cannot use --profile and --interactive together"
            show_usage
            exit 1
        fi

        profile=$(run_interactive_mode "$workspace_root")
        if [[ -z "$profile" ]]; then
            log_info "Interactive mode cancelled by user"
            exit 0
        fi
    else
        # If no profile specified, use auto-detect mode
        if [[ -z "$profile" ]]; then
            if ! profile=$(run_auto_detect_mode "$workspace_root"); then
                log_info "Auto-detect mode cancelled by user"
                exit 0
            fi
            # Check if auto-detect was cancelled
            if [[ "$profile" == "CANCELLED" ]]; then
                log_info "Auto-detect mode cancelled by user"
                exit 0
            elif [[ -z "$profile" ]]; then
                log_error "Auto-detect mode returned empty profile"
                exit 1
            fi
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
