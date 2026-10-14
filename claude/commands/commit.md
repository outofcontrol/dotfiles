---
description: Create a git commit with a conventional message
allowed-tools: Bash(git add:*), Bash(git diff:*), Bash(git commit:*)
model: haiku
---

# Context
- Git status: !`git status --porcelain`
- Diff: !`git diff HEAD`

Create a commit message following Conventional Commits. Stage all changes and commit.
