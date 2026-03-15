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
| `homebrew`       | macOS         | Homebrew + Brewfile packages               |
| `wezterm`        | macOS, no SSH | WezTerm terminal + config                  |
| `aerospace`      | macOS, no SSH | AeroSpace tiling window manager            |

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
└── modules/
    ├── zsh/                # zshrc, p10k.zsh, omz_customizations/
    ├── vim/                # vimrc, vim/
    ├── bash/               # bashrc
    ├── fzf/
    ├── nvm/
    ├── neovim/             # config/ (add your init.lua here)
    ├── claude-skills/
    ├── codex-skills/
    ├── homebrew/
    ├── wezterm/            # wezterm.lua
    └── aerospace/          # aerospace.toml (add your config here)
```
