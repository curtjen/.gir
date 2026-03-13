#!/bin/bash

MODULE_NAME="bash"
MODULE_DESCRIPTION="Bash config"
MODULE_PLATFORMS="all"

install_module() {
  rcs_link "$RCS_DIR/modules/bash/bashrc" "$HOME/.bashrc"
}
