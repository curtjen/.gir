---
name: commit
description: Stage, commit, and push changes. Always ask the user to confirm the commit message before committing, and ask again before pushing.
user-invocable: true
allowed-tools: Bash, Read
---

# Commit and Push

Follow these steps in order:

1. Run `git status` and `git diff --stat` to see what has changed.
2. Run `git diff` on the changed files to understand the nature of the changes.
3. Draft a concise commit message (1–2 sentences, present tense, focused on "why" not "what").
4. **Show the commit message to the user and ask them to confirm before proceeding.** Do not commit until they approve.
5. Stage the relevant files and create the commit.
6. **Ask the user to confirm before pushing.** Show the target branch and remote. Do not push until they approve.
7. Push to the remote branch.
