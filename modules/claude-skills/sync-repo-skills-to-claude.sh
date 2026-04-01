#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RCS_DIR="${RCS_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
REPO_SKILLS_DIR="${REPO_SKILLS_DIR:-$RCS_DIR/skills}"
CLAUDE_SKILLS_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

DRY_RUN=0
CLEAN_STALE=0

log() {
  printf '%s\n' "$*"
}

run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '[dry-run] %s\n' "$*"
  else
    eval "$@"
  fi
}

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  --dry-run       Show what would change without modifying anything
  --clean-stale   Remove stale symlinks in Claude skills that point into repo skills
  -h, --help      Show this help

Environment overrides:
  RCS_DIR            Repo root containing skills/ (default: auto-detected)
  REPO_SKILLS_DIR    Source skills directory (default: \$RCS_DIR/skills)
  CLAUDE_SKILLS_DIR  Destination skills directory (default: \$HOME/.claude/skills)
EOF
}

while [[ $# -gt 0 ]]; do
  if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=1
    shift
    continue
  fi

  if [[ "$1" == "--clean-stale" ]]; then
    CLEAN_STALE=1
    shift
    continue
  fi

  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
    exit 0
  fi

  log "Unknown option: $1"
  usage
  exit 1
done

log "Repo skills source:   $REPO_SKILLS_DIR"
log "Claude skills target: $CLAUDE_SKILLS_DIR"
log ""

if [[ ! -d "$REPO_SKILLS_DIR" ]]; then
  log "Error: Repo skills directory does not exist:"
  log "  $REPO_SKILLS_DIR"
  exit 1
fi

run "mkdir -p \"$CLAUDE_SKILLS_DIR\""

created=0
updated=0
skipped=0
removed=0
errors=0

shopt -s nullglob
for skill_dir in "$REPO_SKILLS_DIR"/*; do
  [[ -d "$skill_dir" ]] || continue

  if [[ ! -f "$skill_dir/SKILL.md" ]]; then
    log "Skipping $(basename "$skill_dir"): no SKILL.md"
    ((skipped+=1))
    continue
  fi

  skill_name="$(basename "$skill_dir")"
  target_link="$CLAUDE_SKILLS_DIR/$skill_name"

  if [[ -L "$target_link" ]]; then
    current_target="$(readlink "$target_link" || true)"

    if [[ "$current_target" == "$skill_dir" ]]; then
      log "OK: $skill_name already linked"
      ((skipped+=1))
      continue
    fi

    log "Updating symlink: $skill_name"
    run "rm -f \"$target_link\""
    run "ln -s \"$skill_dir\" \"$target_link\""
    ((updated+=1))
    continue
  fi

  if [[ -e "$target_link" ]]; then
    log "Conflict: $target_link already exists and is not a symlink; leaving it alone"
    ((errors+=1))
    continue
  fi

  log "Linking: $skill_name"
  run "ln -s \"$skill_dir\" \"$target_link\""
  ((created+=1))
done
shopt -u nullglob

if [[ "$CLEAN_STALE" -eq 1 ]]; then
  log ""
  log "Cleaning stale repo-linked symlinks from Claude skills..."

  shopt -s nullglob
  for target in "$CLAUDE_SKILLS_DIR"/*; do
    [[ -L "$target" ]] || continue
    resolved="$(readlink "$target" || true)"

    if [[ "$resolved" == "$REPO_SKILLS_DIR"/* && ! -e "$resolved" ]]; then
      log "Removing stale symlink: $(basename "$target")"
      run "rm -f \"$target\""
      ((removed+=1))
    fi
  done
  shopt -u nullglob
fi

log ""
log "Summary:"
log "  Created: $created"
log "  Updated: $updated"
log "  Skipped: $skipped"
log "  Removed: $removed"
log "  Conflicts/errors: $errors"
log ""

log "Done."
log "Claude discovers user skills from \$HOME/.claude/skills. Rerun this script whenever you add or change skills in the repo."
