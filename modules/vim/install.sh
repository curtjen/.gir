#!/bin/bash

MODULE_NAME="vim"
MODULE_DESCRIPTION="Vim + Vundle plugin manager"
MODULE_PLATFORMS="all"

install_module() {
  local vim_dir="$RCS_DIR/modules/vim/vim"

  # Create vim working directories (gitignored, needed by vimrc)
  for d in .backup .swp .undo; do
    mkdir -p "$vim_dir/$d"
    log_ok "Created $vim_dir/$d"
  done

  # --- Vundle ---
  local vundle_dir="$vim_dir/bundle/Vundle.vim"
  if [[ -d "$vundle_dir" ]]; then
    log_skip "Vundle already installed"
  else
    log_info "Installing Vundle..."
    git clone https://github.com/gmarik/Vundle.vim.git "$vundle_dir"
    log_ok "Vundle installed"
  fi

  # --- Symlinks ---
  rcs_link "$RCS_DIR/modules/vim/vimrc" "$HOME/.vimrc"
  rcs_link "$vim_dir"                   "$HOME/.vim"

  # --- Install Vim plugins ---
  if command -v vim &>/dev/null; then
    log_info "Installing Vim plugins via Vundle..."
    vim +PluginInstall +qall
    log_ok "Vim plugins installed"
  else
    log_warn "vim not found — skipping plugin install"
  fi
}
