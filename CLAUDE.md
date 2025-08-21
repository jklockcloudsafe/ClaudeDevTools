# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ClaudeDevTools is a comprehensive suite of shell scripts and utilities for optimizing repositories and development environments for Claude Code usage. It provides tools for repository setup, health checking, session management, usage analytics, configuration optimization, and authentication management.

## Repository Structure

```
ClaudeDevTools/
├── install-all.sh            # Master installer for all tools
├── claude-convo.sh           # Interactive conversation prompt builder
├── reposetup/               # Repository setup and validation
│   ├── claude-reposetup.sh  # Repository optimization deployment
│   ├── claude-repocheck.sh  # Health checking and validation
│   └── artifacts/           # Template files for deployment
├── session/                 # Session management
│   └── claude-session.sh    # Repository-specific session tracking
├── usage/                   # Usage analytics and monitoring
│   └── claude-usage.sh      # API usage and cost tracking
├── optimize/                # Configuration optimization
│   └── claude-optimize.sh   # Claude file optimization
└── creds/                   # Authentication management
    └── claude-credchange.sh # Authentication switching
```

## Installation

### Quick Install (All Tools)
Install all Claude development tools with a single command:

```bash
./install-all.sh
```

This installs the following global commands:
- `claude-reposetup` - Repository setup and optimization
- `claude-repocheck` - Health checking and validation 
- `claude-session` - Session management
- `claude-usage` - Usage analytics and cost tracking
- `claude-optimize` - Configuration optimization
- `claude-switch` - Authentication management

### Individual Installation
Each tool can be installed individually:

```bash
./reposetup/claude-reposetup.sh --install
./session/claude-session.sh --install
# etc.
```

## Tool Overview and Usage

### claude-reposetup
Deploy Claude optimization files to any repository.

```bash
claude-reposetup                    # Setup current directory
claude-reposetup /path/to/project   # Setup specific directory
claude-reposetup --replace          # Replace existing files
claude-reposetup --dry-run          # Preview changes
```

Creates: `.claude.json`, `.claudeignore`, `CLAUDE.md`, `.claude-rules`, `PROJECT_CONTEXT.md`, `request-templates.txt`, `project-health.sh`

### claude-repocheck
Validate and analyze Claude optimization status.

```bash
claude-repocheck                    # Check current directory
claude-repocheck --verbose          # Detailed output
claude-repocheck --json             # Machine-readable output
claude-repocheck /path/to/project   # Check specific directory
```

### claude-session
Manage repository-specific Claude conversation sessions.

```bash
claude-session save feature-x       # Save current session
claude-session list                 # List all sessions
claude-session resume feature-x     # Resume previous session
claude-session export feature-x     # Export to markdown
```

Sessions are stored in `.claude/sessions/` and include project context, git state, and timestamps.

### claude-usage
Monitor Claude API usage and costs.

```bash
claude-usage                        # Weekly summary
claude-usage daily                  # Daily breakdown
claude-usage costs                  # Cost estimates
claude-usage status                 # Auth and rate limits
claude-usage --json                 # JSON output
```

### claude-optimize
Optimize Claude configuration files for better performance.

```bash
claude-optimize                     # Analyze current directory
claude-optimize --fix              # Apply optimizations
claude-optimize --backup --fix     # Apply with backups
claude-optimize --json              # JSON analysis
```

Analyzes and optimizes `.claudeignore`, `.claude.json`, `CLAUDE.md`, and `PROJECT_CONTEXT.md`.

### claude-switch
Switch between Pro subscription and API key authentication.

```bash
claude-switch                       # Interactive menu
```

Options:
1. Pro/Max Subscription mode (default)
2. API Key mode (pay-per-use) 
3. Show current status
4. Clear all authentication

### claude-convo (Development)
Interactive conversation builder - currently in development.

```bash
./claude-convo.sh
```

Features:
- File path completion with @ symbol
- Structured TASK → SPECIFICS → CONSTRAINTS workflow
- Preview mode and clipboard integration
- Edit functionality for previous requests

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

The repository provides a master installer that sets up all tools:

```bash
./install-all.sh                   # Install all tools
./install-all.sh --update          # Update existing installations
./install-all.sh --list            # Show installation status
./install-all.sh --uninstall       # Remove all tools
```

All tools are installed to `~/bin/` and automatically added to PATH. Individual tools can also be installed using their `--install` flag.

## Workflow Integration

### Typical Usage Flow
1. **Setup**: `claude-reposetup` - Initialize repository for Claude
2. **Validate**: `claude-repocheck` - Verify optimization status
3. **Optimize**: `claude-optimize --fix` - Tune configuration files
4. **Work**: `claude-session save` - Save conversation contexts
5. **Monitor**: `claude-usage` - Track API usage and costs
6. **Manage**: `claude-switch` - Handle authentication as needed