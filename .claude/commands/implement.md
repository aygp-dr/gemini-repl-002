# Implementation Command

Structured approach to implementing features in the Gemini REPL.

## Workflow

1. **Read specification**
   - Check TLA+ spec in `specs/`
   - Review Alloy models
   - Understand requirements

2. **Write tests first**
   - Create test file
   - Define expected behavior
   - Run tests (they should fail)

3. **Implement feature**
   - Write ClojureScript code
   - Follow project conventions
   - Keep functions small

4. **Verify implementation**
   - Run tests
   - Check formal specs
   - Test manually

5. **Document changes**
   - Update relevant docs
   - Add inline comments
   - Update README if needed

## Code Style

- Use meaningful names
- Prefer pure functions
- Handle errors explicitly
- Add type hints where helpful
