# CI/CD Setup Documentation

## Overview

This project implements a comprehensive CI/CD pipeline using GitHub Actions and pre-commit hooks to ensure code quality, security, and reliability. The setup includes automated testing, linting, security scanning, and branch protection rules.

## Components

### 1. GitHub Actions Workflows

#### Main CI Pipeline (`.github/workflows/ci.yml`)

**Purpose:** Primary continuous integration pipeline that runs on all pushes and pull requests.

**Jobs:**
- **lint-and-test:** Core validation including:
  - Tool validation with `check-tools.sh`
  - Shell script linting with `shellcheck`
  - JSON validation with `jq`
  - Python testing with `uv run pytest` (if Python files exist)
  - Coverage reporting

- **security-scan:** Security validation including:
  - Python security scanning with `bandit`
  - Shell script security analysis
  - Secret detection with TruffleHog

- **markdown-lint:** Documentation quality checks

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests targeting `main` or `develop`

**Failure Behavior:** Blocks merges if any checks fail

#### Branch Protection (`.github/workflows/branch-protection.yml`)

**Purpose:** Enforces branch protection rules and PR requirements.

**Checks:**
- CI workflow completion status
- PR title format (conventional commits)
- Required file validations
- Branch naming conventions
- PR size limits
- Merge conflict detection

**Requirements:**
- PR titles must follow conventional commit format: `feat:`, `fix:`, `docs:`, etc.
- Branch names should follow patterns: `feature/description`, `fix/bug-name`, or `123-issue-description`
- No merge conflicts with target branch
- All CI checks must pass

#### Auto-merge (`.github/workflows/auto-merge.yml`)

**Purpose:** Automatically approves and merges safe changes.

**Safe Change Criteria:**
- Documentation updates (`.md` files)
- Configuration files (`pyproject.toml`, `.gitignore`, etc.)
- Test files
- Non-critical workflow files
- Small size (≤10 files, ≤200 lines)

**Auto-merge Triggers:**
- Dependabot PRs for patch/minor updates
- PRs with `[auto-merge]` in title (if changes are safe)

### 2. Pre-commit Hooks (`.pre-commit-config.yaml`)

**Purpose:** Client-side validation before commits to catch issues early.

**Hook Categories:**

#### Built-in Hooks
- Trailing whitespace removal
- End-of-file fixing
- YAML/JSON validation
- Merge conflict detection
- Large file checking
- Executable permissions

#### Language-Specific Hooks
- **Shell Scripts:** `shellcheck` linting
- **JSON:** Formatting and validation with `jq`
- **Markdown:** Linting with `markdownlint`
- **Python:** `black`, `isort`, `flake8`, `bandit` (if Python files exist)

#### Custom Project Hooks
- **Tool Validation:** Runs `check-tools.sh --profile bash`
- **MCP Config Validation:** Validates all `.mcp/*.json` files
- **Profile Validation:** Validates `.vscode/profiles/*.json` files
- **Script Permissions:** Ensures shell scripts are executable
- **Documentation Links:** Checks for broken internal links
- **Secret Detection:** Scans for accidentally committed secrets

### 3. Configuration Files

#### Python Project (`pyproject.toml`)
- Project metadata and dependencies
- Testing configuration with pytest
- Code quality tool settings (black, isort, flake8, bandit)
- Coverage reporting configuration

#### Makefile
- Convenient commands for common tasks
- Local CI simulation with `make ci-local`
- Profile bootstrapping commands
- Development setup automation

#### Secrets Baseline (`.secrets.baseline`)
- Baseline for the detect-secrets tool
- Tracks reviewed and approved "secrets" (like API examples)

## Usage

### Setting Up Pre-commit Hooks

1. **Install pre-commit:**
   ```bash
   pip install pre-commit
   # or
   uv pip install pre-commit
   ```

2. **Install hooks:**
   ```bash
   pre-commit install
   make setup-hooks  # Alternative using Makefile
   ```

3. **Run hooks manually:**
   ```bash
   pre-commit run --all-files
   make run-hooks  # Alternative using Makefile
   ```

### Local CI Simulation

Run the full CI pipeline locally before pushing:

```bash
make ci-local
```

This executes:
1. Tool validation
2. Configuration validation
3. Linting and formatting
4. Security checks
5. Tests with coverage
6. Pre-commit hooks

### Common Commands

```bash
# Quick validation
make quick-check

# Auto-fix formatting issues
make fix

# Run specific checks
make lint
make test
make security
make validate-configs

# Bootstrap development environment
make dev-setup
make bootstrap-python  # or other profiles
```

### Branch and PR Workflow

1. **Create Feature Branch:**
   ```bash
   git checkout -b feature/new-mcp-integration
   # or
   git checkout -b fix/shellcheck-warnings
   # or
   git checkout -b 123-update-documentation
   ```

2. **Make Changes and Commit:**
   ```bash
   # Pre-commit hooks run automatically
   git add .
   git commit -m "feat: add new MCP server integration"
   ```

3. **Push and Create PR:**
   ```bash
   git push origin feature/new-mcp-integration
   # Create PR with conventional commit title
   ```

4. **PR Requirements:**
   - Title: `feat: add new MCP server integration`
   - All CI checks pass
   - No merge conflicts
   - Reasonable size (< 50 files, < 1000 lines for manual review)

### Auto-merge Criteria

Changes that qualify for auto-merge:
- Documentation updates
- Test additions/updates
- Configuration tweaks
- Dependency updates (patch/minor)
- Pre-commit hook updates

To request auto-merge for safe changes:
```bash
git commit -m "docs: update API documentation [auto-merge]"
```

## Troubleshooting

### Pre-commit Hook Failures

**Shellcheck errors:**
```bash
# Fix shell script issues
shellcheck scripts/problematic-script.sh
# Or disable specific warnings
# shellcheck disable=SC2034
```

**JSON validation errors:**
```bash
# Validate and fix JSON
jq . .mcp/config-python.json
```

**Python formatting:**
```bash
# Auto-fix formatting
make format
# or manually
black .
isort .
```

**Failed tool validation:**
```bash
# Check what tools are missing
./scripts/check-tools.sh --profile bash
# Install missing tools as suggested
```

### CI Failures

**Tool validation failure:**
- Check if `check-tools.sh` script is executable
- Verify script syntax with `shellcheck`
- Ensure all required tools are available in CI environment

**Test failures:**
- Run tests locally: `make test`
- Check coverage: `make test-coverage`
- Verify test files are in correct locations

**Security scan failures:**
- Review bandit report for Python security issues
- Check for accidentally committed secrets
- Update `.secrets.baseline` if needed

**JSON validation errors:**
- Validate files locally: `make validate-configs`
- Fix JSON syntax errors
- Ensure all JSON files are properly formatted

### Branch Protection Issues

**PR title format:**
```bash
# Wrong: "Update documentation"
# Right: "docs: update API documentation"
```

**Branch naming:**
```bash
# Wrong: "my-changes"
# Right: "feature/add-mcp-server" or "fix/json-validation" or "123-update-docs"
```

**Large PR warnings:**
- Consider breaking large changes into smaller PRs
- Focus on single responsibility per PR
- Use feature branches for complex changes

## Maintenance

### Updating Dependencies

**Pre-commit hooks:**
```bash
pre-commit autoupdate
make update-hooks
```

**Python dependencies:**
```bash
# Update in pyproject.toml, then:
uv pip install -e ".[dev]"
```

**GitHub Actions:**
```bash
# Check for newer action versions in .github/workflows/
# Update version tags (e.g., v3 -> v4)
```

### Adding New Checks

**New pre-commit hook:**
1. Add to `.pre-commit-config.yaml`
2. Test with `pre-commit run --all-files`
3. Update documentation

**New CI job:**
1. Add job to `.github/workflows/ci.yml`
2. Test in feature branch
3. Update branch protection rules if needed

**New tool requirement:**
1. Add to `scripts/check-tools.sh`
2. Update installation instructions
3. Add to CI environment setup

## Security Considerations

### Secret Management
- Never commit real secrets/credentials
- Use `.secrets.baseline` for approved patterns
- Review secret detection alerts carefully

### Dependency Security
- Dependabot automatically creates PRs for security updates
- Review and approve security-related dependency updates promptly
- Monitor bandit reports for Python security issues

### Access Control
- Branch protection prevents direct pushes to main/develop
- Required status checks ensure quality gates
- Auto-merge only applies to safe, small changes

## Best Practices

### For Contributors
1. Run `make dev-setup` for initial setup
2. Use `make quick-check` before pushing
3. Follow conventional commit format
4. Keep PRs focused and reasonably sized
5. Update documentation for significant changes

### For Maintainers
1. Review auto-merge configurations regularly
2. Monitor CI performance and adjust timeouts
3. Keep dependencies updated
4. Review and update security baselines
5. Maintain clear contribution guidelines

This CI/CD setup ensures code quality while maintaining developer productivity through automation and clear feedback loops.
