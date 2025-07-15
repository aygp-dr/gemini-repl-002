---
name: Test infrastructure documentation
about: Document test scripts and infrastructure
title: 'Test Infrastructure Documentation'
labels: documentation, testing
assignees: ''

---

## Test Scripts Documentation

### Expect-based REPL Testing

The project uses expect scripts for automated REPL testing. Example script:

```expect
#!/usr/bin/expect -f
# Test basic REPL interactions

set timeout 10
spawn node target/main.js

expect "gemini>"
send "Hello\r"
expect "response"

expect "gemini>"
send "/help\r"
expect "Available commands"

expect "gemini>"
send "/exit\r"
expect "Goodbye!"
```

### Running Tests

1. **Unit tests**: `gmake test`
2. **Expect tests**: `./scripts/test-repl.exp`
3. **Manual testing**: `gmake run` then interact

### Test Coverage Areas

- [ ] Command parsing
- [ ] API request formatting
- [ ] Response handling
- [ ] Error scenarios
- [ ] Conversation context
- [ ] Token tracking

### Future Test Infrastructure

- Property-based testing with test.check
- API mocking for offline tests
- Performance benchmarks
- Load testing for rate limits
