---
name: gir-add-module
description: Scaffold a new module for the .gir dotfiles repo. Use when adding a new tool, app, or config to the installer.
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Add a new .gir module

Scaffold a new module for the `~/.gir` dotfiles installer. Follow these steps:

## 1. Gather requirements

Ask the user for the following (all at once, not one at a time):

- **Module name** — lowercase, no spaces (e.g., `tmux`, `starship`, `git`)
- **Description** — one short sentence
- **Platforms** — space-separated tags (use `all` if unsure):
  - `all` — every platform
  - `macos` — macOS only
  - `linux` — Linux only
  - `no_ssh` — skip on SSH servers (use for GUI/interactive tools)
  - `no_wsl` — skip on WSL
  - Tags combine with AND logic (e.g., `macos no_ssh` = macOS and not SSH)
- **Install command** — how to install the tool (brew cask, apt, etc.), or "symlink only" if it's already installed elsewhere
- **Dotfiles** — list of files to symlink, as `<filename in repo> → <target path>` (e.g., `tmux.conf → ~/.tmux.conf`)

## 2. Create the module

Create `modules/<name>/install.sh` using the template below. Adapt the install block to what the user specified — if "symlink only", omit the install section entirely.

```bash
#!/bin/bash

MODULE_NAME="<name>"
MODULE_DESCRIPTION="<description>"
MODULE_PLATFORMS="<platforms>"

install_module() {
  # --- Install <name> ---
  if command -v <binary> &>/dev/null; then
    log_skip "<name> already installed"
  else
    log_info "Installing <name>..."
    if [[ "$IS_MACOS" == true ]]; then
      brew install <name>
    elif command -v apt-get &>/dev/null; then
      sudo apt-get install -y <name>
    elif command -v dnf &>/dev/null; then
      sudo dnf install -y <name>
    else
      log_warn "Unknown package manager — install <name> manually"
    fi
    log_ok "<name> installed"
  fi

  # --- Symlinks ---
  rcs_link "$RCS_DIR/modules/<name>/<dotfile>" "$HOME/.<dotfile>"
}
```

## 3. Create dotfile placeholders

For each dotfile the user listed, create an empty placeholder at `modules/<name>/<filename>` so the symlink step won't fail. Tell the user to fill it in with their actual config.

## 4. Make the script executable

```bash
chmod +x modules/<name>/install.sh
```

## 5. Summarize and remind

Show the user:
- What files were created
- How to test: `~/.gir/install.sh <name>`
- That dotfile placeholders need their actual config filled in before committing
