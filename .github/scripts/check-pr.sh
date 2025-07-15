#!/bin/sh
# Check PR status
set -e

# Get current branch
BRANCH=$(git branch --show-current)

# Check if PR exists for branch
PR_NUMBER=$(gh pr list --head "$BRANCH" --json number -q '.[0].number' || echo "")

if [ -z "$PR_NUMBER" ]; then
    echo "No PR found for branch: $BRANCH"
    echo "Create one with: gh pr create"
else
    echo "PR #$PR_NUMBER status:"
    gh pr view "$PR_NUMBER"
fi
