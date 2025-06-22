# Development Profiles

## Overview

The MCP VS Code Workflow provides specialized development profiles, each optimized for specific types of work. Each profile includes custom VS Code settings, recommended extensions, MCP integrations, and role-based AI assistance.

## Available Profiles

### Python Development Profile

**Purpose:** Full-stack Python development with testing, debugging, and deployment support.

**Optimized for:**
- Web development (Django, Flask, FastAPI)
- Data science and machine learning
- API development and testing
- Package management and virtual environments

**Key Features:**
- Python-specific linting and formatting
- Integrated testing frameworks (pytest, unittest)
- Virtual environment management
- Code completion and type checking
- Performance profiling tools

**Trigger Command:**
```bash
./scripts/start-python-profile.sh
```

**Extensions Included:**
- Python Extension Pack
- Pylance
- Python Debugger
- autoDocstring
- Python Test Explorer

### Documentation Profile

**Purpose:** Technical writing, documentation generation, and content creation.

**Optimized for:**
- Markdown documentation
- API documentation
- User guides and tutorials
- Code documentation generation
- Static site generation

**Key Features:**
- Markdown preview and editing
- Documentation generators
- Spell checking and grammar
- Diagram creation tools
- Link validation

**Trigger Command:**
```bash
./scripts/start-docs-profile.sh
```

**Extensions Included:**
- Markdown All in One
- markdownlint
- Docs Authoring Pack
- Mermaid Preview
- Code Spell Checker

### CI/CD Profile

**Purpose:** Continuous integration, deployment automation, and DevOps workflows.

**Optimized for:**
- Pipeline configuration
- Build automation
- Testing automation
- Deployment scripting
- Monitoring and alerting

**Key Features:**
- YAML/JSON schema validation
- Pipeline visualization
- Docker integration
- Cloud provider tools
- Secret management

**Trigger Command:**
```bash
./scripts/start-cicd-profile.sh
```

**Extensions Included:**
- YAML
- Docker
- GitHub Actions
- Azure Pipelines
- GitLab Workflow

### Infrastructure Profile

**Purpose:** Infrastructure as Code (IaC) and cloud resource management.

**Optimized for:**
- Terraform development
- AWS/Azure/GCP management
- Kubernetes operations
- Network configuration
- Security compliance

**Key Features:**
- Terraform syntax and validation
- Cloud provider integrations
- Kubernetes manifest editing
- Infrastructure visualization
- Cost optimization tools

**Trigger Command:**
```bash
./scripts/start-infra-profile.sh
```

**Extensions Included:**
- HashiCorp Terraform
- AWS Toolkit
- Azure Account
- Kubernetes
- YAML

### Bash/Shell Profile

**Purpose:** System administration, automation scripting, and command-line tool development.

**Optimized for:**
- Shell script development
- System automation
- Command-line utilities
- Log analysis
- System monitoring

**Key Features:**
- Shell script linting
- Command completion
- Man page integration
- Terminal enhancements
- Process monitoring

**Trigger Command:**
```bash
./scripts/start-bash-profile.sh
```

**Extensions Included:**
- Bash IDE
- shellcheck
- Shell Syntax
- Terminal Here
- Command Runner

## Profile Triggers and Activation

### Automatic Detection

Profiles can be automatically triggered based on:

**File Types:**
- `.py` files → Python profile
- `.md`, `.rst` files → Documentation profile
- `.yml`, `.yaml` with CI keywords → CI/CD profile
- `.tf`, `.hcl` files → Infrastructure profile
- `.sh`, `.bash` files → Bash profile

**Directory Structure:**
- `requirements.txt`, `pyproject.toml` → Python profile
- `docs/`, `README.md` → Documentation profile
- `.github/workflows/`, `Jenkinsfile` → CI/CD profile
- `terraform/`, `k8s/` → Infrastructure profile

**Git Repository Patterns:**
- Python packages with `setup.py`
- Documentation sites with `mkdocs.yml`
- Infrastructure repos with `.terraform/`

### Manual Activation

Force a specific profile:

```bash
# Using bootstrap script
./scripts/bootstrap.sh --profile python

# Direct profile scripts
./scripts/start-python-profile.sh
./scripts/start-docs-profile.sh
./scripts/start-cicd-profile.sh
./scripts/start-infra-profile.sh
./scripts/start-bash-profile.sh
```

### Profile Switching

Switch between profiles without restarting VS Code:

1. **Command Palette:** `Ctrl+Shift+P` → "Switch Profile"
2. **Status Bar:** Click on current profile name
3. **Script:** Run new profile script while VS Code is open

## Profile Customization

### Creating Custom Profiles

1. **Copy Base Profile:**
   ```bash
   cp .vscode/profiles/python.json .vscode/profiles/myprofile.json
   ```

2. **Edit Configuration:**
   ```json
   {
     "name": "My Custom Profile",
     "settings": {
       "workbench.colorTheme": "Dark+ (default dark)",
       "editor.fontSize": 14
     },
     "extensions": {
       "recommendations": [
         "ms-python.python"
       ]
     }
   }
   ```

3. **Create Startup Script:**
   ```bash
   cp scripts/start-python-profile.sh scripts/start-myprofile.sh
   # Edit script to reference your new profile
   ```

### Profile Settings Override

Common settings to customize:

- **Theme and Appearance:**
  ```json
  "workbench.colorTheme": "GitHub Dark",
  "workbench.iconTheme": "material-icon-theme"
  ```

- **Editor Behavior:**
  ```json
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "editor.formatOnSave": true
  ```

- **Terminal Configuration:**
  ```json
  "terminal.integrated.defaultProfile.osx": "zsh",
  "terminal.integrated.fontSize": 12
  ```

## Profile-Specific MCP Integration

Each profile includes specialized MCP configurations:

### Python Profile MCP Features
- Code review with PEP 8 compliance
- Automated testing generation
- Documentation string generation
- Performance optimization suggestions

### Documentation Profile MCP Features
- Content structure recommendations
- Grammar and style checking
- Cross-reference validation
- SEO optimization suggestions

### CI/CD Profile MCP Features
- Pipeline optimization analysis
- Security scanning integration
- Deployment strategy recommendations
- Performance monitoring setup

### Infrastructure Profile MCP Features
- Cost optimization analysis
- Security compliance checking
- Resource dependency mapping
- Best practices validation

### Bash Profile MCP Features
- Script optimization suggestions
- Security vulnerability scanning
- Performance profiling
- Error handling improvements

## Troubleshooting Profiles

### Profile Not Loading

1. Check profile exists: `ls .vscode/profiles/`
2. Verify JSON syntax: Use VS Code JSON validator
3. Check script permissions: `chmod +x scripts/*.sh`
4. Review VS Code logs for errors

### Extensions Not Installing

1. Check internet connection
2. Verify VS Code marketplace access
3. Try manual extension installation
4. Check extension compatibility

### Settings Not Applied

1. Restart VS Code after profile change
2. Check for conflicting user settings
3. Verify profile precedence order
4. Clear VS Code workspace cache

## Next Steps

- Learn about [MCP servers and commands](mcp-servers.md)
- Explore [role-based AI assistance](roles.md)
- Customize profiles using the [configuration guide](configuration.md)
