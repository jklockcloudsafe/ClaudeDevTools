# CLAUDE.md
<!-- Property of CloudSafe -->

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

[Describe your project in 1-2 sentences - what it does and its main purpose]

**Tech Stack:**
- **Language**: [Primary programming language(s)]
- **Framework**: [Framework/library if applicable]
- **Database**: [Database technology if applicable]  
- **Tools**: [Build tools, package managers, etc.]
- **Testing**: [Testing framework/approach]
- **Deployment**: [Deployment platform/method]

## Architecture & File Structure

**Directory Structure:**
```
/your-project/
├── README.md                    # Project documentation
├── CLAUDE.md                    # This file - Claude Code guidance
├── PROJECT_CONTEXT.md           # Current project context
├── src/                         # Source code
├── tests/                       # Test files
├── docs/                        # Documentation
├── config/                      # Configuration files
└── scripts/                     # Build/deployment scripts
```

**Key Components:**
- **[Component 1]**: Brief description of main component
- **[Component 2]**: Brief description of another component
- **[Component 3]**: Brief description of third component

## Development Workflow

**Setup Process:**
1. **Installation**: Install dependencies and set up development environment
2. **Configuration**: Configure necessary tools and settings
3. **Testing**: Run tests to ensure everything works correctly

**Common Commands:**
```bash
# Install dependencies
npm install           # For Node.js projects
pip install -r requirements.txt  # For Python projects

# Development server
npm start            # Start development server
python manage.py runserver  # Django example

# Testing
npm test             # Run tests
pytest               # Python testing
```

## Key Features

**[Feature 1]:**
- Brief description of first key feature
- What it does and why it's important

**[Feature 2]:**
- Brief description of second key feature
- What it does and why it's important

**[Feature 3]:**
- Brief description of third key feature
- What it does and why it's important

## Common Development Tasks

**Building the Project:**
```bash
# Add your build commands here
npm run build
# or
make build
```

**Running Tests:**
```bash
# Add your test commands here
npm test
# or
python -m pytest
```

**Linting and Formatting:**
```bash
# Add your linting/formatting commands here
npm run lint
npm run format
```

**Database Operations:**
```bash
# Add database-related commands if applicable
npm run db:migrate
npm run db:seed
```

## Configuration

**Environment Variables:**
- `NODE_ENV`: Development/production environment
- `DATABASE_URL`: Database connection string
- `API_KEY`: External service API key
- [Add other relevant environment variables]

**Important Files:**
- `.env.example`: Template for environment variables
- `config/`: Configuration files directory
- [List other important configuration files]

## Architecture Patterns

**[Pattern 1]:**
- Explanation of architectural pattern used
- Why this pattern was chosen

**[Pattern 2]:**
- Another architectural consideration
- Implementation details

## Dependencies

**Core Dependencies:**
- List main runtime dependencies
- Brief explanation of what each does

**Development Dependencies:**
- List development/testing dependencies
- Purpose of each dependency

## Troubleshooting

**Common Issues:**
- Issue 1: Description and solution
- Issue 2: Description and solution
- Issue 3: Description and solution

**Debugging:**
- How to enable debug mode
- Where to find logs
- Common debugging techniques