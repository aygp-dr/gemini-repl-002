# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a ClojureScript REPL interface for Google's Gemini API with formal verification using TLA+ and Alloy.

## Build & Test Commands
- **Setup**: `npm install` followed by `cp .env.example .env`
- **Build**: `gmake build` or `npx shadow-cljs compile app`
- **Development**: `gmake dev` (includes live reload)
- **Run**: `gmake run` or `node target/main.js`
- **Test**: `gmake test`
- **Lint**: `gmake lint` (uses clj-kondo if available)
- **Clean**: `gmake clean`
- **Formal verification**: `cd specs && gmake check-tla check-alloy`

## Code Style Guidelines
- **ClojureScript**: Follow standard Clojure style guide
- **Prefer pure functions** and immutable data structures
- **Use meaningful names**: prefer clarity over brevity
- **Error handling**: Use explicit error messages, log errors appropriately
- **Type hints**: Add where it improves performance or clarity
- **Comments**: Only when code intent isn't obvious
- **Git commits**: Use conventional commits format

## Project Structure
- `src/gemini_repl/core.cljs` - Main REPL implementation
- `test/` - Test files using cljs.test
- `specs/` - TLA+ and Alloy formal specifications
- `.claude/commands/` - Claude-specific command documentation
- `scripts/` - Build and utility scripts
- `*-SETUP.org` - Literate programming source files (do not edit directly)

## Key Features to Maintain
1. **Conversation history** - Maintain context across interactions
2. **Slash commands** - All commands start with `/`
3. **Formal verification** - Keep specs in sync with implementation
4. **Logging** - Support both file and FIFO logging
5. **Token tracking** - Accurate cost estimation

## Development Workflow
1. Read existing code before making changes
2. Run tests before committing
3. Update formal specs if behavior changes
4. Use org-mode tangling for setup files
5. BSD compatibility: use `gmake` not `make`

## Common Tasks
- **Add new slash command**: Update core.cljs handle-* functions and process-input
- **Change API behavior**: Update both code and relevant TLA+ specs
- **Add configuration**: Update config map and .env.example
- **Create experiment**: Use experiments/ directory with EXP-XXX naming

## Testing Approach
- Unit tests for pure functions
- Integration tests for API interactions
- Property-based testing where applicable
- Manual testing with expect scripts

## Important Notes
- This is a FreeBSD environment - use `gmake` instead of `make`
- Pre-commit hooks enforce trailing newlines and no trailing whitespace
- Project uses literate programming - many files are generated from .org sources
- Formal specifications are not optional - they must be maintained

## Reproduction Information
This project is part of a reproducible build exercise. The goal is that all project files can be regenerated from the *-SETUP.org files through org-mode tangling.
