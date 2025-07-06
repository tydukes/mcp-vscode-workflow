# 🚀 MCP VS Code Workflow: Getting Started

![Demo GIF](docs/assets/demo.gif) <!-- Replace with actual GIF if available -->

A lightning-fast, AI-powered development workflow for VS Code. Switch between Python, Infrastructure, Docs, CI/CD, and Bash profiles—each with tailored settings, extensions, and AI role assistants. One command, three steps, instant productivity.

---

## ⚡ 30-Second Overview

- **One-command setup** for any development context
- **AI role-based assistance**: code review, docs, infra, CI/CD, shell
- **MCP servers**: sequential thinking, task management, real-time docs
- **Profile switching**: Python, Infra, Docs, CI/CD, Bash

---

## 🛠️ Three-Step Setup

1. **Check Prerequisites**
   ```bash
   ./scripts/check-tools.sh
   ```
2. **Run Bootstrap (Pick a Profile)**
   ```bash
   # Python
   ./scripts/bootstrap.sh --profile python
   # Infrastructure
   ./scripts/bootstrap.sh --profile infra
   # Documentation
   ./scripts/bootstrap.sh --profile docs
   # CI/CD
   ./scripts/bootstrap.sh --profile cicd
   # Bash
   ./scripts/bootstrap.sh --profile bash
   ```
3. **Start Developing!**
   - VS Code auto-configures with extensions, settings, and MCP servers
   - AI role assistant activates for your context

---

## 🧰 Quick Reference: Post-Setup Commands

- **Switch Profile:**
  ```bash
  ./scripts/bootstrap.sh --profile <profile>
  ```
- **Start Profile Directly:**
  ```bash
  ./scripts/start-python-profile.sh
  ./scripts/start-infra-profile.sh
  ./scripts/start-docs-profile.sh
  ./scripts/start-cicd-profile.sh
  ./scripts/start-bash-profile.sh
  ```
- **Check Tools:**
  ```bash
  ./scripts/check-tools.sh
  ```
- **Install MCP Servers:**
  ```bash
  ./scripts/install-mcp-npx.sh
  ```
- **Run MCP Servers Individually:**
  ```bash
  npx @modelcontextprotocol/server-sequential-thinking
  npx claude-task-master
  npx context7
  ```

---

## 🛑 Troubleshooting

**Profile Not Loading**

- Ensure profile exists: `ls .vscode/profiles/`
- Check script permissions: `chmod +x scripts/*.sh`
- Validate JSON: open profile in VS Code for errors
- Restart VS Code after switching profiles
- Review VS Code logs for errors

**Extensions Not Installing**

- Check internet connection
- Try manual install from VS Code marketplace
- Verify extension compatibility with your VS Code version

**MCP Server Not Connecting**

- Run `./scripts/install-mcp-npx.sh` to install servers
- Check server status: `npx @modelcontextprotocol/server-sequential-thinking --status`
- Ensure Node.js 18+ is installed

**Settings Not Applied**

- Restart VS Code
- Check for conflicting user settings
- Clear VS Code workspace cache

**Script Errors**

- Ensure all scripts are executable: `chmod +x scripts/*.sh`
- Run with `--verbose` for debug output
- Check for missing dependencies with `./scripts/check-tools.sh`

---

## 📚 Advanced Guides (Per Profile)

- [Python Profile Guide](docs/profiles.md#python-development-profile)
- [Infrastructure Profile Guide](docs/profiles.md#infrastructure-profile)
- [Documentation Profile Guide](docs/profiles.md#documentation-profile)
- [CI/CD Profile Guide](docs/profiles.md#cicd-profile)
- [Bash Profile Guide](docs/profiles.md#bashshell-profile)
- [MCP Servers & NPX Commands](docs/mcp-servers.md)
- [AI Roles & Usage](docs/roles.md)
- [Full Setup & Configuration](docs/setup.md)

---

## ✅ Acceptance Criteria (Summary)

- **Setup in 3 steps or fewer**
- **Top 5 troubleshooting issues covered**
- **Profile-specific advanced guides linked**
- **Sample commands for immediate use**
- **Single README.md for all getting started info**

See [Full Acceptance Criteria](docs/acceptance-criteria.md) for details.

---

**Ready to supercharge your workflow?**

Run `./scripts/bootstrap.sh --profile <your-choice>` and start building with AI-powered, context-aware assistance!
