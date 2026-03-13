#!/bin/bash

MODULE_NAME="zsh"
MODULE_DESCRIPTION="Zsh + Oh My Zsh + Powerlevel10k"
MODULE_PLATFORMS="all"

install_module() {
  # --- Oh My Zsh ---
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    log_skip "Oh My Zsh already installed"
  else
    log_info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    log_ok "Oh My Zsh installed"
  fi

  # --- Powerlevel10k theme (bundled in this repo as a submodule) ---
  local p10k_dir="$RCS_DIR/modules/zsh/omz_customizations/themes/powerlevel10k"
  if [[ ! -d "$p10k_dir" ]]; then
    log_info "Installing Powerlevel10k theme..."
    mkdir -p "$(dirname "$p10k_dir")"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
    log_ok "Powerlevel10k installed"
  else
    log_skip "Powerlevel10k already present"
  fi

  # --- Symlinks ---
  rcs_link "$RCS_DIR/modules/zsh/zshrc"              "$HOME/.zshrc"
  rcs_link "$RCS_DIR/modules/zsh/p10k.zsh"           "$HOME/.p10k.zsh"
  rcs_link "$RCS_DIR/modules/zsh/omz_customizations" "$HOME/.rcs/omz_customizations"
}
