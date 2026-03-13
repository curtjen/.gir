#!/bin/bash

MODULE_NAME="nvm"
MODULE_DESCRIPTION="Node Version Manager"
MODULE_PLATFORMS="all"

install_module() {
  local nvm_dir="${NVM_DIR:-$HOME/.nvm}"

  if [[ -d "$nvm_dir" ]]; then
    log_skip "nvm already installed at $nvm_dir"
    return 0
  fi

  log_info "Installing nvm..."
  git clone https://github.com/nvm-sh/nvm.git "$nvm_dir"
  pushd "$nvm_dir" > /dev/null
  git fetch --tags origin
  local latest_tag
  latest_tag="$(git describe --abbrev=0 --tags --match "v[0-9]*" "$(git rev-list --tags --max-count=1)")"
  git checkout "$latest_tag"
  popd > /dev/null
  log_ok "nvm $latest_tag installed"

  log_info "Loading nvm and installing LTS node..."
  # shellcheck source=/dev/null
  source "$nvm_dir/nvm.sh"
  nvm install --lts
  log_ok "Node LTS installed"
}
