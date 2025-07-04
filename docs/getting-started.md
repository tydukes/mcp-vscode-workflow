# Getting Started Guide

## Overview

This guide will help you set up and use the MCP VS Code Workflow system for enhanced development productivity.

## Prerequisites

- VS Code with MCP extension support
- Node.js (for script execution)
- Git (for version control)

## Quick Start

1. **Choose Your Profile**
   ```bash
   # For Python development
   ./scripts/start-python-profile.sh

   # For documentation work
   ./scripts/start-docs-profile.sh

   # For infrastructure/DevOps
   ./scripts/start-infra-profile.sh
   ```

2. **Customize Your Workflow**
   - Edit profile configurations in `.vscode/profiles/`
   - Modify MCP prompts in `.mcp/prompts/`
   - Add new automation scripts to `scripts/`

## Profile Configurations

Each profile includes:
- VS Code settings optimized for the task
- Recommended extensions
- MCP integrations
- Custom key bindings

## MCP Prompt Templates

Use the prompt templates in `.mcp/prompts/` for:
- Code reviews
- Documentation generation
- Bug analysis
- And more...

## Default Settings

The workspace is preconfigured with settings that:
- **Disable automatic session summaries** - No markdown files are created after AI assistant sessions
- **Optimize profile-specific workflows** - Each profile has tailored settings and extensions
- **Enable MCP integrations** - AI assistants are connected to relevant development tools

You can customize these settings in `.vscode/settings.json` or through the VS Code preferences.

## Next Steps

- [Configuration Guide](configuration.md)
- [Custom Profiles](custom-profiles.md)
- [MCP Integration](mcp-integration.md)
