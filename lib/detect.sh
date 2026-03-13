#!/bin/bash

# Platform and environment detection.
# Source this file, then check the IS_* variables.

IS_MACOS=false
IS_LINUX=false
IS_WSL=false
IS_SSH=false
IS_GUI=false

case "$OSTYPE" in
  darwin*) IS_MACOS=true ;;
  linux*)  IS_LINUX=true ;;
esac

# WSL: either env var is set, or /proc/version mentions Microsoft
if [[ -n "${WSL_DISTRO_NAME:-}" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
  IS_WSL=true
fi

# SSH: any of these env vars being set means we're in an SSH session
if [[ -n "${SSH_TTY:-}" ]] || [[ -n "${SSH_CONNECTION:-}" ]] || [[ -n "${SSH_CLIENT:-}" ]]; then
  IS_SSH=true
fi

# GUI: not SSH, and either macOS or has a display server
if [[ "$IS_SSH" == false ]]; then
  if [[ "$IS_MACOS" == true ]] || [[ -n "${DISPLAY:-}" ]] || [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
    IS_GUI=true
  fi
fi

# Convenience: print detected environment
detect_summary() {
  echo "  IS_MACOS=$IS_MACOS"
  echo "  IS_LINUX=$IS_LINUX"
  echo "  IS_WSL=$IS_WSL"
  echo "  IS_SSH=$IS_SSH"
  echo "  IS_GUI=$IS_GUI"
}
