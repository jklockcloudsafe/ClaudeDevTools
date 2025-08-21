#!/bin/bash
#
# Project health check for Claude Code optimization

echo "Project Health Check"
echo "======================="

# Check Claude configuration
if [[ -f .claude.json ]]; then
    echo "[OK] Claude configuration found"
else
    echo "[ERROR] Claude configuration missing - run claude-optimize"
fi

# Check documentation
if [[ -f CLAUDE.md ]]; then
    echo "[OK] Claude documentation found"
else
    echo "[ERROR] Claude documentation missing"
fi

# Check ignore file
if [[ -f .claudeignore ]]; then
    echo "[OK] Claude ignore file found"
else
    echo "[ERROR] Claude ignore file missing"
fi

# Check git status
if git status >/dev/null 2>&1; then
    echo "[OK] Git repository initialized"
    uncommitted=$(git status --porcelain | wc -l)
    if [[ $uncommitted -gt 0 ]]; then
        echo "[WARNING] $uncommitted uncommitted changes"
    fi
else
    echo "[WARNING] Not a git repository"
fi

# Check package files
if [[ -f package.json ]]; then
    echo "[OK] Node.js project detected"
    if [[ -d node_modules ]]; then
        echo "[OK] Dependencies installed"
    else
        echo "[WARNING] Run 'npm install' to install dependencies"
    fi
elif [[ -f requirements.txt ]] || [[ -f pyproject.toml ]]; then
    echo "[OK] Python project detected"
elif [[ -f Cargo.toml ]]; then
    echo "[OK] Rust project detected"
elif [[ -f go.mod ]]; then
    echo "[OK] Go project detected"
fi

# Check VS Code configuration
if [[ -d .vscode ]]; then
    echo "[OK] VS Code configuration found"
fi

echo ""
echo "[TIP] Recommendations:"
echo "- Keep CLAUDE.md updated with current project status"  
echo "- Use 'claude' command to start development sessions"
echo "- Monitor Claude Code usage through available tools"
echo "- Run this check regularly to maintain optimization"
