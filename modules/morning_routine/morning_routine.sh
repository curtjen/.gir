#!/usr/bin/env bash
# Morning routine runner — executes commands from a JSON config file
# with styled output. Compatible with bash and zsh.

set -o pipefail

# ─── Colors ──────────────────────────────────────────────────────────────────
if [[ -t 1 ]] && [[ "${NO_COLOR:-}" != "1" ]]; then
  BOLD=$'\033[1m'
  DIM=$'\033[2m'
  RESET=$'\033[0m'
  RED=$'\033[38;5;203m'
  GREEN=$'\033[38;5;114m'
  YELLOW=$'\033[38;5;221m'
  BLUE=$'\033[38;5;75m'
  MAGENTA=$'\033[38;5;176m'
  CYAN=$'\033[38;5;80m'
  GRAY=$'\033[38;5;245m'
else
  BOLD="" DIM="" RESET="" RED="" GREEN="" YELLOW="" BLUE="" MAGENTA="" CYAN="" GRAY=""
fi

# ─── Config ──────────────────────────────────────────────────────────────────
ROUTINE_DIR="$HOME/morning_routine"
DEFAULT_CONFIG="$ROUTINE_DIR/routine.json"
CONFIG_FILE="${1:-$DEFAULT_CONFIG}"

usage() {
  cat <<EOF
${BOLD}Usage:${RESET} $0 [config.json] [options]

${BOLD}Options:${RESET}
  -h, --help        Show this help
  -i, --init        Create a starter routine.json at ${DEFAULT_CONFIG}
  -a, --add         Add a new step to an existing routine.json
  -r, --resume      Resume from last successful step
  -f, --from NAME   Start from a specific command name
  -d, --dry-run     Print commands without running them

${BOLD}Config format (JSON):${RESET}
  {
    "commands": [
      { "name": "...", "command": "echo hi",       "dateLastRun": "" },
      { "name": "...", "script":  "./scripts/x.sh", "dateLastRun": "" }
    ],
    "dateLastRun": "",
    "lastStepRun": ""
  }
EOF
}

init_routine() {
  if [[ -f "$DEFAULT_CONFIG" ]]; then
    echo "${YELLOW}⚠  routine.json already exists: ${BOLD}${DEFAULT_CONFIG}${RESET}"
    echo "${DIM}   Delete it first if you want to start over.${RESET}"
    exit 1
  fi
  mkdir -p "$ROUTINE_DIR"
  cat >"$DEFAULT_CONFIG" <<'EOF'
{
  "commands": [
    { "name": "example", "command": "echo 'Good morning!'", "dateLastRun": "" }
  ],
  "dateLastRun": "",
  "lastStepRun": ""
}
EOF
  echo "${GREEN}✓ Created:${RESET} ${BOLD}${DEFAULT_CONFIG}${RESET}"
  echo "${DIM}  Edit it to add your morning commands, then run:${RESET}"
  echo "  ${CYAN}$0${RESET}"
  exit 0
}

RESUME=0
FROM_NAME=""
DRY_RUN=0
ADD_STEP=0

# Skip first arg if it's the config file
shift_count=0
if [[ "${1:-}" != "" && "${1:-}" != -* ]]; then
  shift_count=1
fi
[[ $shift_count -eq 1 ]] && shift

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    -i|--init) init_routine ;;
    -a|--add) ADD_STEP=1; shift ;;
    -r|--resume) RESUME=1; shift ;;
    -f|--from) FROM_NAME="$2"; shift 2 ;;
    -d|--dry-run) DRY_RUN=1; shift ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

# ─── Dependencies ────────────────────────────────────────────────────────────
if ! command -v jq >/dev/null 2>&1; then
  echo "${RED}✗ Error:${RESET} jq is required but not installed." >&2
  echo "  Install with: ${CYAN}brew install jq${RESET}  or  ${CYAN}apt install jq${RESET}" >&2
  exit 1
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
  if [[ ! -t 0 ]]; then
    echo "${RED}✗ Error:${RESET} config file not found: ${BOLD}$CONFIG_FILE${RESET}" >&2
    echo "${DIM}  Create one with:${RESET} ${CYAN}$0 --init${RESET}" >&2
    exit 1
  fi

  echo
  echo "${YELLOW}No routine found.${RESET} ${BOLD}Let's create one.${RESET}"
  echo
  echo "${DIM}  A routine is a list of steps that run in order each morning."
  echo "  Each step has a name (shown in the output) and a shell command to run."
  echo "  Examples: pull latest repos, run a health check, print a reminder.${RESET}"
  echo

  _tmp_entries=$(mktemp)
  _count=0

  while true; do
    if [[ $_count -eq 0 ]]; then
      echo "${BOLD}Add your first step${RESET} ${DIM}(press Enter with no name to skip and create a starter file instead)${RESET}"
    else
      echo "${BOLD}Add another step${RESET} ${DIM}(press Enter with no name to finish)${RESET}"
    fi

    read -rp "  Name: " _cmd_name
    [[ -z "$_cmd_name" ]] && { echo; break; }

    while true; do
      read -rp "  Run a (c) command or (s) script? " _step_type
      case "$_step_type" in
        c|C)
          echo "  ${DIM}A shell command to run, e.g. git pull, brew update, open -a Mail${RESET}"
          read -rp "  Command: " _cmd_command
          jq -n --arg n "$_cmd_name" --arg c "$_cmd_command" \
            '{"name":$n,"command":$c,"dateLastRun":""}' >>"$_tmp_entries"
          break ;;
        s|S)
          echo "  ${DIM}Path to a shell script file to run, e.g. ~/scripts/check.sh"
          echo "  The script must be executable — if it isn't, run: chmod +x SCRIPT_PATH${RESET}"
          read -rp "  Script path: " _cmd_script
          jq -n --arg n "$_cmd_name" --arg s "$_cmd_script" \
            '{"name":$n,"script":$s,"dateLastRun":""}' >>"$_tmp_entries"
          break ;;
        *) echo "  ${YELLOW}Please enter 'c' for command or 's' for script.${RESET}" ;;
      esac
    done

    _count=$((_count + 1))
    echo "  ${GREEN}✓ Added '${_cmd_name}'${RESET}"
    echo
  done

  mkdir -p "$(dirname "$CONFIG_FILE")"

  if [[ $_count -eq 0 ]]; then
    cat >"$CONFIG_FILE" <<'EOF'
{
  "commands": [
    { "name": "example", "command": "echo 'Good morning!'", "dateLastRun": "" }
  ],
  "dateLastRun": "",
  "lastStepRun": ""
}
EOF
    echo "${GREEN}✓ Created starter routine:${RESET} ${BOLD}${CONFIG_FILE}${RESET}"
    echo "${DIM}  Edit it to add your steps, then run:${RESET} ${CYAN}$0${RESET}"
  else
    jq -s '{"commands": ., "dateLastRun": "", "lastStepRun": ""}' \
      "$_tmp_entries" >"$CONFIG_FILE"
    echo "${GREEN}✓ Created:${RESET} ${BOLD}${CONFIG_FILE}${RESET} ${DIM}(${_count} step(s))${RESET}"
    echo "${DIM}  Run your routine with:${RESET} ${CYAN}$0${RESET}"
  fi

  rm "$_tmp_entries"
  exit 0
fi

if ! jq empty "$CONFIG_FILE" 2>/dev/null; then
  echo "${RED}✗ Error:${RESET} config file is not valid JSON: ${BOLD}$CONFIG_FILE${RESET}" >&2
  exit 1
fi

# ─── Add step ────────────────────────────────────────────────────────────────
if [[ $ADD_STEP -eq 1 ]]; then
  _existing=$(jq -r '.commands | length' "$CONFIG_FILE")

  echo
  echo "${BOLD}Add a step to routine${RESET} ${DIM}(${CONFIG_FILE})${RESET}"
  echo

  if [[ $_existing -gt 0 ]]; then
    echo "${DIM}  Existing steps:${RESET}"
    jq -r '.commands[] | "    • \(.name)"' "$CONFIG_FILE"
    echo
  fi

  read -rp "  Name: " _add_name
  if [[ -z "$_add_name" ]]; then
    echo "${YELLOW}⚠  No name given — nothing added.${RESET}"
    exit 0
  fi

  while true; do
    read -rp "  Run a (c) command or (s) script? " _add_type
    case "$_add_type" in
      c|C)
        echo "  ${DIM}A shell command to run, e.g. git pull, brew update, open -a Mail${RESET}"
        read -rp "  Command: " _add_command
        _new_entry=$(jq -n --arg n "$_add_name" --arg c "$_add_command" \
          '{"name":$n,"command":$c,"dateLastRun":""}')
        break ;;
      s|S)
        echo "  ${DIM}Path to a shell script file to run, e.g. ~/scripts/check.sh"
        echo "  The script must be executable — if it isn't, run: chmod +x SCRIPT_PATH${RESET}"
        read -rp "  Script path: " _add_script
        _new_entry=$(jq -n --arg n "$_add_name" --arg s "$_add_script" \
          '{"name":$n,"script":$s,"dateLastRun":""}')
        break ;;
      *) echo "  ${YELLOW}Please enter 'c' for command or 's' for script.${RESET}" ;;
    esac
  done

  _tmp=$(mktemp)
  jq --argjson entry "$_new_entry" '.commands += [$entry]' "$CONFIG_FILE" >"$_tmp" \
    && mv "$_tmp" "$CONFIG_FILE"

  echo "  ${GREEN}✓ Added '${_add_name}'${RESET}"
  exit 0
fi

# ─── Helpers ─────────────────────────────────────────────────────────────────
now_iso() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }

# Pretty box header for a command
print_header() {
  local idx="$1" total="$2" name="$3"
  local title=" [${idx}/${total}] ${name} "
  local pad
  pad=$(printf '─%.0s' $(seq 1 $((${#title} + 2))))
  echo
  echo "${BLUE}╭${pad}╮${RESET}"
  echo "${BLUE}│${RESET} ${BOLD}${MAGENTA}${title}${RESET} ${BLUE}│${RESET}"
  echo "${BLUE}╰${pad}╯${RESET}"
}

# Indent and color command output
stream_output() {
  local prefix="${GRAY}│${RESET} "
  while IFS= read -r line || [[ -n "$line" ]]; do
    printf '%s%s\n' "$prefix" "$line"
  done
}

print_footer_ok() {
  local elapsed="$1"
  echo "${GREEN}╰─ ✓ done${RESET} ${DIM}(${elapsed}s)${RESET}"
}

print_footer_fail() {
  local elapsed="$1" code="$2"
  echo "${RED}╰─ ✗ failed${RESET} ${DIM}(exit ${code}, ${elapsed}s)${RESET}"
}

# Update a single command's dateLastRun in the config (by index)
update_command_date() {
  local idx="$1" date="$2"
  local tmp
  tmp=$(mktemp)
  jq --argjson i "$idx" --arg d "$date" \
    '.commands[$i].dateLastRun = $d' "$CONFIG_FILE" >"$tmp" && mv "$tmp" "$CONFIG_FILE"
}

# Update top-level lastStepRun and dateLastRun
update_top_level() {
  local last_step="$1" date="$2"
  local tmp
  tmp=$(mktemp)
  jq --arg s "$last_step" --arg d "$date" \
    '.lastStepRun = $s | .dateLastRun = $d' "$CONFIG_FILE" >"$tmp" && mv "$tmp" "$CONFIG_FILE"
}

# ─── Banner ──────────────────────────────────────────────────────────────────
TOTAL=$(jq '.commands | length' "$CONFIG_FILE")
LAST_RUN=$(jq -r '.dateLastRun // "never"' "$CONFIG_FILE")
LAST_STEP=$(jq -r '.lastStepRun // ""' "$CONFIG_FILE")

echo
echo "${BOLD}${CYAN}☀  Morning Routine${RESET}"
echo "${DIM}   config:    ${CONFIG_FILE}${RESET}"
echo "${DIM}   commands:  ${TOTAL}${RESET}"
echo "${DIM}   last run:  ${LAST_RUN}${RESET}"
[[ -n "$LAST_STEP" ]] && echo "${DIM}   last step: ${LAST_STEP}${RESET}"
[[ $DRY_RUN -eq 1 ]] && echo "${YELLOW}   ⚠ dry-run mode${RESET}"

# ─── Determine starting index ────────────────────────────────────────────────
START_IDX=0
if [[ $RESUME -eq 1 && -n "$LAST_STEP" ]]; then
  found=$(jq -r --arg n "$LAST_STEP" '[.commands[].name] | index($n) // -1' "$CONFIG_FILE")
  if [[ "$found" != "-1" && "$found" != "null" ]]; then
    START_IDX=$((found + 1))
    echo "${YELLOW}   ↻ resuming after '${LAST_STEP}' (step $((START_IDX + 1)))${RESET}"
  fi
elif [[ -n "$FROM_NAME" ]]; then
  found=$(jq -r --arg n "$FROM_NAME" '[.commands[].name] | index($n) // -1' "$CONFIG_FILE")
  if [[ "$found" == "-1" || "$found" == "null" ]]; then
    echo "${RED}✗ Error:${RESET} no command named '${FROM_NAME}'" >&2
    exit 1
  fi
  START_IDX=$found
  echo "${YELLOW}   → starting from '${FROM_NAME}'${RESET}"
fi

# ─── Run loop ────────────────────────────────────────────────────────────────
RUN_START=$(date +%s)
FAILED=0
COMPLETED=0

for ((i = START_IDX; i < TOTAL; i++)); do
  name=$(jq -r ".commands[$i].name" "$CONFIG_FILE")
  command=$(jq -r ".commands[$i].command // empty" "$CONFIG_FILE")
  script=$(jq -r ".commands[$i].script // empty" "$CONFIG_FILE")

  print_header "$((i + 1))" "$TOTAL" "$name"

  # Pick command or script
  if [[ -n "$command" && -n "$script" ]]; then
    echo "${YELLOW}⚠  both 'command' and 'script' set — using 'command'${RESET}"
    to_run="$command"
    label="$command"
  elif [[ -n "$command" ]]; then
    to_run="$command"
    label="$command"
  elif [[ -n "$script" ]]; then
    if [[ ! -f "$script" ]]; then
      echo "${RED}✗ script not found: ${script}${RESET}"
      FAILED=1
      break
    fi
    to_run="bash $script"
    label="$script"
  else
    echo "${YELLOW}⚠  no command or script — skipping${RESET}"
    continue
  fi

  echo "${GRAY}╭─ \$ ${label}${RESET}"

  step_start=$(date +%s)

  if [[ $DRY_RUN -eq 1 ]]; then
    echo "${GRAY}│${RESET} ${DIM}(dry-run, not executed)${RESET}"
    exit_code=0
  else
    # Run while streaming output through our prefix formatter.
    # Merges stdout + stderr so users see the full picture inline.
    set +e
    eval "$to_run" 2>&1 | stream_output
    exit_code=${PIPESTATUS[0]}
    set -e
  fi

  step_end=$(date +%s)
  elapsed=$((step_end - step_start))

  if [[ $exit_code -eq 0 ]]; then
    print_footer_ok "$elapsed"
    [[ $DRY_RUN -eq 0 ]] && {
      update_command_date "$i" "$(now_iso)"
      update_top_level "$name" "$(now_iso)"
    }
    COMPLETED=$((COMPLETED + 1))
  else
    print_footer_fail "$elapsed" "$exit_code"
    FAILED=1
    break
  fi
done

# ─── Summary ─────────────────────────────────────────────────────────────────
RUN_END=$(date +%s)
TOTAL_ELAPSED=$((RUN_END - RUN_START))

echo
if [[ $FAILED -eq 0 ]]; then
  echo "${GREEN}${BOLD}✓ Morning routine complete${RESET} ${DIM}— ${COMPLETED} step(s) in ${TOTAL_ELAPSED}s${RESET}"
  exit 0
else
  remaining=$((TOTAL - START_IDX - COMPLETED))
  echo "${RED}${BOLD}✗ Morning routine stopped${RESET} ${DIM}— ${COMPLETED} done, ${remaining} remaining${RESET}"
  echo "${DIM}  resume with:${RESET} ${CYAN}$0 $CONFIG_FILE --resume${RESET}"
  exit 1
fi
