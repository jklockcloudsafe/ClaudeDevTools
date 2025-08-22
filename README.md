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

### Individual Installation

```bash
# Install specific tools
./reposetup/claude-reposetup.sh --install
./session/claude-session.sh --install
```

### Requirements

- **Shell**: Bash 3.2+ (macOS/Linux compatible)
- **Dependencies**: git, curl, jq (installed automatically if missing)
- **Permissions**: Write access to `~/bin` directory

## Core Tools Overview

| Tool | Purpose | Use Case | Quick Command |
|------|---------|----------|---------------|
| **claude-reposetup** | Deploy Claude optimization files | Setup new project | `claude-reposetup` |
| **claude-repocheck** | Validate optimization status | Health monitoring | `claude-repocheck --verbose` |
| **claude-session** | Manage conversation sessions | Save/resume work | `claude-session save feature-x` |
| **claude-usage** | Monitor API costs and usage | Cost tracking | `claude-usage costs` |
| **claude-optimize** | Tune configuration files | Performance optimization | `claude-optimize --fix` |
| **claude-switch** | Switch authentication modes | Manage API/Pro access | `claude-switch` |

## Usage Examples

### Setting Up a New Project

```bash
# Navigate to your project
cd /path/to/your-project

# Deploy Claude optimization files
claude-reposetup

# Verify setup
claude-repocheck

# Start optimized Claude session
# Your repository is now Claude-ready!
```

### Managing Development Sessions

```bash
# Save current conversation context
claude-session save "implementing-auth"

# Work on different feature
claude-session save "api-refactor" 

# Resume previous session with full context
claude-session resume "implementing-auth"

# Export session for documentation
claude-session export "implementing-auth"
```

### Monitoring Costs and Usage

```bash
# Check this week's usage
claude-usage

# Detailed daily breakdown
claude-usage daily

# Cost estimates and projections
claude-usage costs

# Export usage data  
claude-usage export
```

### Switching Authentication

```bash
# Show current authentication status
claude-switch

# Switch authentication modes
claude-switch --sso                 # SSO/Pro subscription
claude-switch --api                 # API key mode (pay-per-use)
```

## Tool Documentation

### claude-reposetup

Deploy Claude Code optimization files to any repository.

**Key Features:**
- Creates `.claude.json`, `.claudeignore`, `CLAUDE.md`, `.claude-rules`
- Generates `PROJECT_CONTEXT.md` and request templates
- Backup existing files before replacement
- Dry-run mode for preview

```bash
claude-reposetup                    # Setup current directory
claude-reposetup /path/to/project   # Setup specific directory  
claude-reposetup --replace          # Replace existing files
claude-reposetup --dry-run          # Preview changes
```

### claude-repocheck

Validate and analyze Claude optimization status.

**Key Features:**
- Comprehensive health checks
- Missing file detection
- Configuration validation
- JSON output for automation

```bash
claude-repocheck                    # Check current directory
claude-repocheck --verbose          # Detailed analysis
claude-repocheck --json             # Machine-readable output
claude-repocheck /path/to/project   # Check specific directory
```

### claude-session

Repository-specific conversation session management that captures git state and project context.

**What Gets Saved:**
- Git repository state (branch, commit hash, working directory)
- Project context (presence of CLAUDE.md, PROJECT_CONTEXT.md, .claude.json)
- Session metadata (timestamp, repository name)
- Sessions stored in `.claude/sessions/` within each repository

**Key Features:**
- Save conversation contexts with full project state
- Resume sessions with git and project context
- Export sessions to markdown for documentation
- Repository-specific session isolation

```bash
claude-session save feature-x       # Save named session with current git state
claude-session list                 # List all sessions for this repository
claude-session resume feature-x     # Resume with project context
claude-session export feature-x     # Export to markdown
claude-session clean                # Remove old sessions (>30 days)
```

**How Resume Works:**
When you resume a session, you get context about what branch you were on, what commit you were at, what project configuration was present, and when the session was created. This helps Claude Code understand the project state when you return to work.

### claude-usage

Monitor Claude API usage and costs (API key mode only).

**Important:** This tool only works when using API key authentication. In SSO/Pro subscription mode, usage data is not available locally and showing no data is expected behavior.

**Log File Locations:**
- macOS: `~/Library/Logs/Claude/`
- Linux: `~/.config/claude/logs/` or `~/.local/share/claude/logs/`

**Key Features:**
- Real-time usage analytics (API mode only)
- Cost estimation and projections
- Rate limit monitoring
- CSV export capabilities

```bash
claude-usage                        # Weekly summary (if logs available)
claude-usage daily                  # Daily breakdown
claude-usage costs                  # Cost estimates
claude-usage --period 30            # Last 30 days
claude-usage --json                 # JSON output
```

**Alternative Usage Monitoring:**
- Use Claude Code's built-in `/status` command
- Monitor usage in your Anthropic console
- Check VS Code status bar (if using Claude Code extension)

### claude-optimize

Optimize Claude configuration files for better performance.

**Key Features:**
- Analyze configuration efficiency
- Automatic optimization suggestions
- Backup before changes
- Performance metrics

```bash
claude-optimize                     # Analyze current setup
claude-optimize --fix              # Apply optimizations
claude-optimize --backup --fix     # Apply with backups
claude-optimize --json              # Analysis output
```

### claude-switch

Switch between SSO/Pro subscription and API key authentication.

**Key Features:**
- Command-line authentication switching
- Conflict prevention and cleanup
- Environment configuration
- Status verification

```bash
claude-switch                       # Show current authentication status
claude-switch --sso                 # Switch to SSO/Pro subscription mode
claude-switch --api                 # Switch to API key mode (pay-per-use)
```

**Authentication Status Display:**
- Current authentication mode (subscription/api/unknown)
- API key presence
- Configuration file status
- Conflict warnings if API key is set in subscription mode

## Advanced Features

### Configuration Templates

All tools use a robust template system located in `reposetup/artifacts/`:

- **`.claude.json`**: Project-specific Claude Code settings
- **`.claudeignore`**: Performance optimization exclusions  
- **`CLAUDE.md`**: Project context and instructions
- **`.claude-rules`**: Automation constraints
- **`PROJECT_CONTEXT.md`**: Current state documentation

### Session Management Workflow

```bash
# Start new feature work
claude-session save "feature-$(date +%Y%m%d)"

# Work with Claude Code (sessions auto-track context)

# Save major milestones  
claude-session save "feature-complete"

# Export for documentation
claude-session export "feature-complete" > docs/development-log.md
```

### Cost Optimization Strategies

```bash
# Monitor usage patterns
claude-usage daily --period 7

# Optimize configurations
claude-optimize --fix

# Validate improvements
claude-repocheck --verbose

# Track cost reduction
claude-usage costs
```

## Documentation

- **[CLAUDE.md](CLAUDE.md)**: Comprehensive project documentation and usage instructions
- **[Project Context](PROJECT_CONTEXT.md)**: Current repository state and development notes
- **Tool Help**: Run any command with `--help` for detailed usage information

## Contributing

We welcome contributions! Here's how to get started:

1. **Fork** the repository
2. **Clone** your fork locally
3. **Create** a feature branch
4. **Test** your changes across different environments
5. **Submit** a pull request

### Development Setup

```bash
git clone https://github.com/yourusername/ClaudeDevTools.git
cd ClaudeDevTools

# Test individual tools
./reposetup/claude-reposetup.sh --help
./session/claude-session.sh --help

# Test installation
./install-all.sh --list
```

## License

This project is provided as-is for educational and development purposes.

## Support & Feedback

- **Issues**: [GitHub Issues](https://github.com/johnklockenkemper/ClaudeDevTools/issues)
- **Discussions**: [GitHub Discussions](https://github.com/johnklockenkemper/ClaudeDevTools/discussions)
- **Documentation**: Check [CLAUDE.md](CLAUDE.md) for detailed guidance

---

**Made for developers using Claude Code** | **Optimize once, benefit forever**