#!/bin/sh
# Create a new issue using GitHub CLI
set -e

if [ $# -lt 2 ]; then
    echo "Usage: $0 <title> <body> [labels]"
    exit 1
fi

TITLE="$1"
BODY="$2"
LABELS="${3:-}"

if [ -n "$LABELS" ]; then
    gh issue create --title "$TITLE" --body "$BODY" --label "$LABELS"
else
    gh issue create --title "$TITLE" --body "$BODY"
fi
