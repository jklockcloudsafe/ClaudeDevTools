# ClaudeDevTools
<!-- Property of CloudSafe -->

> A comprehensive suite of shell scripts for optimizing repositories and development environments for Claude Code

[![Shell](https://img.shields.io/badge/shell-bash-green.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey.svg)](https://github.com/johnklockenkemper/ClaudeDevTools)

Transform any repository into a Claude Code-optimized workspace with automated setup, health monitoring, session management, and cost tracking.

## Quick Start

```bash
# Install all tools
./install-all.sh

# Optimize any repository for Claude
claude-reposetup

# Check optimization status  
claude-repocheck

# Monitor your API usage
claude-usage
```

## Repository Structure

```
ClaudeDevTools/
├── install-all.sh              # Master installer for all tools
├── project-health.sh           # Standalone project health checker
├── CLAUDE.md                   # Project documentation for Claude Code
├── PROJECT_CONTEXT.md          # Current project state and development notes
├── request-templates.txt       # Template prompts for Claude Code interactions
├── .claude.json               # Claude Code project configuration
├── .claudeignore              # Performance optimization exclusions
├── .claude-rules              # Automation constraints and development rules
├── reposetup/                 # Repository setup and validation tools
│   ├── claude-reposetup.sh    # Deploy Claude optimization files
│   ├── claude-repocheck.sh    # Validate optimization status
│   └── artifacts/             # Template files for deployment
│       ├── .claude.json       # Template: Claude Code configuration
│       ├── .claudeignore      # Template: Performance optimization file
│       ├── .claude-rules      # Template: Development automation rules
│       ├── CLAUDE.md          # Template: Project documentation
│       ├── PROJECT_CONTEXT.md # Template: Project state documentation
│       ├── project-health.sh  # Template: Health check script
│       └── request-templates.txt # Template: Interaction prompts
├── session/                   # Session management tools
│   └── claude-session.sh      # Repository-specific session tracking
├── usage/                     # Usage analytics and monitoring
│   └── claude-usage.sh        # API usage and cost tracking
├── optimize/                  # Configuration optimization tools
│   └── claude-optimize.sh     # Claude configuration file optimization
└── creds/                     # Authentication management
    └── claude-credchange.sh   # Authentication mode switching (claude-switch)
```

## Why ClaudeDevTools?

Working with Claude Code becomes exponentially more effective when your repository is properly configured. ClaudeDevTools solves the complexity of:

- **Context Optimization**: Automatically configure `.claudeignore`, `.claude.json`, and context files for faster, more accurate responses
- **Cost Management**: Track API usage and costs across projects to optimize your Claude Code workflows  
- **Session Continuity**: Save and resume conversation contexts with full project state
- **Quality Assurance**: Validate repository setup and maintain optimization standards
- **Team Collaboration**: Standardize Claude Code configurations across teams and projects

## Installation

### Install All Tools (Recommended)

```bash
git clone https://github.com/johnklockenkemper/ClaudeDevTools.git
cd ClaudeDevTools
./install-all.sh
```

This installs 6 global commands: `claude-reposetup`, `claude-repocheck`, `claude-session`, `claude-usage`, `claude-optimize`, `claude-switch`

### Installation Options

```bash
# Install all tools
./install-all.sh

# Update existing installations
./install-all.sh --update

# Check installation status
./install-all.sh --list

# Uninstall all tools
./install-all.sh --uninstall
```

### Individual Installation

```bash
# Install specific tools
./reposetup/claude-reposetup.sh --install
./reposetup/claude-repocheck.sh --install
./session/claude-session.sh --install
./usage/claude-usage.sh --install
./optimize/claude-optimize.sh --install
./creds/claude-credchange.sh --install
```

### Requirements

- **Shell**: Bash 3.2+ (macOS/Linux compatible)
- **Dependencies**: git, curl, jq (installed automatically if missing)
- **Permissions**: Write access to `~/bin` directory

## Core Tools Overview

| Tool | Global Command | Purpose | Key Features |
|------|---------------|---------|--------------|
| **Repository Setup** | `claude-reposetup` | Deploy Claude optimization files | Template deployment, backup creation, dry-run mode |
| **Health Checking** | `claude-repocheck` | Validate optimization status | Comprehensive validation, JSON output, missing file detection |
| **Session Management** | `claude-session` | Manage conversation sessions | Git state capture, context preservation, markdown export |
| **Usage Analytics** | `claude-usage` | Monitor API costs and usage | Cost tracking, rate limits, CSV export |
| **Configuration Optimization** | `claude-optimize` | Tune configuration files | Performance analysis, automatic fixes, backup support |
| **Authentication** | `claude-switch` | Switch authentication modes | Pro/API switching, conflict resolution, status display |

## Configuration Files Reference

### Core Configuration Files

| File | Purpose | Location | Template Available |
|------|---------|----------|-------------------|
| **`.claude.json`** | Claude Code project configuration | Project root | ✅ `reposetup/artifacts/.claude.json` |
| **`.claudeignore`** | Performance optimization exclusions | Project root | ✅ `reposetup/artifacts/.claudeignore` |
| **`.claude-rules`** | Development automation constraints | Project root | ✅ `reposetup/artifacts/.claude-rules` |
| **`CLAUDE.md`** | Project documentation for Claude Code | Project root | ✅ `reposetup/artifacts/CLAUDE.md` |
| **`PROJECT_CONTEXT.md`** | Current project state documentation | Project root | ✅ `reposetup/artifacts/PROJECT_CONTEXT.md` |
| **`project-health.sh`** | Standalone health check script | Project root | ✅ `reposetup/artifacts/project-health.sh` |
| **`request-templates.txt`** | Template prompts for interactions | Project root | ✅ `reposetup/artifacts/request-templates.txt` |

### Configuration File Details

#### `.claude.json`
Project-specific Claude Code settings including:
- Project metadata (name, description)
- Development rules and constraints
- Context file references
- Code style preferences
- Testing and documentation preferences

#### `.claudeignore`
Performance optimization file that excludes:
- Version control files (`.git/`, `.gitignore`)
- IDE and editor files (`.vscode/`, `.idea/`, `*.swp`)
- OS generated files (`.DS_Store`, `Thumbs.db`)
- Build artifacts and temporary files
- Session management files

#### `.claude-rules`
Automation constraints that enforce:
- Minimal change policies
- Workflow requirements
- Forbidden actions
- Response format standards
- Development guidelines

## Usage Examples

### Setting Up a New Project

```bash
# Navigate to your project
cd /path/to/your-project

# Deploy Claude optimization files
claude-reposetup

# Verify setup with detailed validation
claude-repocheck --verbose

# Run project health check
./project-health.sh

# Start optimized Claude session
# Your repository is now Claude-ready!
```

### Managing Development Sessions

```bash
# Save current conversation context with git state
claude-session save "implementing-auth"

# Work on different feature
claude-session save "api-refactor" 

# List all sessions for this repository
claude-session list

# Resume previous session with full context
claude-session resume "implementing-auth"

# Export session for documentation
claude-session export "implementing-auth"

# Clean up old sessions (>30 days)
claude-session clean
```

### Monitoring Costs and Usage

```bash
# Check this week's usage summary
claude-usage

# Detailed daily breakdown
claude-usage daily

# Weekly usage summary
claude-usage weekly

# Monthly usage summary
claude-usage monthly

# Cost estimates and projections
claude-usage costs

# Current authentication and rate limit status
claude-usage status

# Export usage data to CSV
claude-usage export

# JSON output for automation
claude-usage --json summary
```

### Configuration Optimization

```bash
# Analyze current configuration efficiency
claude-optimize

# Apply recommended optimizations
claude-optimize --fix

# Apply optimizations with backups
claude-optimize --backup --fix

# Get analysis in JSON format
claude-optimize --json
```

### Authentication Management

```bash
# Show current authentication status
claude-switch

# Switch to SSO/Pro subscription mode
claude-switch --sso

# Switch to API key mode (pay-per-use)
claude-switch --api
```

## Tool Documentation

### claude-reposetup

Deploy Claude Code optimization files to any repository.

**What It Creates:**
- `.claude.json` - Project configuration
- `.claudeignore` - Performance optimization file
- `.claude-rules` - Development automation rules
- `CLAUDE.md` - Project documentation
- `PROJECT_CONTEXT.md` - Project state tracking
- `project-health.sh` - Health check script
- `request-templates.txt` - Interaction templates

**Key Features:**
- Template-based deployment from `reposetup/artifacts/`
- Automatic backup of existing files (timestamped)
- Dry-run mode for change preview
- Skip existing files by default
- Force replacement option

```bash
claude-reposetup                    # Setup current directory
claude-reposetup /path/to/project   # Setup specific directory  
claude-reposetup --replace          # Replace existing files with templates
claude-reposetup --dry-run          # Preview changes without applying
claude-reposetup --yes              # Skip confirmation prompts
```

### claude-repocheck

Validate and analyze Claude optimization status.

**What It Checks:**
- Presence of all required files
- JSON syntax validation
- File permission verification
- Placeholder content detection
- Git repository status
- Cross-script integration

**Key Features:**
- Colored output for easy reading
- Verbose mode for detailed analysis
- JSON output for automation
- Recommendations for missing files
- Integration with claude-reposetup

```bash
claude-repocheck                    # Check current directory
claude-repocheck /path/to/project   # Check specific directory
claude-repocheck --verbose          # Detailed validation output
claude-repocheck --quiet            # Only summary and errors
claude-repocheck --json             # Machine-readable output
```

### claude-session

Repository-specific conversation session management.

**What Gets Saved:**
- Git repository state (branch, commit hash, working directory status)
- Project context (CLAUDE.md, PROJECT_CONTEXT.md, .claude.json presence)
- Session metadata (timestamp, repository name, session notes)
- Sessions stored in `.claude/sessions/` within each repository

**Key Features:**
- Repository isolation (sessions are project-specific)
- Git state capture and restoration context
- Markdown export for documentation
- Automatic cleanup of old sessions
- Session timestamp and metadata tracking

```bash
claude-session save [name]          # Save named session with current git state
claude-session list                 # List all sessions for this repository
claude-session show <name>          # Show detailed session information
claude-session resume <name>        # Resume with project and git context
claude-session delete <name>        # Delete a specific session
claude-session export <name>        # Export session to markdown
claude-session clean                # Remove sessions older than 30 days
```

**How Resume Works:**
When you resume a session, you get context about:
- What branch you were working on
- What commit you were at when the session was saved
- What project configuration files were present
- When the session was created and last modified
- Any session notes or context that was captured

### claude-usage

Monitor Claude API usage and costs.

**Important Note:** This tool requires API key authentication mode. In SSO/Pro subscription mode, usage data is not available locally.

**What It Tracks:**
- Token usage (input/output)
- Request counts and patterns
- Cost estimates and projections
- Rate limit status and remaining quotas
- Usage trends over time

**Key Features:**
- Multiple time period analysis (daily, weekly, monthly)
- Cost estimation with current pricing
- CSV export for external analysis
- JSON output for automation
- Rate limit monitoring

```bash
claude-usage                        # Weekly usage summary
claude-usage daily                  # Daily breakdown
claude-usage weekly                 # Weekly summary
claude-usage monthly                # Monthly summary
claude-usage costs                  # Cost estimates and projections
claude-usage status                 # Authentication and rate limit status
claude-usage export                 # Export usage data to CSV
claude-usage --json summary         # JSON output for automation
claude-usage --period 30            # Analyze last 30 days
```

### claude-optimize

Optimize Claude configuration files for better performance.

**What It Analyzes:**
- `.claudeignore` effectiveness and coverage
- `.claude.json` configuration efficiency
- `CLAUDE.md` content organization
- `PROJECT_CONTEXT.md` optimization
- File size and structure impacts

**Key Features:**
- Performance impact analysis
- Automatic optimization suggestions
- Backup creation before changes
- JSON output for automation
- Configuration validation

```bash
claude-optimize                     # Analyze current directory setup
claude-optimize /path/to/project    # Analyze specific directory
claude-optimize --analyze           # Show analysis without making changes
claude-optimize --fix               # Apply recommended optimizations
claude-optimize --backup --fix      # Apply optimizations with backups
claude-optimize --json              # Analysis output in JSON format
```

### claude-switch

Switch between SSO/Pro subscription and API key authentication modes.

**Authentication Modes:**
- **SSO/Pro Subscription**: Default Claude Code authentication
- **API Key**: Pay-per-use API access with local cost tracking

**What It Manages:**
- Authentication mode switching
- Environment variable configuration
- Configuration file management
- Conflict detection and resolution

**Key Features:**
- Interactive authentication mode selection
- Automatic conflict resolution
- Status display and verification
- Environment configuration management

```bash
claude-switch                       # Interactive authentication mode menu
claude-switch --sso                 # Switch to SSO/Pro subscription mode
claude-switch --api                 # Switch to API key mode
```

**Authentication Status Display:**
- Current authentication mode (subscription/api/unknown)
- API key presence and validation
- Configuration file status
- Conflict warnings and resolution steps

## Advanced Features

### Template System

All tools use a centralized template system located in `reposetup/artifacts/`:

| Template File | Deployment Location | Purpose |
|--------------|-------------------|---------|
| `artifacts/.claude.json` | `.claude.json` | Project configuration template |
| `artifacts/.claudeignore` | `.claudeignore` | Performance optimization template |
| `artifacts/.claude-rules` | `.claude-rules` | Development rules template |
| `artifacts/CLAUDE.md` | `CLAUDE.md` | Project documentation template |
| `artifacts/PROJECT_CONTEXT.md` | `PROJECT_CONTEXT.md` | Project state template |
| `artifacts/project-health.sh` | `project-health.sh` | Health check script template |
| `artifacts/request-templates.txt` | `request-templates.txt` | Interaction templates |

### Cross-Tool Integration

**Recommendation Engine**: `claude-repocheck` automatically recommends running `claude-reposetup` for missing files.

**Consistent File Tracking**: Both setup and check tools use identical file lists for consistency.

**Template Synchronization**: All tools reference the same template files in `artifacts/` directory.

**Global Installation**: Single installer (`install-all.sh`) manages all tools with consistent PATH configuration.

### Session Management Workflow

```bash
# Start new feature work with automatic git context capture
claude-session save "feature-authentication-$(date +%Y%m%d)"

# Work with Claude Code (git state and context automatically tracked)

# Save major milestones with current git state
claude-session save "feature-auth-complete"

# Export for team documentation
claude-session export "feature-auth-complete" > docs/development-log.md

# Resume work later with full git and project context
claude-session resume "feature-authentication-20241122"
```

### Cost Optimization Strategy

```bash
# 1. Monitor current usage patterns
claude-usage daily --period 7

# 2. Optimize configuration for better performance
claude-optimize --fix

# 3. Validate optimization improvements
claude-repocheck --verbose

# 4. Track cost reduction over time
claude-usage costs --period 30
```

### Health Monitoring Workflow

```bash
# Check project health
./project-health.sh

# Comprehensive optimization validation
claude-repocheck --verbose

# Apply any recommended optimizations
claude-optimize --fix

# Verify final state
claude-repocheck
```

## Project Files Overview

### Main Executable Scripts

| Script | Global Command | Purpose | Key Functions |
|--------|---------------|---------|---------------|
| `install-all.sh` | N/A | Master installer | Install/update/uninstall all tools, PATH management |
| `project-health.sh` | N/A | Standalone health checker | Claude config validation, git status, project type detection |
| `reposetup/claude-reposetup.sh` | `claude-reposetup` | Repository optimization | Template deployment, backup creation, validation |
| `reposetup/claude-repocheck.sh` | `claude-repocheck` | Health validation | File checking, JSON validation, recommendations |
| `session/claude-session.sh` | `claude-session` | Session management | Git state capture, context preservation, export |
| `usage/claude-usage.sh` | `claude-usage` | Usage analytics | Cost tracking, usage analysis, rate limit monitoring |
| `optimize/claude-optimize.sh` | `claude-optimize` | Configuration optimization | Performance analysis, automatic fixes |
| `creds/claude-credchange.sh` | `claude-switch` | Authentication management | Mode switching, conflict resolution |

### Configuration and Documentation Files

| File | Purpose | Used By |
|------|---------|---------|
| `CLAUDE.md` | Main project documentation for Claude Code | All tools (project context) |
| `PROJECT_CONTEXT.md` | Current project state and development notes | Development workflow |
| `request-templates.txt` | Template prompts for Claude Code interactions | User guidance |
| `.claude.json` | Claude Code project configuration | claude-repocheck, claude-optimize |
| `.claudeignore` | Performance optimization exclusions | Claude Code, claude-optimize |
| `.claude-rules` | Development automation constraints | Claude Code |

### Template Files (artifacts/)

All files in `reposetup/artifacts/` serve as templates for deployment:

| Template | Target | Customization |
|----------|--------|---------------|
| `artifacts/.claude.json` | `.claude.json` | Project-specific metadata |
| `artifacts/.claudeignore` | `.claudeignore` | Repository-specific exclusions |
| `artifacts/.claude-rules` | `.claude-rules` | Project development rules |
| `artifacts/CLAUDE.md` | `CLAUDE.md` | Project architecture documentation |
| `artifacts/PROJECT_CONTEXT.md` | `PROJECT_CONTEXT.md` | Current state tracking |
| `artifacts/project-health.sh` | `project-health.sh` | Standalone health script |
| `artifacts/request-templates.txt` | `request-templates.txt` | Interaction templates |

## Error Handling and Safety Features

### Backup and Recovery
- **Automatic backups**: Files backed up before replacement with timestamp-based names
- **Dry-run mode**: Preview changes with `--dry-run` before applying
- **Confirmation prompts**: Interactive confirmations for destructive operations
- **Skip confirmations**: Use `--yes` flag for automated workflows

### Validation and Verification
- **JSON syntax validation**: Automatic validation of `.claude.json` files
- **File permission checks**: Verification that scripts are executable
- **Placeholder detection**: Identification of template content needing customization
- **Cross-platform compatibility**: Scripts tested on macOS and Linux

### Platform Compatibility
- **Bash 3.2+ support**: Compatible with older macOS bash versions
- **POSIX compliance**: Maximum compatibility across Unix-like systems
- **Path handling**: Proper handling of spaces and special characters
- **Dependency management**: Automatic installation of required tools

## Development and Contributing

### Development Setup

```bash
git clone https://github.com/johnklockenkemper/ClaudeDevTools.git
cd ClaudeDevTools

# Test individual tools
./reposetup/claude-reposetup.sh --help
./session/claude-session.sh --help

# Test installation system
./install-all.sh --list

# Test on a sample project
mkdir test-project && cd test-project
claude-reposetup --dry-run
```

### Testing Strategy

**Manual Testing:**
- Test scripts on both macOS and Linux environments
- Verify cross-platform compatibility (especially path handling)
- Test installation and uninstallation processes
- Validate template deployment and file replacement

**Integration Testing:**
- Test tool interactions (repocheck recommends reposetup)
- Verify global command installation
- Test session management across git state changes
- Validate authentication switching scenarios

### Code Style and Standards

- **File Naming**: kebab-case for scripts (`claude-toolname.sh`), lowercase for directories
- **Function Style**: snake_case functions with descriptive names and input validation
- **Error Handling**: `set -e` for strict mode, comprehensive input validation
- **Documentation**: Clear usage examples and help text in all scripts
- **Compatibility**: POSIX-compliant shell scripts with bash 3.2+ support

## Documentation

- **[CLAUDE.md](CLAUDE.md)**: Comprehensive project documentation and architecture overview
- **[Project Context](PROJECT_CONTEXT.md)**: Current repository state and development notes
- **[Request Templates](request-templates.txt)**: Template prompts for Claude Code interactions
- **Tool Help**: Run any command with `--help` for detailed usage information

## Support & Feedback

- **Tool Issues**: Run `./project-health.sh` to diagnose common problems
- **Installation Problems**: Use `./install-all.sh --list` to check installation status
- **Usage Questions**: Each tool provides detailed help with `--help` option
- **Development**: Check [CLAUDE.md](CLAUDE.md) for detailed project guidance

---

**Made for developers using Claude Code** | **Optimize once, benefit forever**