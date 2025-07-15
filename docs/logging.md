# Logging System Documentation

## Overview

The Gemini REPL implements a dual logging system for debugging and monitoring:
1. **FIFO logging** - Real-time log streaming
2. **File logging** - Persistent log storage

## Configuration

Configure logging via environment variables:

```bash
# Enable logging
export GEMINI_LOG_ENABLED=true

# Set log file path (default: logs/gemini-repl.log)
export GEMINI_LOG_FILE=logs/gemini-repl.log

# Set FIFO path (default: /tmp/gemini-repl.fifo)
export GEMINI_LOG_FIFO=/tmp/gemini-repl.fifo

# Set log level (default: info)
export GEMINI_LOG_LEVEL=debug
```

## Usage

### Real-time Log Monitoring

1. Create the FIFO:
   ```bash
   mkfifo /tmp/gemini-repl.fifo
   ```

2. Start monitoring in one terminal:
   ```bash
   cat /tmp/gemini-repl.fifo | jq .
   ```

3. Run the REPL in another terminal:
   ```bash
   GEMINI_LOG_ENABLED=true npm run dev
   ```

### File-based Logging

Logs are automatically written to `logs/gemini-repl.log`:

```bash
# View logs
tail -f logs/gemini-repl.log

# Parse JSON logs
cat logs/gemini-repl.log | jq '.type == "error"'
```

## Log Format

All logs are JSON formatted:

```json
{
  "timestamp": "2025-07-15T10:30:00.000Z",
  "type": "request|response|error|info",
  "data": {
    "prompt": "user input",
    "duration": 850,
    "tokens": 245
  }
}
```

## Log Types

- **request** - API request sent
- **response** - API response received
- **error** - Error occurred
- **info** - General information

## Development Mode

The Makefile automatically enables logging in dev mode:

```bash
make dev
# Equivalent to: GEMINI_LOG_ENABLED=true npx nodemon ...
```

## Troubleshooting

### FIFO Not Working

If FIFO logging fails, the system gracefully continues with file logging only.

### Permission Issues

Ensure the logs directory is writable:
```bash
mkdir -p logs
chmod 755 logs
```

### Log Rotation

Currently not implemented. For production use, consider:
- logrotate configuration
- Periodic cleanup scripts
- Size-based rotation
