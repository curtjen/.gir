#!/bin/bash

MODULE_NAME="morning_routine"
MODULE_DESCRIPTION="Morning Routine CLI — npm link the morning_routine package"
MODULE_PLATFORMS="all"

install_module() {
  local pkg_dir="$RCS_DIR/modules/morning_routine/npm_package"

  if [[ ! -d "$pkg_dir" ]]; then
    log_error "npm package directory not found: $pkg_dir"
    return 1
  fi

  log_info "Linking morning_routine npm package..."
  pushd "$pkg_dir" > /dev/null
  npm link
  popd > /dev/null
  log_ok "morning_routine linked globally"
}
