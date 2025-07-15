# UI Design Documentation

## Overview

The Gemini REPL provides a clean, terminal-based user interface with ASCII art branding and clear visual feedback.

## Components

### ASCII Art Banner

Displayed on startup using the `toilet` utility:

```
┏━╸┏━╸┏┳┓╻┏┓╻╻   ┏━┓┏━╸┏━┓╻
┃╺┓┣╸ ┃┃┃┃┃┗┫┃   ┣┳┛┣╸ ┣━┛┃
┗━┛┗━╸╹ ╹╹╹ ╹╹   ╹┗╸┗━╸╹  ┗━╸
```

### Prompt Design

- Simple, clean prompt: `gemini> `
- No clutter or unnecessary information
- Clear visual separation between user input and responses

### Response Formatting

Responses include:
1. Content text (wrapped appropriately)
2. Metadata line with key metrics

### Metadata Display

Compact single-line format:
```
[🟢 245 tokens | $0.0001 | 0.8s]
```

Components:
- **Confidence Indicator**:
  - 🟢 Green: <100 tokens (quick response)
  - 🟡 Yellow: 100-500 tokens (moderate)
  - 🔴 Red: >500 tokens (lengthy)
- **Token Count**: Total tokens used
- **Cost Estimate**: Approximate cost in USD
- **Duration**: Response time (adaptive units)

## Design Principles

1. **Minimalism**: Show only essential information
2. **Clarity**: Easy to scan and understand
3. **Consistency**: Uniform formatting throughout
4. **Accessibility**: Works in any terminal

## Banner Generation

The banner is generated using:
```bash
toilet -f future "Gemini REPL" > resources/repl-banner.txt
```

### Font Evolution

- Initially tried `mono12` font - too wide for 80 columns
- Switched to `future` font - compact and readable
- Fallback to simple text if `toilet` unavailable

## Color Usage

Currently minimal color usage:
- Default terminal colors
- Emoji indicators for visual feedback
- Future: Consider ANSI color for prompts

## Error Display

Errors shown clearly with prefix:
```
Error: API request failed
```

## Future UI Enhancements

1. **Syntax Highlighting**: For code blocks in responses
2. **Progress Indicators**: For long-running requests
3. **Theme Support**: Light/dark mode detection
4. **Unicode Borders**: Optional fancy borders
5. **Status Line**: Persistent status information

## Terminal Compatibility

- Designed for 80-column minimum width
- No special terminal requirements
- UTF-8 support recommended for emojis
- Works in ssh sessions

## Implementation Notes

- Banner loaded from file, not hard-coded
- All UI strings externalized for future i18n
- Responsive to terminal width changes
- Graceful degradation for limited terminals
