# PROJECT CONTEXT
<!-- Property of CloudSafe -->

## Current State

- **Project Type**: Shell script suite for Claude Code optimization
- **Tech Stack**: Bash shell scripts (3.2+ compatible), JSON configuration files, CLI tools
- **File Structure**: Organized by functionality - reposetup/, session/, usage/, optimize/, creds/
- **Build Process**: No compilation needed; scripts are executable shell files

## Development Rules

- **Change Policy**: Follow .claude-rules file; minimal changes only; test on macOS and Linux
- **Dependencies**: External: git, curl, jq (auto-installed); Internal: cross-script integration
- **Frameworks**: Pure bash with POSIX compliance for maximum compatibility
- **Optimization**: Scripts are idempotent and can be run multiple times safely
- **File Creation**: Follow existing directory structure; use template system in artifacts/

## Current Architecture

- **Main Files**: 
  - `install-all.sh` - Master installer for all tools
  - `reposetup/claude-reposetup.sh` - Repository optimization deployment
  - `session/claude-session.sh` - Conversation session management
  - `usage/claude-usage.sh` - API usage and cost tracking
- **Entry Points**: Global commands installed to ~/bin/ via install-all.sh
- **Configuration**: Template files in reposetup/artifacts/ deployed to target repositories
- **Dependencies**: Self-contained with automatic dependency checking and installation

## Active Development

- **Current Task**: Repository documentation and configuration updates
- **Recent Changes**: 
  - Updated .claude.json with actual project information
  - Customized .claudeignore for shell script repository
  - Reviewed and updated PROJECT_CONTEXT.md with real project details
- **Known Issues**: README contains references to missing LICENSE file
- **Next Planned**: Update README to fix LICENSE references and GitHub URLs

## Task Queue

1. [x] Update Claude configuration files with project-specific content
2. [ ] Fix README LICENSE references and GitHub URLs
3. [ ] Verify all CLI examples in README work correctly
4. [ ] Ensure artifact templates are up to date

## Code Conventions

- **File Naming**: kebab-case for scripts (claude-toolname.sh), lowercase for directories
- **Function Style**: snake_case functions with descriptive names and input validation
- **Import Style**: Source other scripts with relative paths and error checking
- **Formatting**: 4-space indentation, consistent error handling patterns
- **Error Handling**: set -e for strict mode, comprehensive input validation, user-friendly error messages

## Testing Strategy

**Manual Testing:**
- Test scripts on both macOS and Linux environments
- Verify cross-platform compatibility (especially path handling)
- Test installation and uninstallation processes

**Integration Testing:**
- Test tool interactions (repocheck recommends reposetup)
- Verify global command installation works correctly
- Test template deployment and file replacement scenarios

## HOW TO USE THIS FILE

At the start of each Claude Code session:
1. Read this PROJECT_CONTEXT.md to understand current state
2. Check CLAUDE.md for detailed project architecture 
3. Update "Current Task" section when starting new work
4. Update "Recent Changes" when tasks complete
5. Review any specific implementation notes

## SESSION CHECKLIST

- [ ] Read CLAUDE.md project documentation
- [ ] Read PROJECT_CONTEXT.md (this file)  
- [ ] Understand current project status and priorities
- [ ] Review any recent changes that might affect current work