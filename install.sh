#!/bin/bash
set -euo pipefail

# =============================================================================
# rcs — dotfiles & tool installer
#
# Usage:
#   # Via curl (bootstraps from scratch):
#   curl -fsSL https://raw.githubusercontent.com/curtjen/.gir/v2/install.sh | bash
#
#   # Via npx (no git history):
#   npx degit curtjen/.gir#v2 ~/.rcs && ~/.rcs/install.sh
#
#   # After cloning manually:
#   git clone -b v2 git@github.com:curtjen/.gir.git ~/.rcs && ~/.rcs/install.sh
#
#   # Install specific modules only:
#   ~/.rcs/install.sh zsh vim nvm
#
# =============================================================================

# --- Config ------------------------------------------------------------------
RCS_REPO="${RCS_REPO:-git@github.com:curtjen/.gir.git}"
RCS_DIR="${RCS_DIR:-$HOME/.rcs}"

# --- Bootstrap (curl-pipe detection) ----------------------------------------
# When piped through bash (curl ... | bash), BASH_SOURCE[0] is not a file.
# In that case, clone the repo and re-exec the real install.sh.
if [[ ! -f "${BASH_SOURCE[0]:-}" ]]; then
  echo "[rcs] Running via curl — cloning repo to $RCS_DIR..."
  if [[ -d "$RCS_DIR" ]]; then
    echo "[rcs] $RCS_DIR already exists. Pulling latest..."
    git -C "$RCS_DIR" pull --ff-only
  else
    git clone "$RCS_REPO" "$RCS_DIR"
  fi
  exec bash "$RCS_DIR/install.sh" "$@"
fi

# --- Running from a real file ------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RCS_DIR="$SCRIPT_DIR"

source "$RCS_DIR/lib/log.sh"
source "$RCS_DIR/lib/detect.sh"
source "$RCS_DIR/lib/symlink.sh"

# --- Platform summary --------------------------------------------------------
log_header "rcs installer"
log_info "Installing to: $RCS_DIR"
detect_summary

# --- Module runner -----------------------------------------------------------
# Each module lives in modules/<name>/install.sh and must define:
#   MODULE_NAME        — short identifier
#   MODULE_DESCRIPTION — human-readable description
#   MODULE_PLATFORMS   — space-separated tags: all | macos | linux | no_ssh | no_wsl
#   install_module()   — function that does the actual work
#
run_module() {
  local module_file="$1"
  local module_dir
  module_dir="$(dirname "$module_file")"

  # Reset module vars before sourcing
  MODULE_NAME=""
  MODULE_DESCRIPTION=""
  MODULE_PLATFORMS="all"

  # shellcheck source=/dev/null
  source "$module_file"

  # Platform gate
  local skip=false
  for tag in $MODULE_PLATFORMS; do
    case "$tag" in
      macos)    [[ "$IS_MACOS" == true ]] || skip=true ;;
      linux)    [[ "$IS_LINUX" == true ]] || skip=true ;;
      no_ssh)   [[ "$IS_SSH"   == false ]] || skip=true ;;
      no_wsl)   [[ "$IS_WSL"   == false ]] || skip=true ;;
      all)      ;;
    esac
  done

  if [[ "$skip" == true ]]; then
    log_skip "Module '$MODULE_NAME' — not applicable on this platform"
    return 0
  fi

  log_header "Module: $MODULE_NAME — $MODULE_DESCRIPTION"
  install_module
}

# --- Determine which modules to run -----------------------------------------
REQUESTED=("$@")

module_files=()
while IFS= read -r -d '' f; do
  module_files+=("$f")
done < <(find "$RCS_DIR/modules" -name "install.sh" -maxdepth 2 -print0 | sort -z)

if [[ ${#module_files[@]} -eq 0 ]]; then
  log_warn "No modules found in $RCS_DIR/modules/"
  exit 0
fi

for module_file in "${module_files[@]}"; do
  module_name="$(basename "$(dirname "$module_file")")"

  # If specific modules were requested, skip non-matching ones
  if [[ ${#REQUESTED[@]} -gt 0 ]]; then
    match=false
    for req in "${REQUESTED[@]}"; do
      [[ "$req" == "$module_name" ]] && match=true && break
    done
    [[ "$match" == true ]] || continue
  fi

  run_module "$module_file"
done

log_header "Done!"
echo ""
