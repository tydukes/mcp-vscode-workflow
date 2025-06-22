# Makefile for MCP VS Code Workflow
# Provides convenient commands for development, testing, and CI/CD tasks

.PHONY: help install install-dev test test-verbose lint format security clean check-tools bootstrap pre-commit setup-hooks run-hooks ci-local

# Default target
help: ## Show this help message
	@echo "MCP VS Code Workflow - Available Commands:"
	@echo ""
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "Profile Commands:"
	@echo "  make bootstrap-python    Bootstrap Python development profile"
	@echo "  make bootstrap-infra     Bootstrap Infrastructure profile"
	@echo "  make bootstrap-docs      Bootstrap Documentation profile"
	@echo "  make bootstrap-cicd      Bootstrap CI/CD profile"
	@echo "  make bootstrap-bash      Bootstrap Bash/Shell profile"

# Installation commands
install: ## Install basic dependencies
	@echo "Installing basic dependencies..."
	@if command -v uv >/dev/null 2>&1; then \
		uv pip install -e .; \
	elif command -v pip >/dev/null 2>&1; then \
		pip install -e .; \
	else \
		echo "Neither uv nor pip found. Please install Python package manager."; \
		exit 1; \
	fi

install-dev: ## Install development dependencies
	@echo "Installing development dependencies..."
	@if command -v uv >/dev/null 2>&1; then \
		uv pip install -e ".[dev]"; \
	else \
		pip install -e ".[dev]"; \
	fi

# Testing commands
test: ## Run tests
	@echo "Running tests..."
	@if command -v uv >/dev/null 2>&1; then \
		uv run pytest; \
	else \
		pytest; \
	fi

test-verbose: ## Run tests with verbose output
	@echo "Running tests with verbose output..."
	@if command -v uv >/dev/null 2>&1; then \
		uv run pytest -v --cov-report=term-missing; \
	else \
		pytest -v --cov-report=term-missing; \
	fi

test-coverage: ## Run tests with coverage report
	@echo "Running tests with coverage..."
	@if command -v uv >/dev/null 2>&1; then \
		uv run pytest --cov=. --cov-report=html --cov-report=term; \
	else \
		pytest --cov=. --cov-report=html --cov-report=term; \
	fi

# Linting and formatting commands
lint: ## Run all linting checks
	@echo "Running linting checks..."
	@echo "1. Running flake8..."
	@if command -v uv >/dev/null 2>&1; then uv run flake8 .; else flake8 .; fi
	@echo "2. Running black check..."
	@if command -v uv >/dev/null 2>&1; then uv run black --check .; else black --check .; fi
	@echo "3. Running isort check..."
	@if command -v uv >/dev/null 2>&1; then uv run isort --check-only .; else isort --check-only .; fi
	@echo "4. Running shellcheck..."
	@find . -name "*.sh" -type f -exec shellcheck {} +
	@echo "5. Validating JSON files..."
	@find . -name "*.json" -type f -exec jq empty {} \;

format: ## Format code
	@echo "Formatting code..."
	@if command -v uv >/dev/null 2>&1; then \
		uv run black .; \
		uv run isort .; \
	else \
		black .; \
		isort .; \
	fi

security: ## Run security checks
	@echo "Running security checks..."
	@if command -v uv >/dev/null 2>&1; then uv run bandit -r . -f json -o bandit-report.json; else bandit -r . -f json -o bandit-report.json; fi
	@echo "Running detect-secrets..."
	@if command -v detect-secrets >/dev/null 2>&1; then detect-secrets scan --baseline .secrets.baseline; else echo "detect-secrets not found, skipping..."; fi

# Project validation commands
check-tools: ## Validate required tools for all profiles
	@echo "Checking tools for all profiles..."
	@chmod +x scripts/*.sh
	@./scripts/check-tools.sh --profile bash
	@./scripts/check-tools.sh --profile python || true
	@./scripts/check-tools.sh --profile infra || true

validate-configs: ## Validate all configuration files
	@echo "Validating MCP configurations..."
	@find .mcp -name "*.json" -type f -exec jq empty {} \;
	@echo "Validating VS Code profiles..."
	@find .vscode/profiles -name "*.json" -type f -exec jq empty {} \;

# Bootstrap commands for different profiles
bootstrap-python: ## Bootstrap Python development environment
	@chmod +x scripts/*.sh
	@./scripts/bootstrap.sh --profile python

bootstrap-infra: ## Bootstrap Infrastructure development environment
	@chmod +x scripts/*.sh
	@./scripts/bootstrap.sh --profile infra

bootstrap-docs: ## Bootstrap Documentation environment
	@chmod +x scripts/*.sh
	@./scripts/bootstrap.sh --profile docs

bootstrap-cicd: ## Bootstrap CI/CD environment
	@chmod +x scripts/*.sh
	@./scripts/bootstrap.sh --profile cicd

bootstrap-bash: ## Bootstrap Bash/Shell environment
	@chmod +x scripts/*.sh
	@./scripts/bootstrap.sh --profile bash

# Pre-commit commands
setup-hooks: ## Install pre-commit hooks
	@echo "Installing pre-commit hooks..."
	@if command -v pre-commit >/dev/null 2>&1; then \
		pre-commit install; \
		pre-commit install --hook-type commit-msg; \
	else \
		echo "pre-commit not found. Install with: pip install pre-commit"; \
		exit 1; \
	fi

run-hooks: ## Run pre-commit hooks on all files
	@echo "Running pre-commit hooks on all files..."
	@pre-commit run --all-files

update-hooks: ## Update pre-commit hooks
	@echo "Updating pre-commit hooks..."
	@pre-commit autoupdate

# CI/CD simulation
ci-local: ## Run full CI pipeline locally
	@echo "Running full CI pipeline locally..."
	@echo "1. Checking tools..."
	@$(MAKE) check-tools
	@echo "2. Validating configurations..."
	@$(MAKE) validate-configs
	@echo "3. Running linting..."
	@$(MAKE) lint
	@echo "4. Running security checks..."
	@$(MAKE) security
	@echo "5. Running tests..."
	@$(MAKE) test-coverage
	@echo "6. Running pre-commit hooks..."
	@$(MAKE) run-hooks
	@echo "✅ All CI checks passed!"

# Cleanup commands
clean: ## Clean up build artifacts and caches
	@echo "Cleaning up..."
	@rm -rf build/
	@rm -rf dist/
	@rm -rf *.egg-info/
	@rm -rf .pytest_cache/
	@rm -rf .coverage
	@rm -rf htmlcov/
	@rm -rf .mypy_cache/
	@rm -rf bandit-report.json
	@find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete 2>/dev/null || true

clean-all: clean ## Clean everything including virtual environments
	@echo "Cleaning everything..."
	@rm -rf venv/
	@rm -rf .venv/
	@rm -rf virtualenv/

# Documentation commands
docs-serve: ## Serve documentation locally (if using mkdocs or similar)
	@echo "This project uses markdown documentation in docs/"
	@echo "View docs by opening files in docs/ directory"
	@ls -la docs/

# Development helpers
dev-setup: install-dev setup-hooks ## Complete development setup
	@echo "Development environment setup complete!"
	@echo "Next steps:"
	@echo "  1. Choose a profile: make bootstrap-<profile-name>"
	@echo "  2. Run tests: make test"
	@echo "  3. Start developing!"

# Quick commands for common workflows
quick-check: ## Quick validation (fast subset of CI)
	@echo "Running quick validation..."
	@$(MAKE) lint
	@$(MAKE) validate-configs
	@echo "✅ Quick check passed!"

fix: ## Auto-fix formatting and some linting issues
	@echo "Auto-fixing issues..."
	@$(MAKE) format
	@chmod +x scripts/*.sh
	@echo "✅ Auto-fix complete!"

# Status and info commands
status: ## Show project status and configuration
	@echo "MCP VS Code Workflow Status:"
	@echo "=========================="
	@echo "Python version: $$(python --version 2>/dev/null || echo 'Not found')"
	@echo "Node.js version: $$(node --version 2>/dev/null || echo 'Not found')"
	@echo "Git version: $$(git --version 2>/dev/null || echo 'Not found')"
	@echo "VS Code installed: $$(command -v code >/dev/null 2>&1 && echo 'Yes' || echo 'No')"
	@echo ""
	@echo "Available profiles:"
	@ls -1 .vscode/profiles/ 2>/dev/null | sed 's/^/  - /' || echo "  No profiles found"
	@echo ""
	@echo "Available scripts:"
	@ls -1 scripts/*.sh 2>/dev/null | sed 's/^/  - /' || echo "  No scripts found"
