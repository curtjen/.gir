---
name: checkpoint-standup
description: Print the standup notes from the latest checkpoint so they're ready to copy into MS Teams. Use when the developer says "standup", "standup notes", "print my standup", "what's my standup", "morning standup", "daily standup", or "what do I paste into Teams". Pulls from the most recent checkpoint for the current project — check project-local .checkpoints/ first, then the global log. Works across Claude Code and Codex.
user-invocable: true
allowed-tools: Bash, Read, Glob
---

# Standup

Extract and display the standup section from the most recent checkpoint so it's ready to copy into MS Teams.

---

## Step 1 — Identify the project

Run `git rev-parse --show-toplevel` to get the project name (last path component).

If not in a git repo, use the current working directory name.

---

## Step 2 — Find the latest checkpoint

Check in order, use the first location that has files:

1. `<project-root>/.checkpoints/` — most recently modified `.md` file
2. `~/dev_notes/checkpoints/<project-name>/` — most recently modified `.md` file

```bash
ls -t <location>/*.md 2>/dev/null | head -1
```

If no checkpoint exists: tell the user and suggest running `/checkpoint` first. Stop here.

---

## Step 3 — Extract and display the standup section

Read the checkpoint file and extract everything between `## Standup` and the next `---` or end of file.

Display it clearly with a header line showing the checkpoint date and project, followed by the standup content — formatted for direct copy-paste:

```
── Standup · gir · 2026-03-31 ──────────────────

**Yesterday**
- ...

**Today**
- ...

**Blockers**
...

─────────────────────────────────────────────────
```

---

## Step 4 — Brief follow-up

One line only:
- Checkpoint timestamp it was pulled from
- If they want a different date: `ls ~/dev_notes/checkpoints/<project-name>/` to see all available

---

## Edge cases

- **No standup section in the checkpoint**: Tell the user the checkpoint exists but has no standup section. Suggest re-running `/checkpoint` to generate a fresh one.
- **No checkpoint found**: Tell the user clearly. Suggest `/checkpoint` first.
- **Checkpoint file unreadable**: Try the next most recent file.
