#!/bin/bash

# rcs_link <source> <target>
#
# Safely creates a symlink from <target> → <source>.
# If <target> already exists:
#   - If it's already a correct symlink, skip.
#   - Otherwise, back it up to $RCS_BACKUP_DIR before linking.
#
# Requires log.sh to be sourced first.

RCS_BACKUP_DIR="${RCS_BACKUP_DIR:-$HOME/_gir_backup}"

rcs_link() {
  local src="$1"
  local target="$2"

  if [[ ! -e "$src" ]]; then
    log_error "Source does not exist: $src"
    return 1
  fi

  # Already a correct symlink — nothing to do
  if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$src" ]]; then
    log_skip "Already linked: $target"
    return 0
  fi

  # Existing file, dir, or wrong symlink — back it up
  if [[ -e "$target" ]] || [[ -L "$target" ]]; then
    local ts
    ts="$(date +%Y%m%d_%H%M%S)"
    local backup_dir="$RCS_BACKUP_DIR/$ts"
    mkdir -p "$backup_dir"
    mv "$target" "$backup_dir/$(basename "$target")"
    log_warn "Backed up: $target → $backup_dir/$(basename "$target")"
  fi

  # Ensure parent directory exists
  mkdir -p "$(dirname "$target")"

  ln -s "$src" "$target"
  log_ok "Linked: $target → $src"
}
