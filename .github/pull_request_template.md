# Pull Request

## Description

<!-- Provide a clear and concise description of the changes -->

## Type of Change

<!-- Mark the applicable option with an 'x' -->
- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Security enhancement
- [ ] CI/CD improvement

## Acceptance Criteria Checklist

<!-- All items must be checked before merging -->
<!-- Review the complete acceptance criteria: docs/acceptance-criteria.md -->

### Testing Requirements
- [ ] All Python tests pass (`make test`)
- [ ] Test coverage maintained or improved (`make test-coverage`)
- [ ] New functionality includes appropriate tests
- [ ] Shell scripts pass shellcheck validation
- [ ] Integration tests pass for affected workflows

### Code Quality Standards
- [ ] All linting checks pass (`make lint`)
- [ ] Code formatted according to standards (`make format`)
- [ ] No flake8 violations (Python)
- [ ] Black formatting applied (Python)
- [ ] isort import sorting applied (Python)
- [ ] Shellcheck validation passed (Shell scripts)

### Configuration Validation
- [ ] All JSON configurations are valid (`make validate-configs`)
- [ ] MCP configurations validate successfully
- [ ] VS Code profile configurations are valid
- [ ] No syntax errors in configuration files

### Security Requirements
- [ ] Security checks pass (`make security`)
- [ ] Bandit scan shows no high-severity issues
- [ ] No exposed credentials or secrets
- [ ] Proper file permissions maintained

### Documentation Standards
- [ ] Code includes appropriate documentation/comments
- [ ] User-facing changes documented
- [ ] Examples provided for new features
- [ ] Installation instructions updated if needed

### CI/CD Requirements
- [ ] All CI workflows pass
- [ ] Pre-commit hooks pass (`make run-hooks`)
- [ ] Commit messages follow conventional format
- [ ] Branch protection rules satisfied

### Compatibility
- [ ] Changes work on macOS (primary target)
- [ ] Linux compatibility maintained where applicable
- [ ] All required tools validated (`make check-tools`)
- [ ] No significant performance regression

### Full Validation
- [ ] Complete CI pipeline passes locally (`make ci-local`)
- [ ] All acceptance criteria met (reviewed [acceptance-criteria.md](docs/acceptance-criteria.md))

## Testing Performed

<!-- Describe the testing you performed to verify your changes -->
- [ ] Unit tests
- [ ] Integration tests
- [ ] Manual testing
- [ ] Performance testing (if applicable)

## Breaking Changes

<!-- If this is a breaking change, describe the impact and migration path -->
- [ ] N/A - No breaking changes
- [ ] Breaking changes documented with migration guide

## Screenshots (if applicable)

<!-- Add screenshots for UI changes -->

## Related Issues

<!-- Link to related issues using keywords: Fixes #123, Closes #456, Refs #789 -->

## Additional Notes

<!-- Any additional information that reviewers should know -->

## Reviewer Notes

<!-- For reviewers: Additional items to verify -->
- [ ] Code review completed
- [ ] Manual testing performed
- [ ] Documentation review completed
- [ ] Security implications assessed
- [ ] Performance impact evaluated

---

**Note**: This PR must meet all acceptance criteria defined in [docs/acceptance-criteria.md](docs/acceptance-criteria.md) before merging.
