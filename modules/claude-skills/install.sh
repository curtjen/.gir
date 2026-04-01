#!/bin/bash

MODULE_NAME="claude-skills"
MODULE_DESCRIPTION="Symlink repo skills into ~/.claude/skills/"
MODULE_PLATFORMS="all"

install_module() {
  local sync_script="$RCS_DIR/modules/claude-skills/sync-repo-skills-to-claude.sh"

  if [[ ! -f "$sync_script" ]]; then
    log_error "Sync script not found: $sync_script"
    return 1
  fi

  log_info "Syncing repo skills into Claude..."
  bash "$sync_script"
  log_ok "Repo skills synced into Claude"
}
