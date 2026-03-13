#!/bin/bash

MODULE_NAME="neovim"
MODULE_DESCRIPTION="Neovim + config"
MODULE_PLATFORMS="all"

install_module() {
  # --- Install neovim ---
  if command -v nvim &>/dev/null; then
    log_skip "neovim already installed ($(nvim --version | head -1))"
  else
    log_info "Installing neovim..."
    if [[ "$IS_MACOS" == true ]]; then
      brew install neovim
    elif command -v apt-get &>/dev/null; then
      sudo apt-get install -y neovim
    elif command -v dnf &>/dev/null; then
      sudo dnf install -y neovim
    else
      log_warn "Unknown package manager — install neovim manually"
      return 1
    fi
    log_ok "neovim installed"
  fi

  # --- Install ripgrep (used by neovim plugins) ---
  if command -v rg &>/dev/null; then
    log_skip "ripgrep already installed"
  else
    log_info "Installing ripgrep..."
    if [[ "$IS_MACOS" == true ]]; then
      brew install ripgrep
    elif command -v apt-get &>/dev/null; then
      sudo apt-get install -y ripgrep
    elif command -v dnf &>/dev/null; then
      sudo dnf install -y ripgrep
    else
      log_warn "Unknown package manager — install ripgrep manually"
    fi
    log_ok "ripgrep installed"
  fi

  # --- Symlink config ---
  local config_dir="$RCS_DIR/modules/neovim/config"
  if [[ -d "$config_dir" ]]; then
    rcs_link "$config_dir" "$HOME/.config/nvim"
  else
    log_skip "No neovim config dir found at $config_dir — skipping symlink"
    log_info "Add your neovim config to modules/neovim/config/ to enable."
  fi
}
