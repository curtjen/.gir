---
name: checkpoint-load
description: Load the most recent checkpoint for the current project so you can pick up exactly where you left off. Use when the developer says "load checkpoint", "load my checkpoint", "what was I working on", "where did I leave off", "catch me up", "what's my checkpoint", "resume my work", or when starting a new session on a project. Check the current project's local .checkpoints/ directory first, then fall back to the global checkpoint log. Works across Claude Code and Codex.
user-invocable: true
allowed-tools: Bash, Read, Glob
---

# Load Checkpoint

Find and display the most recent checkpoint for the current project so the developer can immediately see where they left off.

---

## Step 1 — Identify the project

Run `git rev-parse --show-toplevel` to get the project root and name (last path component).

If not in a git repo, use the current working directory name as the project name.

---

## Step 2 — Find the latest checkpoint

Check these locations in order, stopping at the first one that has files:

1. **Project-local**: `<project-root>/.checkpoints/` — list `.md` files sorted by modification time, take the most recent
2. **Global log**: `~/dev_notes/checkpoints/<project-name>/` — list `.md` files sorted by modification time, take the most recent

```bash
ls -t <location>/*.md 2>/dev/null | head -1
```

If neither location has checkpoint files: tell the user no checkpoint exists for this project and suggest running `/checkpoint` to create one. Stop here.

---

## Step 3 — Read and display the checkpoint

Read the full checkpoint file and display its contents in the conversation.

Lead with the **Resume here** section — this is what the developer needs first. The full file follows.

---

## Step 4 — Brief follow-up

After displaying, note in one or two lines:
- The checkpoint timestamp and type (from the filename or header)
- How many older checkpoints exist in the same directory (just a count — don't list them)
- That they can run `/checkpoint` when ready to save a new one

Don't pad this out. The developer is trying to get back to work.

---

## Edge cases

- **No checkpoint found**: Tell the user clearly. Suggest `/checkpoint` to create one. Don't attempt to reconstruct context from git — that's the checkpoint skill's job.
- **Checkpoint file is unreadable or malformed**: Note the issue, then try the next most recent file in the directory.
- **Multiple projects with similar names**: The project name is derived from the git repo root directory name. If this creates ambiguity, show the full path of the checkpoint file so the developer can confirm it's the right project.
- **Project-local checkpoint is older than global**: Still prefer the project-local one — it was intentionally placed there. Mention the discrepancy so the developer is aware.
