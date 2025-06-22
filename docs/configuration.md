# Configuration Guide

## VS Code Profiles

### Creating Custom Profiles

1. Copy an existing profile from `.vscode/profiles/`
2. Modify settings and extensions as needed
3. Create a corresponding startup script in `scripts/`

### Profile Structure

```json
{
  "name": "Profile Name",
  "settings": {
    // VS Code settings
  },
  "extensions": {
    "recommendations": [
      // Extension IDs
    ]
  }
}
```

## MCP Prompt Configuration

### Template Variables

Use these variables in your prompts:
- `{{CODE_BLOCK}}` - The selected code
- `{{LANGUAGE}}` - Programming language
- `{{CONTEXT}}` - Additional context
- `{{ERROR_MESSAGE}}` - Error details (for debugging)

### Creating Custom Prompts

1. Create a new `.md` file in `.mcp/prompts/`
2. Use template variables for dynamic content
3. Follow the established prompt structure

## Script Configuration

### Environment Variables

Scripts support these environment variables:
- `PROFILE_NAME` - Name of the profile to load
- `WORKSPACE_ROOT` - Root directory of the workspace
- `MCP_CONFIG_PATH` - Path to MCP configuration

### Adding New Scripts

1. Create executable shell script in `scripts/`
2. Follow the naming convention: `start-{profile}-profile.sh`
3. Include profile loading and MCP setup logic
