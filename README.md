# gir — dotfiles & tool installer

Modular dotfiles and tool setup for Mac, Linux, WSL, and SSH servers.

`gir` is named after GIR from *Invader Zim*, the robot assistant.

## Quick install

```bash
# Via curl (clones repo to ~/.gir then runs installer)
curl -fsSL https://raw.githubusercontent.com/curtjen/.gir/v2/install.sh | bash

# Via npx (no git history)
npx degit curtjen/.gir#v2 ~/.gir && ~/.gir/install.sh

# Manual
git clone -b v2 https://github.com/curtjen/.gir.git ~/.gir && ~/.gir/install.sh
```

## Selective install

Install specific modules only:

```bash
~/.gir/install.sh zsh vim nvm
```

## How it works

- Each tool lives in `modules/<name>/install.sh`
- `install.sh` discovers and runs all modules automatically
- Existing dotfiles are **backed up** to `~/_gir_backup/<timestamp>/` before being replaced with symlinks
- Modules declare which platforms they support — GUI-only tools are skipped on SSH servers

## Modules

| Module           | Platforms     | What it does                               |
|------------------|---------------|--------------------------------------------|
| `zsh`            | all           | Zsh + Oh My Zsh + Powerlevel10k            |
| `vim`            | all           | Vim + Vundle plugins                       |
| `bash`           | all           | Bash config                                |
| `fzf`            | all           | Fuzzy finder for the terminal              |
| `nvm`            | all           | Node Version Manager + LTS Node            |
| `neovim`         | all           | Neovim + ripgrep                           |
| `claude-skills`  | all           | Symlink repo skills into `~/.claude/skills`|
| `codex-skills`   | all           | Sync Claude skills into Codex skills       |
| `morning-routine` | all          | Morning startup command with local config  |
| `homebrew`       | macOS         | Homebrew + Brewfile packages               |
| `wezterm`        | macOS, no SSH | WezTerm terminal + config                  |

## Adding a new module

1. Create `modules/<name>/install.sh`:

```bash
#!/bin/bash

MODULE_NAME="mytool"
MODULE_DESCRIPTION="My tool description"
MODULE_PLATFORMS="all"   # all | macos | linux | no_ssh | no_wsl (space-separated)

install_module() {
  # rcs_link <source> <target> backs up existing files then creates a symlink
  rcs_link "$RCS_DIR/modules/mytool/mytoolrc" "$HOME/.mytoolrc"
}
```

2. Add any dotfiles alongside it (e.g., `modules/mytool/mytoolrc`)
3. Run `~/.gir/install.sh mytool` to test it

## morning-routine module

Run via the installer:

```bash
~/.gir/install.sh morning-routine
```

This module:

- links `morning-routine` and `evening-routine` into `~/.local/bin`
- creates `~/.morning-routine.json` from a local example if it does not already exist
- keeps machine-specific details in `~/.morning-routine.json` instead of inside the repo
- uses Node.js to read and update the JSON config/state file
- lets `evening-routine` save your current in-progress context for the next morning

Typical flow:

```bash
morning-routine
evening-routine "Finish draft intro and verify deploy plan"
evening-routine --clear
```

Example config:

```json
{
  "chrome_profile": "Profile 1",
  "urls": {
    "current_doc": "https://docs.google.com/document/d/YOUR_DOC_ID",
    "task_manager": "https://app.asana.com/0/home",
    "research_tool": "https://notebooklm.google.com",
    "email": "https://mail.google.com"
  },
  "apps": {
    "notes": "Notes",
    "calendar": "Calendar",
    "slack": "Slack"
  },
  "docker_services": [],
  "delays": {
    "email": 300,
    "slack": 600
  },
  "state": {
    "in_progress": "",
    "updated_at": "",
    "last_morning_run_at": ""
  }
}
```

`docker_services` supports either full commands as strings or compose definitions like:

```json
[
  "docker context use desktop-linux",
  {
    "directory": "~/Development/my-app",
    "services": ["db", "redis"]
  }
]
```

`morning-routine` will:

- show the saved `state.in_progress`
- check whether `~/.gir` is up to date with its upstream branch
- open configured apps and URLs
- optionally run configured Docker startup commands

`evening-routine` updates `state.in_progress` so the next morning starts with the right context

## claude-skills module

The `claude-skills` module syncs skill directories from this repo's `skills/`
directory into `~/.claude/skills` as symlinks.

Run via the installer:

```bash
~/.gir/install.sh claude-skills
```

Run the helper directly after adding or changing repo skills:

```bash
~/.gir/modules/claude-skills/sync-repo-skills-to-claude.sh --dry-run
~/.gir/modules/claude-skills/sync-repo-skills-to-claude.sh --clean-stale
```

Environment overrides:

```bash
REPO_SKILLS_DIR=/custom/repo/skills \
CLAUDE_SKILLS_DIR=/custom/claude/skills \
~/.gir/modules/claude-skills/sync-repo-skills-to-claude.sh
```

## Skills

Skills are Claude Code slash commands stored in `skills/` and synced into `~/.claude/skills` by the `claude-skills` module.

| Skill | Command | What it does |
|-------|---------|--------------|
| `checkpoint` | `/checkpoint` | Save a context checkpoint (task switch, EOD, project switch). Gathers git context, asks 3 questions, writes a structured markdown file with a "Resume here" section and standup block to `~/dev_notes/checkpoints/<project>/`. |
| `checkpoint-load` | `/checkpoint-load` | Load the most recent checkpoint for the current project. Checks `.checkpoints/` locally first, then `~/dev_notes/checkpoints/<project>/`. |
| `checkpoint-standup` | `/checkpoint-standup` | Extract and print just the standup section from the latest checkpoint, ready to paste into MS Teams. |

## codex-skills module

The `codex-skills` module syncs skill directories from `~/.claude/skills` into
`~/.agents/skills` as symlinks.

Run via the installer:

```bash
~/.gir/install.sh codex-skills
```

Run the helper directly for additional options:

```bash
~/.gir/modules/codex-skills/sync-claude-skills-to-codex.sh --dry-run
~/.gir/modules/codex-skills/sync-claude-skills-to-codex.sh --clean-stale
```

Environment overrides:

```bash
CLAUDE_SKILLS_DIR=/custom/claude/skills \
CODEX_SKILLS_DIR=/custom/codex/skills \
~/.gir/modules/codex-skills/sync-claude-skills-to-codex.sh
```

## Repo layout

```
gir/
├── install.sh              # Bootstrap entry point (curl-able)
├── Brewfile                # macOS Homebrew packages
├── lib/
│   ├── log.sh              # Colored log helpers
│   ├── detect.sh           # IS_MACOS, IS_LINUX, IS_WSL, IS_SSH, IS_GUI
│   └── symlink.sh          # rcs_link — safe backup-then-symlink
├── modules/
│   ├── zsh/                # zshrc, p10k.zsh, omz_customizations/
│   ├── vim/                # vimrc, vim/
│   ├── bash/               # bashrc
│   ├── fzf/
│   ├── nvm/
│   ├── neovim/             # config/ (add your init.lua here)
│   ├── claude-skills/      # sync-repo-skills-to-claude.sh
│   ├── codex-skills/
│   ├── morning-routine/
│   ├── homebrew/
│   └── wezterm/            # wezterm.lua
└── skills/
    ├── checkpoint/
    ├── checkpoint-load/
    └── checkpoint-standup/
```
