#!/bin/sh
# Check file naming conventions

set -e

# Check change requests
for file in change-requests/CR-*.org; do
    if [ -f "$file" ]; then
        base=$(basename "$file")
        if ! echo "$base" | grep -qE '^CR-[0-9]{3}-[a-z-]+\.org$'; then
            echo "✗ Invalid CR naming: $file"
            echo "  Expected: CR-XXX-lowercase-description.org"
            exit 1
        fi
    fi
done

# Check experiments
for file in experiments/EXP-*/; do
    if [ -d "$file" ]; then
        base=$(basename "$file")
        if ! echo "$base" | grep -qE '^EXP-[0-9]{3}-[a-z-]+$'; then
            echo "✗ Invalid experiment naming: $file"
            echo "  Expected: EXP-XXX-lowercase-description/"
            exit 1
        fi
    fi
done

echo "✓ File naming conventions passed"
