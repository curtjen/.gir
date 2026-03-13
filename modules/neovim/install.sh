#!/bin/bash

MODULE_NAME="neovim"
MODULE_DESCRIPTION="Neovim + config"
MODULE_PLATFORMS="all"

_pkg_install() {
  local pkg="$1"
  if [[ "$IS_MACOS" == true ]]; then
    brew install "$pkg"
  elif command -v apt-get &>/dev/null; then
    sudo apt-get install -y "$pkg"
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y "$pkg"
  else
    log_warn "Unknown package manager — install $pkg manually"
    return 1
  fi
}

install_module() {
  # --- Install neovim ---
  if command -v nvim &>/dev/null; then
    log_skip "neovim already installed ($(nvim --version | head -1))"
  else
    log_info "Installing neovim..."
    if _pkg_install neovim; then
      log_ok "neovim installed"
    else
      log_warn "Skipping neovim install — continue with remaining steps"
    fi
  fi

  # --- Install ripgrep (used by neovim plugins) ---
  if command -v rg &>/dev/null; then
    log_skip "ripgrep already installed"
  else
    log_info "Installing ripgrep..."
    if _pkg_install ripgrep; then
      log_ok "ripgrep installed"
    else
      log_warn "Skipping ripgrep install"
    fi
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
