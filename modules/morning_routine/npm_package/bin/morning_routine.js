#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');
const os = require('os');
const { spawn } = require('child_process');
const readline = require('readline');

// ─── Colors ──────────────────────────────────────────────────────────────────
const useColor = process.stdout.isTTY && process.env.NO_COLOR !== '1';
const KEYS = ['BOLD', 'DIM', 'RESET', 'RED', 'GREEN', 'YELLOW', 'BLUE', 'MAGENTA', 'CYAN', 'GRAY'];
const c = useColor ? {
  BOLD:    '\x1b[1m',
  DIM:     '\x1b[2m',
  RESET:   '\x1b[0m',
  RED:     '\x1b[38;5;203m',
  GREEN:   '\x1b[38;5;114m',
  YELLOW:  '\x1b[38;5;221m',
  BLUE:    '\x1b[38;5;75m',
  MAGENTA: '\x1b[38;5;176m',
  CYAN:    '\x1b[38;5;80m',
  GRAY:    '\x1b[38;5;245m',
} : Object.fromEntries(KEYS.map(k => [k, '']));

// ─── Config paths ─────────────────────────────────────────────────────────────
const ROUTINE_DIR    = path.join(os.homedir(), 'morning_routine');
const DEFAULT_CONFIG = path.join(ROUTINE_DIR, 'routine.json');

// ─── Arg parsing ──────────────────────────────────────────────────────────────
const args = process.argv.slice(2);
let configFile = DEFAULT_CONFIG;
let doInit   = false;
let addStep  = false;
let resume   = false;
let fromName = '';
let dryRun   = false;

let i = 0;
if (args[0] && !args[0].startsWith('-')) {
  configFile = args[i++];
}
for (; i < args.length; i++) {
  switch (args[i]) {
    case '-h': case '--help':     usage(); process.exit(0); break;
    case '-i': case '--init':     doInit  = true; break;
    case '-a': case '--add':      addStep = true; break;
    case '-r': case '--resume':   resume  = true; break;
    case '-f': case '--from':     fromName = args[++i]; break;
    case '-d': case '--dry-run':  dryRun  = true; break;
    default:
      console.error(`Unknown option: ${args[i]}`);
      usage();
      process.exit(1);
  }
}

function usage() {
  console.log(`${c.BOLD}Usage:${c.RESET} morning_routine [config.json] [options]

${c.BOLD}Options:${c.RESET}
  -h, --help        Show this help
  -i, --init        Create a starter routine.json at ${DEFAULT_CONFIG}
  -a, --add         Add a new step to an existing routine.json
  -r, --resume      Resume from last successful step
  -f, --from NAME   Start from a specific command name
  -d, --dry-run     Print commands without running them

${c.BOLD}Config format (JSON):${c.RESET}
  {
    "commands": [
      { "name": "...", "command": "echo hi",        "dateLastRun": "" },
      { "name": "...", "script":  "./scripts/x.sh", "dateLastRun": "" }
    ],
    "dateLastRun": "",
    "lastStepRun": ""
  }`);
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
const nowIso = () => new Date().toISOString().replace(/\.\d{3}Z$/, 'Z');

function readConfig(file) {
  try {
    return JSON.parse(fs.readFileSync(file, 'utf8'));
  } catch {
    console.error(`${c.RED}✗ Error:${c.RESET} config file is not valid JSON: ${c.BOLD}${file}${c.RESET}`);
    process.exit(1);
  }
}

function writeConfig(file, data) {
  fs.writeFileSync(file, JSON.stringify(data, null, 2) + '\n', 'utf8');
}

function printHeader(idx, total, name) {
  const title = ` [${idx}/${total}] ${name} `;
  const pad = '─'.repeat(title.length + 2);
  console.log();
  console.log(`${c.BLUE}╭${pad}╮${c.RESET}`);
  console.log(`${c.BLUE}│${c.RESET} ${c.BOLD}${c.MAGENTA}${title}${c.RESET} ${c.BLUE}│${c.RESET}`);
  console.log(`${c.BLUE}╰${pad}╯${c.RESET}`);
}

function streamLine(line) {
  process.stdout.write(`${c.GRAY}│${c.RESET} ${line}\n`);
}

// ─── Prompt helpers ───────────────────────────────────────────────────────────
function makeRL() {
  return readline.createInterface({ input: process.stdin, output: process.stdout });
}

function ask(rl, question) {
  return new Promise(resolve => rl.question(question, resolve));
}

async function askStepType(rl) {
  while (true) {
    const type = (await ask(rl, '  Run a (c) command or (s) script? ')).trim().toLowerCase();
    if (type === 'c') {
      console.log(`  ${c.DIM}A shell command to run, e.g. git pull, brew update, open -a Mail${c.RESET}`);
      const command = (await ask(rl, '  Command: ')).trim();
      return { command };
    } else if (type === 's') {
      console.log(`  ${c.DIM}Path to a shell script file to run, e.g. ~/scripts/check.sh`);
      console.log(`  The script must be executable — if it isn't, run: chmod +x SCRIPT_PATH${c.RESET}`);
      const script = (await ask(rl, '  Script path: ')).trim();
      return { script };
    } else {
      console.log(`  ${c.YELLOW}Please enter 'c' for command or 's' for script.${c.RESET}`);
    }
  }
}

// ─── Init ─────────────────────────────────────────────────────────────────────
function initRoutine() {
  if (fs.existsSync(DEFAULT_CONFIG)) {
    console.log(`${c.YELLOW}⚠  routine.json already exists: ${c.BOLD}${DEFAULT_CONFIG}${c.RESET}`);
    console.log(`${c.DIM}   Delete it first if you want to start over.${c.RESET}`);
    process.exit(1);
  }
  fs.mkdirSync(ROUTINE_DIR, { recursive: true });
  writeConfig(DEFAULT_CONFIG, {
    commands: [{ name: 'example', command: "echo 'Good morning!'", dateLastRun: '' }],
    dateLastRun: '',
    lastStepRun: '',
  });
  console.log(`${c.GREEN}✓ Created:${c.RESET} ${c.BOLD}${DEFAULT_CONFIG}${c.RESET}`);
  console.log(`${c.DIM}  Edit it to add your morning commands, then run:${c.RESET}`);
  console.log(`  ${c.CYAN}morning_routine${c.RESET}`);
  process.exit(0);
}

// ─── Interactive create ────────────────────────────────────────────────────────
async function interactiveCreate() {
  const rl = makeRL();
  console.log();
  console.log(`${c.YELLOW}No routine found.${c.RESET} ${c.BOLD}Let's create one.${c.RESET}`);
  console.log();
  console.log(`${c.DIM}  A routine is a list of steps that run in order each morning.`);
  console.log(`  Each step has a name (shown in the output) and a shell command to run.`);
  console.log(`  Examples: pull latest repos, run a health check, print a reminder.${c.RESET}`);
  console.log();

  const entries = [];
  let isFirst = true;
  while (true) {
    const hint = isFirst
      ? `${c.BOLD}Add your first step${c.RESET} ${c.DIM}(press Enter with no name to skip and create a starter file instead)${c.RESET}\n  Name: `
      : `${c.BOLD}Add another step${c.RESET} ${c.DIM}(press Enter with no name to finish)${c.RESET}\n  Name: `;
    const name = (await ask(rl, hint)).trim();
    if (!name) { console.log(); break; }

    const rest = await askStepType(rl);
    entries.push({ name, ...rest, dateLastRun: '' });
    isFirst = false;
    console.log(`  ${c.GREEN}✓ Added '${name}'${c.RESET}`);
    console.log();
  }

  rl.close();
  fs.mkdirSync(path.dirname(configFile), { recursive: true });

  if (entries.length === 0) {
    writeConfig(configFile, {
      commands: [{ name: 'example', command: "echo 'Good morning!'", dateLastRun: '' }],
      dateLastRun: '',
      lastStepRun: '',
    });
    console.log(`${c.GREEN}✓ Created starter routine:${c.RESET} ${c.BOLD}${configFile}${c.RESET}`);
    console.log(`${c.DIM}  Edit it to add your steps, then run:${c.RESET} ${c.CYAN}morning_routine${c.RESET}`);
  } else {
    writeConfig(configFile, { commands: entries, dateLastRun: '', lastStepRun: '' });
    console.log(`${c.GREEN}✓ Created:${c.RESET} ${c.BOLD}${configFile}${c.RESET} ${c.DIM}(${entries.length} step(s))${c.RESET}`);
    console.log(`${c.DIM}  Run your routine with:${c.RESET} ${c.CYAN}morning_routine${c.RESET}`);
  }
  process.exit(0);
}

// ─── Add step ─────────────────────────────────────────────────────────────────
async function addStepFlow(config) {
  const rl = makeRL();
  console.log();
  console.log(`${c.BOLD}Add a step to routine${c.RESET} ${c.DIM}(${configFile})${c.RESET}`);
  console.log();

  if (config.commands.length > 0) {
    console.log(`${c.DIM}  Existing steps:${c.RESET}`);
    for (const cmd of config.commands) console.log(`    • ${cmd.name}`);
    console.log();
  }

  const name = (await ask(rl, '  Name: ')).trim();
  if (!name) {
    console.log(`${c.YELLOW}⚠  No name given — nothing added.${c.RESET}`);
    rl.close();
    process.exit(0);
  }

  const rest = await askStepType(rl);
  rl.close();

  config.commands.push({ name, ...rest, dateLastRun: '' });
  writeConfig(configFile, config);
  console.log(`  ${c.GREEN}✓ Added '${name}'${c.RESET}`);
  process.exit(0);
}

// ─── Run a step ───────────────────────────────────────────────────────────────
function runStep(cmd) {
  return new Promise(resolve => {
    const proc = spawn(cmd, { shell: true, stdio: ['inherit', 'pipe', 'pipe'] });
    let buf = '';

    function handleData(data) {
      const chunk = buf + data.toString();
      const lines = chunk.split('\n');
      buf = lines.pop();
      for (const line of lines) streamLine(line);
    }

    proc.stdout.on('data', handleData);
    proc.stderr.on('data', handleData);
    proc.on('close', code => {
      if (buf) streamLine(buf);
      resolve(code ?? 0);
    });
  });
}

// ─── Main ─────────────────────────────────────────────────────────────────────
async function main() {
  if (doInit) initRoutine();

  if (!fs.existsSync(configFile)) {
    if (!process.stdin.isTTY) {
      console.error(`${c.RED}✗ Error:${c.RESET} config file not found: ${c.BOLD}${configFile}${c.RESET}`);
      console.error(`${c.DIM}  Create one with:${c.RESET} ${c.CYAN}morning_routine --init${c.RESET}`);
      process.exit(1);
    }
    await interactiveCreate();
    return;
  }

  const config = readConfig(configFile);

  if (addStep) {
    await addStepFlow(config);
    return;
  }

  const total    = config.commands.length;
  const lastRun  = config.dateLastRun  || 'never';
  const lastStep = config.lastStepRun  || '';

  console.log();
  console.log(`${c.BOLD}${c.CYAN}☀  Morning Routine${c.RESET}`);
  console.log(`${c.DIM}   config:    ${configFile}${c.RESET}`);
  console.log(`${c.DIM}   commands:  ${total}${c.RESET}`);
  console.log(`${c.DIM}   last run:  ${lastRun}${c.RESET}`);
  if (lastStep) console.log(`${c.DIM}   last step: ${lastStep}${c.RESET}`);
  if (dryRun)   console.log(`${c.YELLOW}   ⚠ dry-run mode${c.RESET}`);

  // ─── Determine starting index ───────────────────────────────────────────────
  let startIdx = 0;
  if (resume && lastStep) {
    const found = config.commands.findIndex(cmd => cmd.name === lastStep);
    if (found !== -1) {
      startIdx = found + 1;
      console.log(`${c.YELLOW}   ↻ resuming after '${lastStep}' (step ${startIdx + 1})${c.RESET}`);
    }
  } else if (fromName) {
    const found = config.commands.findIndex(cmd => cmd.name === fromName);
    if (found === -1) {
      console.error(`${c.RED}✗ Error:${c.RESET} no command named '${fromName}'`);
      process.exit(1);
    }
    startIdx = found;
    console.log(`${c.YELLOW}   → starting from '${fromName}'${c.RESET}`);
  }

  // ─── Run loop ───────────────────────────────────────────────────────────────
  const runStart = Date.now();
  let failed    = false;
  let completed = 0;

  for (let idx = startIdx; idx < total; idx++) {
    const step = config.commands[idx];
    const { name, command, script } = step;

    printHeader(idx + 1, total, name);

    let toRun, label;
    if (command && script) {
      console.log(`${c.YELLOW}⚠  both 'command' and 'script' set — using 'command'${c.RESET}`);
      toRun = command; label = command;
    } else if (command) {
      toRun = command; label = command;
    } else if (script) {
      if (!fs.existsSync(script)) {
        console.log(`${c.RED}✗ script not found: ${script}${c.RESET}`);
        failed = true;
        break;
      }
      toRun = `bash ${script}`; label = script;
    } else {
      console.log(`${c.YELLOW}⚠  no command or script — skipping${c.RESET}`);
      continue;
    }

    console.log(`${c.GRAY}╭─ $ ${label}${c.RESET}`);
    const stepStart = Date.now();

    let exitCode;
    if (dryRun) {
      console.log(`${c.GRAY}│${c.RESET} ${c.DIM}(dry-run, not executed)${c.RESET}`);
      exitCode = 0;
    } else {
      exitCode = await runStep(toRun);
    }

    const elapsed = Math.round((Date.now() - stepStart) / 1000);

    if (exitCode === 0) {
      console.log(`${c.GREEN}╰─ ✓ done${c.RESET} ${c.DIM}(${elapsed}s)${c.RESET}`);
      if (!dryRun) {
        config.commands[idx].dateLastRun = nowIso();
        config.lastStepRun  = name;
        config.dateLastRun  = nowIso();
        writeConfig(configFile, config);
      }
      completed++;
    } else {
      console.log(`${c.RED}╰─ ✗ failed${c.RESET} ${c.DIM}(exit ${exitCode}, ${elapsed}s)${c.RESET}`);
      failed = true;
      break;
    }
  }

  // ─── Summary ────────────────────────────────────────────────────────────────
  const totalElapsed = Math.round((Date.now() - runStart) / 1000);
  console.log();
  if (!failed) {
    console.log(`${c.GREEN}${c.BOLD}✓ Morning routine complete${c.RESET} ${c.DIM}— ${completed} step(s) in ${totalElapsed}s${c.RESET}`);
    process.exit(0);
  } else {
    const remaining = total - startIdx - completed;
    console.log(`${c.RED}${c.BOLD}✗ Morning routine stopped${c.RESET} ${c.DIM}— ${completed} done, ${remaining} remaining${c.RESET}`);
    console.log(`${c.DIM}  resume with:${c.RESET} ${c.CYAN}morning_routine ${configFile} --resume${c.RESET}`);
    process.exit(1);
  }
}

main().catch(err => {
  console.error(`${c.RED}✗ Unexpected error:${c.RESET}`, err.message);
  process.exit(1);
});
