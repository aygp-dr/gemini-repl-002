---
name: Banner Implementation
about: ASCII art banner for REPL startup
title: 'Add ASCII art banner on REPL startup #19'
labels: enhancement, ui
assignees: ''

---

## Description

Add an ASCII art banner that displays when the REPL starts to make it more visually appealing.

## Implementation Details

1. Use `toilet` command to generate ASCII art
2. Store in `resources/repl-banner.txt`
3. Load and display on startup
4. Provide fallback for systems without `toilet`

## Initial Issue

When using `toilet -f mono12`, the banner wrapped on standard 80-column terminals.

## Solution

Changed to `toilet -f future` which produces more compact output:

```
┏━╸┏━╸┏┳┓╻┏┓╻╻   ┏━┓┏━╸┏━┓╻
┃╺┓┣╸ ┃┃┃┃┃┗┫┃   ┣┳┛┣╸ ┣━┛┃
┗━┛┗━╸╹ ╹╹╹ ╹╹   ╹┗╸┗━╸╹  ┗━╸
```

## Integration

- Makefile target: `resources/repl-banner.txt`
- Core.cljs: `display-banner` function
- Fallback: Simple text banner if file missing

## Testing

- [X] Banner displays on startup
- [X] Fits in 80-column terminal
- [X] Fallback works when file missing
- [X] No performance impact
