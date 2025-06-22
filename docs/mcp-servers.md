# MCP Servers Guide

## Overview

The MCP VS Code Workflow integrates three powerful Model Context Protocol servers to enhance your development experience with AI-driven assistance.

## Available MCP Servers

### Sequential Thinking Server

**Package:** `@modelcontextprotocol/server-sequential-thinking`

**Purpose:** Dynamic and reflective problem-solving with step-by-step reasoning.

**Capabilities:**
- Break down complex problems into manageable steps
- Provide reasoning chains for development decisions
- Offer alternative approaches to coding challenges
- Support iterative refinement of solutions

**Use Cases:**
- Algorithm design and optimization
- Architecture decision making
- Debugging complex issues
- Code refactoring strategies

**Installation:**
```bash
npx @modelcontextprotocol/server-sequential-thinking
```

### Task Master Server

**Package:** `claude-task-master`

**Source:** [GitHub - eyaltoledano/claude-task-master](https://github.com/eyaltoledano/claude-task-master)

**Purpose:** AI-driven development task management and workflow automation.

**Capabilities:**
- Intelligent task breakdown and prioritization
- Progress tracking and milestone management
- Automated workflow suggestions
- Integration with development tools

**Use Cases:**
- Project planning and estimation
- Sprint planning and task allocation
- Development workflow optimization
- Progress monitoring and reporting

**Installation:**
```bash
npx claude-task-master
```

### Context7 Server

**Package:** `context7`

**Source:** [GitHub - upstash/context7](https://github.com/upstash/context7)

**Purpose:** Up-to-date code documentation and library reference.

**Capabilities:**
- Real-time library documentation lookup
- API reference and examples
- Framework-specific guidance
- Code pattern recommendations

**Use Cases:**
- Learning new libraries and frameworks
- API integration and usage
- Best practices and patterns
- Troubleshooting library issues

**Installation:**
```bash
npx context7
```

## NPX Commands Reference

### Installation Commands

**Install all MCP servers:**
```bash
# Automated installation
./scripts/install-mcp-npx.sh

# Manual installation
npx @modelcontextprotocol/server-sequential-thinking
npx claude-task-master
npx context7
```

**Install specific servers:**
```bash
# Sequential Thinking only
npx @modelcontextprotocol/server-sequential-thinking

# Task Master only
npx claude-task-master

# Context7 only
npx context7
```

### Running Commands

**Start servers individually:**
```bash
# Start Sequential Thinking server
npx @modelcontextprotocol/server-sequential-thinking --port 3001

# Start Task Master server
npx claude-task-master --port 3002

# Start Context7 server
npx context7 --port 3003
```

**Server management:**
```bash
# Check server status
npx @modelcontextprotocol/server-sequential-thinking --status

# Stop servers
pkill -f "sequential-thinking"
pkill -f "task-master"
pkill -f "context7"

# Restart all servers
./scripts/install-mcp-npx.sh --restart
```

### Configuration Commands

**Update server configurations:**
```bash
# Update Sequential Thinking config
npx @modelcontextprotocol/server-sequential-thinking --config-update

# Validate configurations
npx claude-task-master --validate-config

# Reset to defaults
npx context7 --reset-config
```

## Server Integration

### VS Code Integration

Each MCP server integrates with VS Code through the MCP extension:

**Command Palette Access:**
- `Ctrl+Shift+P` → "MCP: Sequential Thinking"
- `Ctrl+Shift+P` → "MCP: Task Master" 
- `Ctrl+Shift+P` → "MCP: Context7"

**Keyboard Shortcuts:**
- `Ctrl+Alt+S` → Sequential Thinking analysis
- `Ctrl+Alt+T` → Task Master planning
- `Ctrl+Alt+C` → Context7 documentation lookup

**Status Bar Integration:**
- MCP server status indicators
- Quick access to server commands
- Real-time connection monitoring

### Profile-Specific Usage

**Python Profile:**
```bash
# Code analysis with Sequential Thinking
npx @modelcontextprotocol/server-sequential-thinking --analyze-python

# Task planning for Python projects
npx claude-task-master --project-type python

# Python library documentation
npx context7 --language python
```

**Documentation Profile:**
```bash
# Content structure analysis
npx @modelcontextprotocol/server-sequential-thinking --analyze-content

# Documentation task management
npx claude-task-master --project-type docs

# Documentation framework help
npx context7 --language markdown
```

**CI/CD Profile:**
```bash
# Pipeline optimization
npx @modelcontextprotocol/server-sequential-thinking --analyze-pipeline

# CI/CD task planning
npx claude-task-master --project-type cicd

# CI/CD tool documentation
npx context7 --language yaml
```

## Troubleshooting

### Common Issues

**Server Installation Failures:**

*Error: Package not found*
```bash
# Clear npm cache
npm cache clean --force

# Update npm
npm update -g npm

# Try alternative installation
npm install -g @modelcontextprotocol/server-sequential-thinking
```

*Error: Permission denied*
```bash
# Fix npm permissions (macOS/Linux)
sudo chown -R $(whoami) ~/.npm

# Or use nvm for better node management
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
```

**Server Connection Issues:**

*Error: Cannot connect to MCP server*
```bash
# Check if servers are running
ps aux | grep -E "(sequential-thinking|task-master|context7)"

# Check port availability
lsof -i :3001 -i :3002 -i :3003

# Restart MCP extension in VS Code
Ctrl+Shift+P → "Developer: Reload Window"
```

*Error: Server timeout*
```bash
# Increase timeout in VS Code settings
"mcp.serverTimeout": 30000

# Check network connectivity
ping github.com

# Verify firewall settings
```

**Configuration Issues:**

*Error: Invalid configuration*
```bash
# Validate JSON configuration
cat .mcp/config-python.json | jq .

# Reset to default configuration
rm .mcp/config-*.json
./scripts/bootstrap.sh --profile python
```

*Error: Missing dependencies*
```bash
# Check Node.js version
node --version  # Should be 18+

# Check VS Code version
code --version  # Should be 1.85+

# Reinstall MCP extension
Ctrl+Shift+P → "Extensions: Reinstall Extension"
```

### Performance Optimization

**Improve Server Response Times:**

1. **Increase Memory Allocation:**
   ```bash
   export NODE_OPTIONS="--max-old-space-size=4096"
   npx @modelcontextprotocol/server-sequential-thinking
   ```

2. **Enable Caching:**
   ```json
   {
     "mcp.caching.enabled": true,
     "mcp.caching.maxAge": 3600
   }
   ```

3. **Optimize Network Settings:**
   ```json
   {
     "mcp.network.timeout": 10000,
     "mcp.network.retries": 3
   }
   ```

**Monitor Server Performance:**
```bash
# Check CPU usage
top -p $(pgrep -f sequential-thinking)

# Monitor memory usage
ps aux | grep -E "(sequential-thinking|task-master|context7)" | awk '{print $6}'

# Check response times
curl -w "%{time_total}\n" -o /dev/null -s http://localhost:3001/health
```

### Advanced Configuration

**Custom Server Ports:**
```bash
# Set custom ports in environment
export MCP_SEQUENTIAL_PORT=4001
export MCP_TASKMASTER_PORT=4002
export MCP_CONTEXT7_PORT=4003

# Start with custom ports
npx @modelcontextprotocol/server-sequential-thinking --port $MCP_SEQUENTIAL_PORT
```

**Proxy Configuration:**
```bash
# Set proxy for corporate environments
export HTTP_PROXY=http://proxy.company.com:8080
export HTTPS_PROXY=http://proxy.company.com:8080

# Configure npm proxy
npm config set proxy http://proxy.company.com:8080
npm config set https-proxy http://proxy.company.com:8080
```

**SSL/TLS Configuration:**
```bash
# Generate self-signed certificates for HTTPS
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365

# Start server with HTTPS
npx @modelcontextprotocol/server-sequential-thinking --ssl --cert cert.pem --key key.pem
```

## Getting Help

### Debug Information Collection

When reporting issues, include:

```bash
# System information
uname -a
node --version
npm --version
code --version

# MCP server status
npx @modelcontextprotocol/server-sequential-thinking --version
npx claude-task-master --version
npx context7 --version

# VS Code MCP extension logs
# Help → Toggle Developer Tools → Console
```

### Support Resources

- **Sequential Thinking:** [MCP Servers Repository](https://github.com/modelcontextprotocol/servers)
- **Task Master:** [Claude Task Master Issues](https://github.com/eyaltoledano/claude-task-master/issues)
- **Context7:** [Upstash Context7 Support](https://github.com/upstash/context7/issues)
- **General MCP:** [Model Context Protocol Documentation](https://modelcontextprotocol.io/)

## Next Steps

- Explore [role-based AI assistance](roles.md)
- Learn about [profile customization](profiles.md)
- Review the [configuration guide](configuration.md) for advanced settings
