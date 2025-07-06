# Contributing to MCP VS Code Workflow

Thank you for your interest in contributing to the MCP VS Code Workflow project! This guide will help you understand our contribution process and quality standards.

## 📋 Before You Start

**All contributions must meet our comprehensive [acceptance criteria](docs/acceptance-criteria.md).** Please review this document thoroughly before submitting any changes.

## Quick Start for Contributors

1. **Fork the repository** and clone your fork
2. **Install development dependencies**: `make dev-setup`
3. **Create a feature branch**: `git checkout -b feature/your-feature-name`
4. **Make your changes** following our guidelines
5. **Test thoroughly**: `make ci-local`
6. **Submit a pull request**

## Development Workflow

### 1. Environment Setup
```bash
# Clone your fork
git clone https://github.com/your-username/mcp-vscode-workflow.git
cd mcp-vscode-workflow

# Set up development environment
make dev-setup

# Install pre-commit hooks
make setup-hooks
```

### 2. Making Changes

#### Code Quality Requirements
- Run `make lint` to check code formatting
- Run `make format` to auto-fix formatting issues
- Run `make security` to check for security issues
- Run `make test` to run the test suite

#### Testing Requirements
- All tests must pass: `make test`
- New features must include tests
- Bug fixes must include regression tests
- Maintain or improve test coverage

#### Documentation Requirements
- Update relevant documentation for changes
- Add examples for new features
- Update installation instructions if needed
- Validate all links and references

### 3. Validation Before Submitting

Run the full CI pipeline locally:
```bash
make ci-local
```

This command runs:
- Tool validation (`make check-tools`)
- Configuration validation (`make validate-configs`)
- Code linting (`make lint`)
- Security scanning (`make security`)
- Test suite with coverage (`make test-coverage`)
- Pre-commit hooks (`make run-hooks`)

## Pull Request Process

### 1. PR Title and Description
- Use [conventional commit format](https://www.conventionalcommits.org/):
  - `feat:` for new features
  - `fix:` for bug fixes
  - `docs:` for documentation
  - `ci:` for CI/CD changes
  - `test:` for test additions/changes

### 2. PR Checklist
Before submitting, ensure:
- [ ] All acceptance criteria are met
- [ ] Tests pass locally (`make test`)
- [ ] Linting passes (`make lint`)
- [ ] Security checks pass (`make security`)
- [ ] Documentation is updated
- [ ] Changes are backward compatible
- [ ] Commit messages follow conventions

### 3. Review Process
1. **Automated checks** must pass
2. **Manual review** by maintainers
3. **Testing** in different environments
4. **Documentation review** if applicable

## Types of Contributions

### Bug Reports
- Use the issue template
- Provide detailed reproduction steps
- Include environment information
- Attach relevant logs or screenshots

### Feature Requests
- Describe the use case clearly
- Explain why it's valuable
- Consider implementation approaches
- Discuss potential breaking changes

### Code Contributions
- Must meet all acceptance criteria
- Include appropriate tests
- Update documentation
- Follow existing code patterns

### Documentation Improvements
- Fix typos and grammatical errors
- Add missing information
- Improve clarity and examples
- Update outdated information

## Code Standards

### Python Code
- Follow PEP 8 style guide
- Use Black for formatting
- Use isort for import sorting
- Include type hints where appropriate
- Write comprehensive docstrings

### Shell Scripts
- Use shellcheck for validation
- Follow bash best practices
- Include error handling
- Use proper quoting and escaping
- Add comments for complex logic

### JSON Configuration
- Validate with `jq`
- Use consistent formatting
- Include comments where supported
- Follow schema requirements

## Testing Guidelines

### Unit Tests
- Test individual functions and methods
- Use descriptive test names
- Include edge cases and error conditions
- Mock external dependencies

### Integration Tests
- Test workflow components together
- Verify file operations and configurations
- Test different profile combinations
- Validate script execution

### End-to-End Tests
- Test complete user workflows
- Verify bootstrap processes
- Test auto-detection features
- Validate profile switching

## Security Considerations

### Secret Management
- Never commit secrets or credentials
- Use environment variables for sensitive data
- Review `.secrets.baseline` for approved patterns
- Update security baselines as needed

### Code Security
- Follow secure coding practices
- Validate all inputs
- Use parameterized queries
- Avoid shell injection vulnerabilities

### Dependencies
- Keep dependencies updated
- Review security advisories
- Use known secure versions
- Document security-related changes

## Communication

### Getting Help
- Check existing issues and documentation
- Ask questions in discussions
- Use appropriate communication channels
- Provide context and examples

### Reporting Issues
- Use issue templates
- Search for existing issues first
- Provide clear reproduction steps
- Include relevant environment details

## Recognition

We appreciate all contributions and will:
- Acknowledge contributors in release notes
- Maintain contributor list
- Provide feedback and support
- Share knowledge and best practices

## Code of Conduct

This project follows the [Contributor Covenant](https://www.contributor-covenant.org/). Please be respectful, inclusive, and professional in all interactions.

## Questions?

If you have questions about contributing:
- Review the [acceptance criteria](docs/acceptance-criteria.md)
- Check existing [documentation](docs/)
- Search or create an issue
- Engage in project discussions

Thank you for contributing to MCP VS Code Workflow! 🚀
