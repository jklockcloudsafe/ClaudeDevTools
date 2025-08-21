# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ClaudeDevTools is a collection of shell scripts and utilities for optimizing repositories and development environments for Claude Code usage. It provides tools for health checking, conversation management, authentication switching, and repository setup automation.

## Repository Structure

```
ClaudeDevTools/
├── claude-check.sh           # Health check for Claude optimization files
├── claude-convo.sh           # Interactive conversation prompt builder
├── claude-credchange.sh      # Authentication management for Claude Code
└── reposetup/               # Repository optimization deployment tool
    ├── claude-reposetup.sh  # Main deployment script
    └── artifacts/           # Template files for deployment
        ├── CLAUDE.md        # Template documentation
        ├── PROJECT_CONTEXT.md # Template project context
        ├── project-health.sh  # Template health check
        └── request-templates.txt # Request templates
```

## Key Scripts and Usage

### claude-check.sh
Health check script that validates Claude Code optimization files in a target directory.

```bash
# Check current directory
./claude-check.sh

# Check specific directory
./claude-check.sh /path/to/project
```

Checks for: `.claude.json`, `.claudeignore`, `CLAUDE.md`, `.claude-rules`, `PROJECT_CONTEXT.md`, `request-templates.txt`, `project-health.sh`

### claude-convo.sh
Interactive conversation builder with structured prompting workflow.

```bash
./claude-convo.sh
```

Features:
- File path completion with @ symbol
- Preview mode for request formatting
- Structured TASK → SPECIFICS → CONSTRAINTS workflow
- Automatic clipboard copying
- Edit functionality for previous requests

### claude-credchange.sh (claude-switch)
Authentication management tool for switching between Pro subscription and API key modes.

```bash
./claude-credchange.sh
# Or after installation:
claude-switch
```

Options:
1. Pro/Max Subscription mode (default)
2. API Key mode (pay-per-use)
3. Show current status
4. Clear all authentication

### reposetup/claude-reposetup.sh
Deploys Claude optimization files from the artifacts directory to target repositories.

```bash
# Deploy to current directory (skip existing files)
./reposetup/claude-reposetup.sh

# Deploy to specific directory
./reposetup/claude-reposetup.sh /path/to/target

# Replace existing files with fresh templates (creates backups)
./reposetup/claude-reposetup.sh --replace

# Preview changes without applying them
./reposetup/claude-reposetup.sh --dry-run

# Skip confirmation prompts
./reposetup/claude-reposetup.sh --replace --yes
```

### reposetup/claude-repocheck.sh
Comprehensive checking and validation tool for Claude Code optimization files.

```bash
# Check current directory
./reposetup/claude-repocheck.sh

# Check specific directory with verbose output
./reposetup/claude-repocheck.sh --verbose /path/to/project

# Get machine-readable JSON output
./reposetup/claude-repocheck.sh --json

# Quiet mode (only errors and summary)
./reposetup/claude-repocheck.sh --quiet
```

## Architecture Patterns

### Script Design Philosophy
- **Idempotent execution**: All scripts can be run multiple times safely
- **Cross-platform compatibility**: Scripts handle different environments gracefully
- **User-friendly interfaces**: Clear prompts and feedback
- **Error handling**: Comprehensive validation and error reporting

### File Management
- **Template system**: Artifacts directory contains template files for deployment
- **Configuration files**: JSON and text-based configurations for Claude Code
- **Health monitoring**: Built-in health checks and validation scripts
- **Idempotent operations**: Scripts can be run multiple times safely
- **Backup system**: Automatic backups when replacing existing files

### Integration Features
- **Cross-script integration**: claude-repocheck.sh recommends running claude-reposetup.sh for missing files
- **Smart recommendations**: Scripts suggest appropriate next actions based on current state
- **Consistent file tracking**: Both scripts use identical file lists for consistency
- **Machine-readable output**: JSON mode enables automation and integration with other tools

### Authentication Handling
- **Mode separation**: Clear distinction between subscription and API key modes
- **Conflict prevention**: Automatic cleanup to prevent authentication conflicts
- **Environment management**: Shell configuration file management for API keys

## Safety Features

### Backup and Recovery
- **Automatic backups**: Files are backed up before replacement with timestamp-based names
- **Dry-run mode**: Preview changes before applying them with `--dry-run`
- **Confirmation prompts**: Interactive confirmations for potentially destructive operations
- **Skip confirmations**: Use `--yes` flag for automated scripts

### Validation and Verification
- **JSON syntax validation**: Automatic validation of .claude.json files
- **File permission checks**: Verification that scripts are executable
- **Placeholder detection**: Identification of template content that needs customization
- **Comprehensive health checks**: Full repository optimization status validation

## Common Development Tasks

### Testing Scripts
Scripts are primarily tested through manual execution on target platforms. Each script includes help functionality and input validation.

```bash
# View help for any script
./script-name.sh --help
./script-name.sh -h
```

### Adding New Templates
New template files should be added to `reposetup/artifacts/` and referenced in `claude-reposetup.sh` for deployment.

### Modifying Conversation Workflow
The conversation builder in `claude-convo.sh` uses a structured approach:
1. TASK collection
2. SPECIFICS gathering with file completion
3. CONSTRAINTS application with smart filtering
4. Request formatting and clipboard integration

## Configuration Files

### .claude.json
Project configuration for Claude Code with optimization settings.

### .claudeignore
Performance optimization file to exclude irrelevant files from Claude's context.

### .claude-rules
Automation constraints and rules for Claude Code behavior.

### PROJECT_CONTEXT.md
Project-specific context and current state documentation for Claude Code sessions.

## Error Handling and Validation

All scripts implement:
- Directory existence validation
- Permission checking
- Git repository detection
- File dependency verification
- Platform-specific command availability

## Security Considerations

- API keys are managed through environment variables, not stored in configurations
- Scripts validate input parameters to prevent path traversal
- Authentication switching includes proper cleanup of credentials
- No sensitive information is included in template files

## Installation and Deployment

The repository is designed to be self-contained. The `claude-credchange.sh` script includes installation functionality for the `claude-switch` command in `~/bin/`.

For repository optimization deployment, use `claude-reposetup.sh` which copies template files and updates `.gitignore` appropriately.