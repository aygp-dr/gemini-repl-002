# GitHub Integration Command

Helpers for GitHub workflows and CI/CD.

## Available Actions

### Create Issue
```bash
gh issue create --title "Title" --body "Description"
```

### Create PR
```bash
gh pr create --title "Title" --body "Description"
```

### Run Workflow
```bash
gh workflow run formal-verification.yml
```

## CI/CD Triggers

- Push to main: Run all tests
- PR opened: Run linting and tests
- Tag created: Build release
- Manual: Formal verification

## Labels

- `bug` - Something isn't working
- `enhancement` - New feature
- `formal-methods` - Related to TLA+/Alloy
- `clojurescript` - Implementation related
