---
name: checkpoint
description: Save a context checkpoint for the current project so you can resume exactly where you left off. Use this skill when the developer says "checkpoint", "save my place", "context switch", "switching projects", "switching tasks", "wrapping up", "end of day", "EOD", or "I need to step away". Also use proactively when the developer is about to switch projects or tasks and hasn't saved context yet. Works across Claude Code and Codex.
user-invocable: true
allowed-tools: Bash, Read, Write, Glob, Grep
---

# Checkpoint

Save a snapshot of current project state so you can return to it without reorientation time. The output is a markdown file with an immediate-action "Resume here" section at the top and supporting context below.

---

## Step 1 — Verify git repo

Run `git rev-parse --show-toplevel` to confirm you're in a git repository and capture the repo root path and repo name (the last component of the path).

If this fails (not a git repo), tell the user, use the current working directory name as the project name, and save to `~/dev_notes/checkpoints/<dir-name>/`. Continue with the remaining steps — a checkpoint is still useful without git.

---

## Step 2 — Determine checkpoint type

Infer the type from what the user said if possible:
- **task** — staying in this project, switching to a different task
- **project** — leaving this project to work on something else
- **eod** — done for the day or stepping away for an extended period

If you can infer it confidently (e.g., "wrapping up for the day" → eod), state your inference and confirm. If unclear, ask. Keep it to one quick question.

---

## Step 3 — Gather git context

Run all of these in parallel:

```bash
git log --since="midnight" --oneline
git branch --show-current
git status --short
git diff --stat
git stash list
git log --oneline -10
```

Interpret the results:
- **No commits today**: Normal — note it clearly. The developer may have worked without committing.
- **Current branch**: Capture the branch name. If it's `main` or `master`, note that in the State section.
- **Uncommitted changes**: Parse `git status --short` and `git diff --stat` together — understand what's staged vs. unstaged.
- **Stashes**: If any entries are older than 7 days (check the timestamp in the stash list), flag them as stale.
- **Detached HEAD**: Note this explicitly in the State section.

---

## Step 4 — Find recently modified files and scan for markers

Find files modified recently (excluding `.git/`, `node_modules/`, `dist/`, `.next/`, `build/`):

```bash
find <repo-root> -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/dist/*' -not -path '*/.next/*' -not -path '*/build/*' -newer <repo-root>/.git/index -type f 2>/dev/null | head -30
```

From that file list, use Grep to find `TODO`, `FIXME`, and `HACK` markers — but only in files that also appear in `git status` or today's commits. A handful of relevant findings is better than a dump of everything.

---

## Step 5 — Check for notes files

Look in the repo root for: `NOTES.md`, `TODO.md`, `CHANGELOG.md`, `.notes/`, and any `.md` files with "notes" or "todo" in the name (case-insensitive).

Read files under 100 lines in full. For longer files, read the first 30 lines. These often contain context the developer has already written for themselves.

---

## Step 6 — Ask the user three questions (all at once)

Ask all three together — end of day or mid-task, the developer doesn't want an interrogation:

1. What were you in the middle of / what's the current task?
2. What's the first thing to do when you return?
3. Any blockers, open questions, decisions pending, or links to capture?

All three are optional. If the user skips any, synthesize from git context.

---

## Step 7 — Generate the checkpoint document

Use this structure exactly:

```markdown
# Checkpoint — <TYPE> — YYYY-MM-DD HH:MM

**Project:** <repo-name>
**Branch:** `<branch-name>`
**Type:** task | project | eod

---

## Resume here

[The most important section — write this first. Specific and actionable: what file to open, what command to run, what decision to make next. 3–6 bullets. This is what gets read when the developer returns cold.]

---

## Current task

[Plain-language description of what was being worked on. Synthesized from user input and git context — not a raw dump. 2–4 sentences.]

---

## State

**Uncommitted changes:** [prose summary, or "None — working tree is clean."]
**Stashes:** [list entries, or "None." Flag entries older than 7 days as stale.]
**TODOs in flight:** [relevant TODO/FIXME/HACK from recently changed files, or "None found."]

### Commits today
- `<hash>` — <message>

[If no commits: "No commits today."]

### Files in flight

[Staged, modified, and untracked files — skip lock files, build artifacts, and generated files. If the diff is very large (e.g., a dependency update), summarize the pattern instead of listing everything.]

---

## Standup (copy-paste for Teams)

**Yesterday / Last session**
[2–4 bullets synthesized from commits and work description — past tense, human-readable, not raw commit messages]

**Today / Next session**
[From the "first thing to do" input and any open threads]

**Blockers**
[From user input, or "None."]

---

## Notes

[User-provided extras from question 3. Omit this section entirely if the user provided nothing.]
```

Write synthesized prose — don't dump raw command output. The commits list is the one exception where verbatim hashes are appropriate.

---

## Step 8 — Save the file

Get the current date and time:
```bash
date +%Y-%m-%d_%H%M%S
date "+%Y-%m-%d %H:%M"
```

Default save path: `~/dev_notes/checkpoints/<project-name>/YYYY-MM-DD_HHMMSS-<type>.md`

Only save to the project directory (`<project-root>/.checkpoints/`) if the user explicitly requests it. If you do save locally:
- Do NOT modify `.gitignore`
- Tell the user the file is saved locally and is not gitignored — they'll need to add it themselves if they don't want it committed

Create the directory and write the file:
```bash
mkdir -p ~/dev_notes/checkpoints/<project-name>
```
Then use the Write tool to write to the full expanded path (resolve `~` to the actual home path).

If a checkpoint file for this exact timestamp already exists (unlikely but possible), append `-2` to the filename.

---

## Step 9 — Confirm

Tell the user:

```
Checkpoint saved: ~/dev_notes/checkpoints/<project-name>/YYYY-MM-DD_HHMMSS-<type>.md

The standup section is ready to copy into Teams.
```

Keep it brief. The developer is switching context and wants this done.

---

## Edge cases

- **No commits, no changed files**: Generate the document anyway using user input. Note the clean state — it's useful information.
- **Not in a git repo**: Use the current directory name as project name, save to global location, note there's no git context.
- **Detached HEAD**: Flag explicitly in the State section.
- **Huge diff** (deps update, generated files): Summarize the pattern ("87 files changed, primarily in `node_modules/`") instead of listing every file.
- **Stale stashes** (7+ days old): Flag them in the State section — often forgotten WIP.
