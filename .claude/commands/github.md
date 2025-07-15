# GitHub Integration Command

Extended helpers for GitHub workflows and CI/CD.

## Quick Commands

### Issues
```bash
# Create issue
.github/scripts/create-issue.sh "Title" "Description" "bug,help-wanted"

# List issues
gh issue list

# View issue
gh issue view <number>
```

### Pull Requests
```bash
# Create PR
gh pr create --fill

# Check PR CI status
gh pr checks

# View PR
.github/scripts/check-pr.sh
```

### Workflows
```bash
# Run formal verification
.github/scripts/run-workflow.sh formal-verification.yml

# View workflow runs
gh run list

# Watch current run
gh run watch
```

## Labels to Use

- `bug` - Something isn't working
- `enhancement` - New feature request
- `documentation` - Documentation improvements
- `formal-methods` - Related to TLA+/Alloy specs
- `clojurescript` - Implementation related
- `good-first-issue` - Good for newcomers
- `help-wanted` - Extra attention needed

## Workflow Tips

1. Always create issues before PRs
2. Reference issues in PR descriptions
3. Wait for CI to pass before merging
4. Use draft PRs for work in progress
5. Request reviews from relevant people
