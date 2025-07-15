#!/bin/sh
# Trigger a workflow manually
set -e

if [ $# -lt 1 ]; then
    echo "Usage: $0 <workflow-name>"
    echo "Available workflows:"
    gh workflow list
    exit 1
fi

WORKFLOW="$1"
shift

gh workflow run "$WORKFLOW" "$@"
