#!/bin/bash

MODULE_NAME="claude-skills"
MODULE_DESCRIPTION="Symlink repo skills into ~/.claude/skills/"
MODULE_PLATFORMS="all"

install_module() {
  local skills_src="$RCS_DIR/skills"
  local skills_dst="$HOME/.claude/skills"

  if [[ ! -d "$skills_src" ]]; then
    log_skip "No skills/ directory found in repo"
    return 0
  fi

  mkdir -p "$skills_dst"

  for skill_dir in "$skills_src"/*/; do
    local skill_name
    skill_name="$(basename "$skill_dir")"
    rcs_link "$skill_dir" "$skills_dst/$skill_name"
  done
}
