# AI Role-Based Assistance

## Overview

The MCP VS Code Workflow provides specialized AI personas designed to assist with specific development tasks. Each role brings domain expertise and tailored guidance to enhance your workflow productivity.

## Available Roles

### Python Development Assistant

**Role:** `python`

**Expertise:** Python development, testing, and deployment

**Specializations:**

- **Language Mastery:** Deep understanding of Python 3.x features, syntax, and idioms
- **Code Quality:** PEP 8 compliance, type hints, docstrings, and clean code principles  
- **Testing:** Unit testing, integration testing, test-driven development (TDD)
- **Performance:** Profiling, optimization, and memory management
- **Frameworks:** Django, Flask, FastAPI, SQLAlchemy, Celery, and more

**Key Capabilities:**

- Pythonic code review and suggestions
- Test generation and coverage analysis
- Performance optimization recommendations
- Security vulnerability identification
- Dependency management guidance

**Usage Examples:**
```bash
# Activate Python assistant for code review
"Review this Python function for PEP 8 compliance and performance"

# Get testing recommendations
"Generate unit tests for this Flask API endpoint"

# Performance optimization
"Analyze this code for potential bottlenecks"
```

**Best Used For:**

- Web application development
- API design and implementation
- Data processing pipelines
- Package development
- Code refactoring and optimization

### Infrastructure & DevOps Assistant

**Role:** `infra`

**Expertise:** Infrastructure automation, cloud services, and DevOps practices

**Specializations:**

- **Cloud Platforms:** AWS, Azure, GCP service expertise
- **Infrastructure as Code:** Terraform, CloudFormation, Pulumi
- **Containerization:** Docker, Kubernetes, container orchestration
- **Monitoring:** Observability, alerting, and performance monitoring
- **Security:** Infrastructure security, compliance, and best practices

**Key Capabilities:**

- Infrastructure architecture review
- Cost optimization analysis
- Security compliance checking
- Deployment strategy recommendations
- Monitoring and alerting setup

**Usage Examples:**
```bash
# Infrastructure review
"Review this Terraform configuration for best practices"

# Security analysis
"Analyze this Kubernetes deployment for security issues"

# Cost optimization
"Suggest cost optimizations for this AWS architecture"
```

**Best Used For:**

- Cloud infrastructure design
- Kubernetes deployment management
- CI/CD pipeline infrastructure
- Security and compliance audits
- Cost optimization projects

### Documentation Specialist

**Role:** `docs`

**Expertise:** Technical writing and documentation generation

**Specializations:**

- **Content Strategy:** Information architecture and user journey mapping
- **Technical Writing:** API documentation, user guides, and tutorials
- **Documentation Tools:** Markdown, reStructuredText, docs-as-code workflows
- **Style Guidelines:** Consistency, clarity, and accessibility standards
- **Publishing Platforms:** GitBook, MkDocs, Sphinx, and static site generators

**Key Capabilities:**

- Content structure and organization
- Writing style and clarity improvements
- API documentation generation
- User experience optimization
- Cross-reference validation

**Usage Examples:**
```bash
# Content review
"Review this API documentation for clarity and completeness"

# Structure optimization
"Suggest improvements for this documentation hierarchy"

# Style guidance
"Improve the writing style of this user guide"
```

**Best Used For:**

- API documentation projects
- User guide creation
- Technical blog writing
- Documentation site organization
- Content strategy development

### Shell Scripting Expert

**Role:** `bash`

**Expertise:** Shell scripting, automation, and system administration

**Specializations:**

- **Shell Scripting:** Bash, Zsh, and POSIX shell compatibility
- **System Administration:** Process management, file operations, and system monitoring
- **Automation:** Task automation, cron jobs, and workflow scripting
- **Performance:** Script optimization and resource management
- **Portability:** Cross-platform compatibility and best practices

**Key Capabilities:**

- Script optimization and security
- Error handling and debugging
- Performance analysis
- Portability recommendations
- Automation workflow design

**Usage Examples:**
```bash
# Script review
"Review this bash script for security and best practices"

# Optimization
"Optimize this shell script for better performance"

# Error handling
"Add proper error handling to this automation script"
```

**Best Used For:**

- System automation scripts
- Build and deployment automation
- Log processing and analysis
- System monitoring scripts
- Cross-platform scripting

### CI/CD Pipeline Expert

**Role:** `cicd`

**Expertise:** Continuous integration and deployment workflows

**Specializations:**

- **Pipeline Design:** Workflow optimization and best practices
- **Platform Expertise:** GitHub Actions, GitLab CI, Jenkins, Azure DevOps
- **Quality Gates:** Testing, security scanning, and code quality checks
- **Deployment Strategies:** Blue-green, canary, rolling deployments
- **Monitoring:** Pipeline observability and failure analysis

**Key Capabilities:**

- Pipeline architecture design
- Workflow optimization
- Security integration
- Performance monitoring
- Failure analysis and debugging

**Usage Examples:**
```bash
# Pipeline review
"Review this GitHub Actions workflow for optimization"

# Security integration
"Add security scanning to this CI/CD pipeline"

# Performance analysis
"Analyze this pipeline for bottlenecks and improvements"
```

**Best Used For:**

- CI/CD pipeline design
- Deployment automation
- Quality gate implementation
- Pipeline troubleshooting
- Workflow optimization

## Advanced Roles

### Senior Architect

**Role:** `senior-architect`

**Focus:** System design, architecture decisions, and technical leadership

**Capabilities:**

- High-level system design
- Technology stack recommendations
- Scalability and performance planning
- Risk assessment and mitigation
- Team guidance and mentoring

### Security Analyst

**Role:** `security-analyst`

**Focus:** Security assessment, vulnerability analysis, and compliance

**Capabilities:**

- Security vulnerability assessment
- Compliance framework guidance
- Threat modeling
- Security best practices
- Incident response planning

### Data Modeler

**Role:** `data-modeler`

**Focus:** Database design, data architecture, and analytics

**Capabilities:**

- Database schema design
- Data modeling best practices
- Query optimization
- ETL pipeline design
- Analytics infrastructure

## Role Usage Patterns

### Context-Aware Activation

Roles are automatically activated based on:

**File Extensions:**
- `.py` files → Python Development Assistant
- `.tf`, `.yml` (infra) → Infrastructure Assistant
- `.md`, `.rst` → Documentation Specialist
- `.sh`, `.bash` → Shell Scripting Expert
- CI/CD files → Pipeline Expert

**Project Structure:**
- `requirements.txt` presence → Python Assistant
- `Dockerfile` presence → Infrastructure Assistant
- `docs/` directory → Documentation Specialist
- `.github/workflows/` → CI/CD Expert

**Content Analysis:**
- Function definitions → Code review roles
- Documentation sections → Writing specialists
- Infrastructure configs → DevOps experts

### Manual Role Selection

**Command Palette:**
```bash
# Select specific role for current task
Ctrl+Shift+P → "MCP: Select Role"

# Switch role context
Ctrl+Shift+P → "MCP: Switch to Python Assistant"
```

**Direct Invocation:**
```bash
# In MCP prompt
@python "Review this code for performance issues"
@infra "Analyze this Terraform configuration"
@docs "Improve this API documentation"
```

### Multi-Role Collaboration

**Sequential Consultation:**
```bash
# Get multiple perspectives
@python "Review this code" 
@security "Check for vulnerabilities"
@senior-architect "Assess the design approach"
```

**Collaborative Analysis:**
```bash
# Combined expertise
@infra @security "Review this Kubernetes deployment for both infrastructure and security best practices"
```

## Role Customization

### Creating Custom Roles

1. **Define Role Configuration:**
   ```json
   {
     "roles": {
       "frontend": {
         "name": "Frontend Specialist",
         "description": "React, Vue, and modern frontend development",
         "promptFile": "prompts/frontend-specialist.md",
         "capabilities": ["ui-review", "performance", "accessibility"],
         "mcpServers": ["filesystem", "git", "npm-tools"]
       }
     }
   }
   ```

2. **Create Prompt Template:**
   ```markdown
   # Frontend Development Specialist
   
   You are an expert frontend developer specializing in:
   - Modern JavaScript frameworks (React, Vue, Angular)
   - Performance optimization
   - Accessibility standards
   - UI/UX best practices
   ```

3. **Register with Profile:**
   ```json
   {
     "extends": "../roles.json#/roles/frontend"
   }
   ```

### Role Prompt Templates

**Template Structure:**
```markdown
# Role Name

## Core Competencies
- List key skills and knowledge areas

## Review Focus Areas
1. Primary concerns for this role
2. Quality standards and best practices
3. Common issues to identify

## Tools and Frameworks
- Relevant technologies and tools

## Common Patterns
- Best practices and anti-patterns
- Recommended approaches
```

**Template Variables:**
- `{{CODE_BLOCK}}` - Selected code for analysis
- `{{LANGUAGE}}` - Programming language context
- `{{FRAMEWORK}}` - Framework being used
- `{{PROJECT_TYPE}}` - Type of project
- `{{ERROR_MESSAGE}}` - Error details for debugging

## Best Practices

### Effective Role Usage

**Be Specific:**
```bash
# Good: Specific request with context
@python "Review this FastAPI endpoint for proper error handling and type hints"

# Less effective: Vague request
@python "Review this code"
```

**Provide Context:**
```bash
# Include relevant information
@infra "Review this Terraform module for a high-traffic web application requiring 99.9% uptime"
```

**Chain Consultations:**
```bash
# Use multiple roles for comprehensive analysis
@python "Review code structure"
@security "Check for vulnerabilities" 
@senior-architect "Evaluate overall design"
```

### Role Selection Guidelines

**Choose Based on Primary Concern:**
- Code quality issues → Language-specific assistant
- Architecture decisions → Senior Architect
- Security concerns → Security Analyst
- Performance problems → Relevant specialist + Senior Architect
- Documentation → Documentation Specialist

**Consider Project Phase:**
- Planning phase → Senior Architect, Product Manager
- Development phase → Language specialists
- Testing phase → Test Engineer, Security Analyst
- Deployment phase → Infrastructure, CI/CD Expert
- Maintenance phase → Relevant specialists based on issues

## Next Steps

- Learn about [MCP server integration](mcp-servers.md)
- Explore [profile customization](profiles.md)
- Review [setup and configuration](setup.md) for role management
