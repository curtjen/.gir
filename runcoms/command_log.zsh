#!/usr/bin/env zsh
#
# command_log.sh
#
# Logs every executed command to a Markdown table file using a Zsh preexec hook.
# Commands are wrapped in Markdown code ticks so no escaping helper is needed.
# Intended to be sourced from .zshrc.
#

# Prevent double-loading
[[ -n "${COMMAND_LOG_LOADED:-}" ]] && return
export COMMAND_LOG_LOADED=1

# -------------------------------------------------------------------
# Configuration
# -------------------------------------------------------------------

# Output file (Markdown)
: "${COMMAND_LOG_FILE:=$HOME/.command_log.md}"

# Timestamp format (date(1) compatible)
: "${COMMAND_LOG_TIMESTAMP_FORMAT:=%Y-%m-%d %H:%M:%S}"

# Enable/disable logging (set to 0 to disable)
: "${COMMAND_LOG_ENABLED:=1}"

# How many backticks to wrap the command with.
# Using triple backticks avoids issues if a command contains a single backtick.
: "${COMMAND_LOG_CODE_FENCE:="\`\`\`"}"

# -------------------------------------------------------------------
# Setup
# -------------------------------------------------------------------

command_log_init_file() {
  if [[ ! -f "$COMMAND_LOG_FILE" ]]; then
    umask 077
    touch "$COMMAND_LOG_FILE"
  fi

  # If empty, write table header
  if [[ ! -s "$COMMAND_LOG_FILE" ]]; then
    {
      print '| Timestamp | Command |'
      print '| --------- | ------- |'
    } >> "$COMMAND_LOG_FILE"
  fi
}

command_log_init_file

# -------------------------------------------------------------------
# Hooks
# -------------------------------------------------------------------

command_log_preexec() {
  [[ "$COMMAND_LOG_ENABLED" -ne 1 ]] && return

  local ts cmd fence
  ts="$(date +"$COMMAND_LOG_TIMESTAMP_FORMAT")"
  cmd="$1"
  fence="$COMMAND_LOG_CODE_FENCE"

  # Note: If a command contains a newline, it will render poorly in a Markdown table.
  # Most interactive commands are single-line; if you routinely run multi-line commands,
  # consider normalizing newlines to '\n' (at the cost of reintroducing some escaping).
  printf '| %s | %s%s%s |\n' "$ts" "$fence" "$cmd" "$fence" >> "$COMMAND_LOG_FILE"
}

# -------------------------------------------------------------------
# Hook registration (Zsh-native)
# -------------------------------------------------------------------

autoload -Uz add-zsh-hook
add-zsh-hook preexec command_log_preexec

echo "COMMAND LOG INITIATED"
