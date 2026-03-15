#!/bin/bash

MODULE_NAME="codex-skills"
MODULE_DESCRIPTION="Sync Claude Code skills into Codex"
MODULE_PLATFORMS="all"

install_module() {
  local sync_script="$RCS_DIR/modules/codex-skills/sync-claude-skills-to-codex.sh"

  if [[ ! -f "$sync_script" ]]; then
    log_error "Sync script not found: $sync_script"
    return 1
  fi

  log_info "Syncing Claude skills into Codex..."
  bash "$sync_script"
  log_ok "Claude skills synced into Codex"
}
