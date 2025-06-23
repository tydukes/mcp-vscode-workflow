# MCP VS Code Workflow

[![CI](https://github.com/tydukes/mcp-vscode-workflow/workflows/CI/badge.svg)](https://github.com/tydukes/mcp-vscode-workflow/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.8+](https://img.shields.io/badge/python-3.8+-blue.svg)](https://www.python.org/downloads/)
[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)

A comprehensive development workflow system that integrates Model Context Protocol (MCP) servers with VS Code profiles to provide AI-enhanced, role-based development assistance.

## Overview

This project revolutionizes development workflows by combining:

- **Specialized VS Code Profiles** - Optimized settings and extensions for different development contexts
- **AI Role-Based Assistance** - Domain expert personas for code review, architecture, and specialized guidance  
- **MCP Server Integration** - Sequential thinking, task management, and real-time documentation
- **Automated Setup** - One-command environment configuration and server management

## Key Features

### 🎯 **Profile-Based Development**
- **Python Profile** - Web development, data science, API development
- **Infrastructure Profile** - Terraform, Kubernetes, cloud services  
- **Documentation Profile** - Technical writing, API docs, user guides
- **CI/CD Profile** - Pipeline optimization, deployment automation
- **Bash Profile** - System administration, automation scripting

### 🤖 **AI Role Specialization**
- **Python Development Assistant** - Code review, testing, performance optimization
- **Infrastructure Expert** - Architecture review, security analysis, cost optimization
- **Documentation Specialist** - Content strategy, technical writing, user experience
- **Shell Scripting Expert** - Automation, system administration, script optimization
- **CI/CD Pipeline Expert** - Workflow design, quality gates, deployment strategies

### ⚡ **MCP Server Powers**
- **Sequential Thinking** - Dynamic problem-solving with step-by-step reasoning
- **Task Master** - AI-driven development task management and workflow automation
- **Context7** - Up-to-date library documentation and framework guidance

## Quick Start

### 1. Prerequisites Check
```bash
# Verify requirements
./scripts/check-tools.sh
```

### 2. One-Command Setup
```bash
# For Python development
./scripts/bootstrap.sh --profile python

# For infrastructure work  
./scripts/bootstrap.sh --profile infra

# For documentation projects
./scripts/bootstrap.sh --profile docs
```

### 3. Start Developing
Your VS Code environment is now optimized with:
- ✅ Profile-specific settings and extensions
- ✅ MCP servers running and connected
- ✅ AI role assistance activated
- ✅ Context-aware productivity tools

## Project Structure

```text
mcp-vscode-workflow/
├── .vscode/profiles/          # VS Code profile configurations
│   ├── python.json           # Python development profile
│   ├── infra.json            # Infrastructure/DevOps profile
│   ├── docs.json             # Documentation profile
│   └── cicd.json             # CI/CD pipeline profile
├── .mcp/                      # MCP configurations and prompts
│   ├── config-*.json         # Profile-specific MCP settings
│   ├── roles.json            # AI role definitions
│   └── prompts/              # Role-based prompt templates
├── scripts/                   # Automation and setup scripts
│   ├── bootstrap.sh          # Master setup script
│   ├── install-mcp-npx.sh   # MCP server installation
│   └── start-*-profile.sh   # Individual profile launchers
└── docs/                      # Comprehensive documentation
    ├── setup.md              # Installation and prerequisites
    ├── profiles.md           # Profile guide and customization
    ├── mcp-servers.md        # MCP integration and troubleshooting
    └── roles.md              # AI role usage and examples
```

## Available Profiles

| Profile | Focus | Key Extensions | AI Role | Use Cases |
|---------|-------|----------------|---------|-----------|
| **Python** | Full-stack Python development | Python Extension Pack, Pylance, Python Debugger | Python Development Assistant | Web apps, APIs, data science, ML |
| **Infrastructure** | IaC and cloud services | Terraform, AWS Toolkit, Kubernetes | Infrastructure Expert | Cloud architecture, DevOps, containers |
| **Documentation** | Technical writing | Markdown All in One, Docs Authoring Pack | Documentation Specialist | API docs, user guides, content strategy |
| **CI/CD** | Pipeline automation | GitHub Actions, Docker, YAML | CI/CD Pipeline Expert | Build automation, deployment, testing |
| **Bash** | System administration | Bash IDE, shellcheck, Terminal Here | Shell Scripting Expert | Automation, system scripts, CLI tools |

## MCP Server Integration

### Sequential Thinking Server
```bash
npx @modelcontextprotocol/server-sequential-thinking
```
- Dynamic problem decomposition
- Step-by-step reasoning chains  
- Alternative solution exploration
- Iterative refinement guidance

### Task Master Server  
```bash
npx claude-task-master
```
- Intelligent task breakdown
- Progress tracking and milestones
- Workflow optimization suggestions
- Development productivity insights

### Context7 Server
```bash
npx context7  
```
- Real-time library documentation
- Framework-specific guidance
- API reference and examples
- Best practices recommendations

## AI Role-Based Assistance

### Context-Aware Activation
Roles automatically activate based on:
- **File types** - `.py` → Python Assistant, `.tf` → Infrastructure Expert
- **Project structure** - `requirements.txt` → Python, `Dockerfile` → Infrastructure  
- **Content analysis** - Function definitions → Code review, configs → Architecture

### Manual Role Selection
```bash
# Command Palette
Ctrl+Shift+P → "MCP: Select Role"

# Direct invocation
@python "Review this code for performance issues"
@infra "Analyze this Terraform configuration"  
@docs "Improve this API documentation"
```

### Multi-Role Collaboration
```bash
# Sequential consultation  
@python "Review code structure"
@security "Check for vulnerabilities"
@senior-architect "Evaluate overall design"

# Combined expertise
@infra @security "Review this Kubernetes deployment"
```

## Advanced Usage

### Custom Profiles
1. Copy existing profile: `cp .vscode/profiles/python.json .vscode/profiles/myprofile.json`
2. Customize settings and extensions
3. Create startup script: `cp scripts/start-python-profile.sh scripts/start-myprofile.sh`

### Environment Variables
```bash
export PROFILE_NAME="python"           # Default profile to load
export WORKSPACE_ROOT="/path/to/work"  # Workspace directory
export MCP_CONFIG_PATH="/.mcp"         # MCP configuration path
```

### Troubleshooting
```bash
# Verbose setup with debugging
./scripts/bootstrap.sh --profile python --verbose

# Check MCP server status
npx @modelcontextprotocol/server-sequential-thinking --status

# Validate configurations
./scripts/check-tools.sh
```

## Documentation

- **[Setup Guide](docs/setup.md)** - Prerequisites, installation, and troubleshooting
- **[Profiles Guide](docs/profiles.md)** - Profile summaries, triggers, and customization
- **[MCP Servers](docs/mcp-servers.md)** - NPX commands, integration, and troubleshooting  
- **[AI Roles](docs/roles.md)** - Role descriptions, usage patterns, and examples
- **[Configuration](docs/configuration.md)** - Advanced customization and settings
- **[Getting Started](docs/getting-started.md)** - Detailed walkthrough and examples

## Requirements

- **VS Code** 1.85+ with MCP extension
- **Node.js** 18+ for NPX package management
- **Git** 2.30+ for version control
- **Profile-specific tools** (Python, Docker, etc. as needed)

## License

See [LICENSE](LICENSE) for details.

---

**Ready to supercharge your development workflow?** Start with `./scripts/bootstrap.sh --profile <your-choice>` and experience AI-enhanced, context-aware development assistance!
