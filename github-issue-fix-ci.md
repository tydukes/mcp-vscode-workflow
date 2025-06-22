# Fix CI Pipeline Failures

## Description

The CI pipelines are currently failing due to multiple issues that need to be addressed to ensure all checks pass consistently. This includes fixing syntax errors, adding missing content, and resolving linting issues.

## Issues Identified

### 1. JSON Syntax Error ❌

- **File**: `.vscode/profiles/python.json`
- **Issue**: Extra comma on line 26 causing JSON parse error
- **Fix Required**: Remove the trailing comma after the `python.linting.mypyEnabled` property

### 2. ShellCheck Failures ❌

Multiple shell script issues identified:

#### Empty Profile Scripts Missing Shebang

- **Files**:
  - `scripts/start-bash-profile.sh`
  - `scripts/start-cicd-profile.sh`
  - `scripts/start-docs-profile.sh`
  - `scripts/start-infra-profile.sh`
  - `scripts/start-python-profile.sh`
- **Issue**: Empty files without shebang causing SC2148 errors
- **Fix Required**: Either add shebang + placeholder content or exclude from shellcheck

#### Quote Issues in install-mcp-npx.sh

- **File**: `scripts/install-mcp-npx.sh`
- **Issue**: Unquoted variables causing SC2086 warnings (lines 113, 115)
- **Fix Required**: Quote `$npx_args` variable usage

#### Variable Assignment Issue in bootstrap.sh

- **File**: `scripts/bootstrap.sh`
- **Issue**: Combined declare and assign masking return values (line 91)
- **Fix Required**: Separate declaration and assignment

### 3. CI Configuration Issues ❌

- **Python Dependencies**: CI may fail installing test dependencies with `uv`
- **Test Discovery**: Tests may not run properly due to dependency issues
- **Coverage**: Coverage reporting may fail if tests don't execute

## Tasks

### High Priority (Blocking CI)

- [ ] Fix JSON syntax error in `.vscode/profiles/python.json`
- [ ] Add shebang to empty profile scripts or exclude from shellcheck
- [ ] Fix shell script quoting issues in `scripts/install-mcp-npx.sh`
- [ ] Fix variable assignment in `scripts/bootstrap.sh`

### Medium Priority (CI Reliability)

- [ ] Verify Python test dependencies install correctly with uv
- [ ] Ensure pytest can discover and run tests properly
- [ ] Validate coverage reporting works end-to-end
- [ ] Test markdownlint rules and fix any issues

### Low Priority (CI Enhancement)

- [ ] Add content to empty profile scripts or remove them
- [ ] Review and optimize CI caching strategy
- [ ] Add CI status badges to README
- [ ] Consider adding pre-commit hooks to prevent these issues

## Expected Outcome

After addressing these issues:

- ✅ All CI workflow jobs should pass consistently
- ✅ JSON validation should succeed
- ✅ ShellCheck should pass for all scripts
- ✅ Python tests should run and report coverage
- ✅ Security scans should complete without errors
- ✅ Markdown linting should pass
- ✅ Branch protection rules should work properly

## Files to Modify

1. `.vscode/profiles/python.json` - Fix JSON syntax
2. `scripts/install-mcp-npx.sh` - Add quotes to variables
3. `scripts/bootstrap.sh` - Fix variable assignment
4. `scripts/start-*-profile.sh` - Add shebangs or exclude from linting
5. `.github/workflows/ci.yml` - Potential dependency installation fixes

## Testing

After fixes:

1. Run `shellcheck scripts/*.sh` locally
2. Run `find . -name "*.json" -exec jq empty {} \;` locally
3. Test Python dependency installation with uv
4. Verify all CI jobs pass on a test branch

## Priority

**High** - CI failures prevent proper code review and merge processes

## Labels

- `bug`
- `ci/cd`
- `high-priority`
- `good-first-issue` (for JSON fix)
