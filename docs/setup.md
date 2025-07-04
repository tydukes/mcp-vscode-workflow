# Setup Guide

## Prerequisites

Before setting up the MCP VS Code Workflow, ensure you have the following installed:

### Required Software

1. **Visual Studio Code** (version 1.85+)
   - Download from [code.visualstudio.com](https://code.visualstudio.com/)
   - Required for profile management and MCP integration

2. **Node.js** (version 18+)
   - Download from [nodejs.org](https://nodejs.org/)
   - Required for NPX package management and MCP servers

3. **Git** (version 2.30+)
   - Download from [git-scm.com](https://git-scm.com/)
   - Required for version control and some MCP integrations

4. **MCP Extension for VS Code**
   - Install the Model Context Protocol extension from the VS Code marketplace
   - Provides MCP client functionality within VS Code

### Optional Dependencies

Depending on your chosen profiles, you may need:

- **Python** (3.8+) - For Python development profile
- **Docker** - For infrastructure and CI/CD profiles
- **AWS CLI** - For cloud infrastructure work
- **Terraform** - For infrastructure as code
- **kubectl** - For Kubernetes operations

## Installation

### Quick Setup

Run the bootstrap script to automatically set up your environment:

```bash
# Clone the repository
git clone <repository-url>
cd mcp-vscode-workflow

# Make scripts executable
chmod +x scripts/*.sh

# Option 1: Quick setup (fastest, under 60 seconds)
./scripts/bootstrap.sh --quick

# Option 2: Interactive mode (recommended for new users)
./scripts/bootstrap.sh --interactive

# Option 3: Direct profile selection
./scripts/bootstrap.sh --profile python
```

### Interactive Mode (Recommended)

The interactive mode automatically detects your project type and guides you through setup:

```bash
./scripts/bootstrap.sh --interactive
```

**What the interactive mode does:**
1. **Auto-detects** your project type based on existing files
2. **Asks questions** about your development preferences
3. **Recommends** the best profile for your needs
4. **Shows preview** of tools and configurations to be installed
5. **Requests confirmation** before proceeding

**Example interaction:**
```
✓ Auto-detected project types: python, docs

1. What is your primary development activity?
   a) Writing Python code (web apps, data science, APIs)
   b) Managing infrastructure (Terraform, Kubernetes, cloud)
   ...
Your choice (a/b/c/d/e/f): a

2. Which tools do you expect to use most?
   a) Python, pip, virtual environments, pytest
   ...
Your choice (a/b/c/d/e/f): a

=== Recommendation ===
Based on your project and preferences, we recommend: python

=== Installation Preview ===
Profile: python
Tools and configurations that will be installed/configured:
• Python extension pack for VS Code
• Pylance language server
• Python debugger and test explorer
...

Do you want to proceed with the python profile installation? (y/n): y
```

### Manual Setup

If you prefer manual installation:

1. **Check Prerequisites**
   ```bash
   ./scripts/check-tools.sh
   ```

2. **Install MCP Servers**
   ```bash
   ./scripts/install-mcp-npx.sh
   ```

3. **Launch a Profile**
   ```bash
   ./scripts/start-python-profile.sh
   ```

## Bootstrap Script Options

The `bootstrap.sh` script supports several options:

```bash
./scripts/bootstrap.sh [OPTIONS]

Options:
  --profile <name>     Use specific profile (bash, cicd, docs, infra, python, node)
  --interactive        Launch interactive mode with auto-detection and wizard
  --quick              Quick setup with minimal validation (uses Python profile)
  --help              Show this help message

Examples:
  ./scripts/bootstrap.sh --quick                     # Quick setup (under 60 seconds)
  ./scripts/bootstrap.sh --interactive               # Interactive wizard (recommended)
  ./scripts/bootstrap.sh --profile python            # Direct profile selection
  ./scripts/bootstrap.sh --profile docs              # Documentation profile
```

### Quick Setup Mode Benefits

- **Ultra fast**: Complete setup in under 60 seconds
- **Minimal validation**: Skips time-consuming tool checks
- **Python focused**: Automatically uses Python development profile
- **Essential setup**: Configures core development environment
- **Next steps guidance**: Shows immediate actions to take after setup

### Interactive Mode Benefits

- **Zero configuration**: No need to know which profile to choose
- **Auto-detection**: Automatically identifies your project type
- **Guided setup**: Step-by-step wizard for new users
- **Smart recommendations**: Suggests optimal profile based on your needs
- **Preview mode**: Shows exactly what will be installed before proceeding
- **Educational**: Learn about available profiles and their purposes

## Verification

After setup, verify your installation:

1. **Check MCP Servers**
   ```bash
   npx @modelcontextprotocol/server-sequential-thinking --version
   npx claude-task-master --version
   npx context7 --version
   ```

2. **Verify VS Code Profile**
   - Open VS Code
   - Check that the correct profile is active
   - Verify MCP extension is running

3. **Test MCP Integration**
   - Open a file relevant to your profile
   - Try using MCP commands in the Command Palette
   - Check MCP status in the status bar

## Troubleshooting

### Common Issues

**Node.js/NPX not found:**
```bash
# On macOS with Homebrew
brew install node

# On Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```

**Permission denied on scripts:**
```bash
chmod +x scripts/*.sh
```

**MCP servers fail to install:**
```bash
# Clear npm cache
npm cache clean --force

# Try with force flag
./scripts/bootstrap.sh --profile <name> --force
```

**VS Code profile not loading:**
- Ensure VS Code is updated to latest version
- Check that profile files exist in `.vscode/profiles/`
- Verify MCP extension is installed and enabled

### Getting Help

If you encounter issues:

1. Check the logs in VS Code Developer Console
2. Run scripts with `--verbose` flag for detailed output
3. Verify all prerequisites are met with `./scripts/check-tools.sh`
4. Check the [troubleshooting section](mcp-servers.md#troubleshooting) in MCP servers documentation

## Next Steps

Once setup is complete:

1. Familiarize yourself with available [profiles](profiles.md)
2. Learn about [MCP servers and commands](mcp-servers.md)
3. Explore [role-based workflows](roles.md)
4. Customize your workflow using the [configuration guide](configuration.md)
