#!/bin/bash

MODULE_NAME="morning-routine"
MODULE_DESCRIPTION="Config-driven morning startup workflow with saved in-progress state"
MODULE_PLATFORMS="all"

install_module() {
  local module_dir="$RCS_DIR/modules/morning-routine"
  local bin_dir="$HOME/.local/bin"
  local config_path="$HOME/.morning-routine.json"
  local helper_path="$module_dir/bin/routine-config-helper.js"
  local shell_rc=""

  mkdir -p "$bin_dir"

  rcs_link "$module_dir/bin/morning-routine" "$bin_dir/morning-routine"
  rcs_link "$module_dir/bin/evening-routine" "$bin_dir/evening-routine"
  log_ok "morning-routine commands linked into $bin_dir"

  if [[ -f "$config_path" ]]; then
    if ! command -v node >/dev/null 2>&1; then
      log_error "node is required to validate existing config at $config_path"
      return 1
    fi

    if ! node "$helper_path" validate "$config_path"; then
      log_error "Existing morning routine config does not match expected schema: $config_path"
      return 1
    fi

    log_ok "Validated existing morning routine config at $config_path"
  else
    cp "$module_dir/morning-routine.config.example.json" "$config_path"
    log_ok "Created local morning routine config at $config_path"
  fi

  if [[ -f "$HOME/.zshrc" ]]; then
    shell_rc="$HOME/.zshrc"
  elif [[ -f "$HOME/.bashrc" ]]; then
    shell_rc="$HOME/.bashrc"
  fi

  if [[ -n "$shell_rc" ]]; then
    if grep -Fq 'export PATH="$HOME/.local/bin:$PATH"' "$shell_rc"; then
      log_skip "~/.local/bin already present in $(basename "$shell_rc")"
    else
      printf '\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$shell_rc"
      log_ok "Added ~/.local/bin to PATH in $(basename "$shell_rc")"
    fi
  else
    log_warn "No shell rc file found to update PATH; add $bin_dir manually if needed"
  fi
}
