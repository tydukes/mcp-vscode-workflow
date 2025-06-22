# Voice Commands Reference

This document maps natural language voice commands to their corresponding actions in the MCP VS Code Workflow system.

## Profile Management Commands

### Starting Development Profiles

| Voice Command | Action | Script/Command |
|---------------|--------|----------------|
| "Start Python profile" | Launch Python development environment | `scripts/bootstrap.sh --profile python` |
| "Start documentation profile" | Launch technical writing environment | `scripts/bootstrap.sh --profile docs` |
| "Start infrastructure profile" | Launch DevOps/infrastructure environment | `scripts/bootstrap.sh --profile infra` |
| "Start CI/CD profile" | Launch continuous integration environment | `scripts/bootstrap.sh --profile cicd` |
| "Start bash profile" | Launch shell scripting environment | `scripts/bootstrap.sh --profile bash` |
| "Start shell profile" | Launch shell scripting environment | `scripts/bootstrap.sh --profile bash` |
| "Launch Python environment" | Launch Python development environment | `scripts/bootstrap.sh --profile python` |
| "Open docs workspace" | Launch technical writing environment | `scripts/bootstrap.sh --profile docs` |
| "Switch to Python mode" | Launch Python development environment | `scripts/bootstrap.sh --profile python` |

### Direct Profile Scripts

| Voice Command | Action | Script/Command |
|---------------|--------|----------------|
| "Run Python profile script" | Execute Python profile directly | `scripts/start-python-profile.sh` |
| "Run docs profile script" | Execute documentation profile directly | `scripts/start-docs-profile.sh` |
| "Run infrastructure script" | Execute infrastructure profile directly | `scripts/start-infra-profile.sh` |
| "Run CI/CD script" | Execute CI/CD profile directly | `scripts/start-cicd-profile.sh` |
| "Run bash script" | Execute bash profile directly | `scripts/start-bash-profile.sh` |

## Agent & Role Commands

### Invoking Specialized Agents

| Voice Command | Action | Role/Agent |
|---------------|--------|------------|
| "Invoke Python specialist" | Activate Python development assistant | Python Development Assistant |
| "Call documentation expert" | Activate documentation specialist | Documentation Specialist |
| "Get infrastructure expert" | Activate infrastructure assistant | Infrastructure & DevOps Assistant |
| "Invoke CI/CD expert" | Activate CI/CD pipeline expert | CI/CD Pipeline Expert |
| "Call shell expert" | Activate shell scripting expert | Shell Scripting Expert |
| "Get DevOps specialist" | Activate infrastructure assistant | Infrastructure & DevOps Assistant |
| "Invoke test engineer" | Activate testing capabilities | Python Development Assistant (testing) |
| "Call senior test engineer" | Activate advanced testing analysis | Python Development Assistant (testing) |

### Specific Task Commands

| Voice Command | Action | Role/Capability |
|---------------|--------|-----------------|
| "Generate test plan" | Create comprehensive testing strategy | Python Development Assistant (testing) |
| "Review this code" | Perform code analysis and review | Any specialist role (code-review) |
| "Analyze this bug" | Investigate and analyze bugs | Any specialist role (bug-analysis) |
| "Optimize performance" | Analyze and improve performance | Python Development Assistant (performance-optimization) |
| "Check security" | Perform security analysis | Infrastructure & DevOps Assistant (security-analysis) |
| "Generate documentation" | Create technical documentation | Documentation Specialist (documentation) |
| "Create API docs" | Generate API documentation | Documentation Specialist (api-documentation) |
| "Write user guide" | Create user documentation | Documentation Specialist (user-guides) |
| "Optimize pipeline" | Improve CI/CD workflows | CI/CD Pipeline Expert (pipeline-optimization) |
| "Review deployment" | Analyze deployment configuration | Infrastructure & DevOps Assistant (deployment-optimization) |

## System Management Commands

### Tool Management

| Voice Command | Action | Script/Command |
|---------------|--------|----------------|
| "Check tools" | Validate installed CLI tools | `scripts/check-tools.sh` |
| "Install MCP packages" | Install MCP via NPX | `scripts/install-mcp-npx.sh` |
| "Verify environment" | Check development environment | `scripts/check-tools.sh` |
| "Setup dependencies" | Install required packages | `scripts/install-mcp-npx.sh` |

### Environment Commands

| Voice Command | Action | Description |
|---------------|--------|-------------|
| "Bootstrap environment" | Initialize complete development setup | Run bootstrap with profile selection |
| "Reset workspace" | Clean and reinitialize workspace | Manual cleanup + bootstrap |
| "Reload configuration" | Refresh MCP and VS Code settings | Restart VS Code with active profile |

## Quick Actions

### Development Workflow

| Voice Command | Action | Context |
|---------------|--------|---------|
| "Run tests" | Execute test suite | Python/CI-CD profiles |
| "Build project" | Compile/build current project | Any development profile |
| "Deploy code" | Execute deployment pipeline | CI/CD/Infrastructure profiles |
| "Lint code" | Run code quality checks | Python/Bash profiles |
| "Format code" | Auto-format source code | Any development profile |
| "Commit changes" | Git commit with generated message | Any profile with git integration |
| "Push to remote" | Git push to remote repository | Any profile with git integration |

### Documentation Workflow

| Voice Command | Action | Context |
|---------------|--------|---------|
| "Generate README" | Create project README file | Documentation profile |
| "Update changelog" | Add entries to CHANGELOG | Documentation profile |
| "Create release notes" | Generate release documentation | Documentation/CI-CD profiles |
| "Document API" | Generate API documentation | Documentation profile |

### Infrastructure Workflow

| Voice Command | Action | Context |
|---------------|--------|---------|
| "Deploy infrastructure" | Apply infrastructure changes | Infrastructure profile |
| "Check deployment status" | Monitor deployment progress | Infrastructure/CI-CD profiles |
| "Scale services" | Adjust service scaling | Infrastructure profile |
| "Monitor logs" | View application/system logs | Infrastructure profile |

## Profile-Specific Commands

### Python Profile

- "Install Python packages" → Package management
- "Run pytest" → Execute Python tests
- "Create virtual environment" → Python environment setup
- "Debug Python code" → Python debugging session

### Documentation Profile

- "Convert to markdown" → Format conversion
- "Generate table of contents" → Documentation structure
- "Check spelling" → Documentation quality
- "Validate links" → Link verification

### Infrastructure Profile

- "Apply Terraform" → Infrastructure deployment
- "Check Kubernetes status" → Container orchestration
- "Monitor resources" → Resource utilization
- "Update containers" → Container management

### CI/CD Profile

- "Trigger build" → Pipeline execution
- "Check pipeline status" → Build monitoring
- "Deploy to staging" → Staging deployment
- "Promote to production" → Production deployment

### Bash Profile

- "Execute script" → Shell script execution
- "Check syntax" → Script validation
- "Monitor processes" → System monitoring
- "Manage permissions" → File system management

## Voice Command Tips

1. **Be Specific**: Use exact profile names when possible
2. **Context Matters**: Some commands work better in specific profiles
3. **Natural Language**: Commands support variations of the same intent
4. **Chaining**: Multiple commands can be executed in sequence
5. **Error Handling**: Voice system will suggest alternatives for unrecognized commands

## Configuration

Voice commands can be customized by:

1. Modifying script parameters in `scripts/` directory
2. Updating role definitions in `.mcp/roles.json`
3. Adding custom prompts in `.mcp/prompts/`
4. Configuring VS Code profiles in `.vscode/profiles/`

## Troubleshooting

| Issue | Voice Command | Action |
|-------|---------------|--------|
| Command not recognized | "Show available commands" | Display this documentation |
| Profile won't start | "Check tools" | Validate environment setup |
| MCP server issues | "Install MCP packages" | Reinstall MCP dependencies |
| Permission errors | "Fix permissions" | Adjust file/script permissions |

---

*For more detailed information about each profile and its capabilities, see the individual configuration files in the `.mcp/` directory.*
