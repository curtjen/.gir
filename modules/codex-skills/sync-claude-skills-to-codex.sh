#!/usr/bin/env bash
set -euo pipefail

# Sync Claude Code skills into Codex as symlinks.

CLAUDE_SKILLS_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
CODEX_SKILLS_DIR="${CODEX_SKILLS_DIR:-$HOME/.agents/skills}"

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
  --clean-stale   Remove stale symlinks in Codex skills that point into Claude skills
  -h, --help      Show this help

Environment overrides:
  CLAUDE_SKILLS_DIR   Source skills directory (default: $HOME/.claude/skills)
  CODEX_SKILLS_DIR    Destination skills directory (default: $HOME/.agents/skills)
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --clean-stale)
      CLEAN_STALE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      log "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

log "Claude skills source: $CLAUDE_SKILLS_DIR"
log "Codex skills target:  $CODEX_SKILLS_DIR"
log ""

if [[ ! -d "$CLAUDE_SKILLS_DIR" ]]; then
  log "Error: Claude skills directory does not exist:"
  log "  $CLAUDE_SKILLS_DIR"
  exit 1
fi

run "mkdir -p \"$CODEX_SKILLS_DIR\""

created=0
updated=0
skipped=0
removed=0
errors=0

# Only link directories that contain SKILL.md.
shopt -s nullglob
for skill_dir in "$CLAUDE_SKILLS_DIR"/*; do
  [[ -d "$skill_dir" ]] || continue
  if [[ ! -f "$skill_dir/SKILL.md" ]]; then
    log "Skipping $(basename "$skill_dir"): no SKILL.md"
    ((skipped+=1))
    continue
  fi

  skill_name="$(basename "$skill_dir")"
  target_link="$CODEX_SKILLS_DIR/$skill_name"

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
  log "Cleaning stale Claude-linked symlinks from Codex..."
  shopt -s nullglob
  for target in "$CODEX_SKILLS_DIR"/*; do
    [[ -L "$target" ]] || continue
    resolved="$(readlink "$target" || true)"

    case "$resolved" in
      "$CLAUDE_SKILLS_DIR"/*)
        if [[ ! -e "$resolved" ]]; then
          log "Removing stale symlink: $(basename "$target")"
          run "rm -f \"$target\""
          ((removed+=1))
        fi
        ;;
    esac
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
log "Codex discovers user skills from \$HOME/.agents/skills and supports symlinked skill folders there. Use /skills in Codex to verify discovery."
