#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

function fail(message) {
  process.stderr.write(`${message}\n`);
  process.exit(1);
}

function resolveConfigPath(configPath) {
  return path.resolve(configPath);
}

function ensureConfigExists(configPath) {
  const resolvedPath = resolveConfigPath(configPath);

  if (!fs.existsSync(resolvedPath)) {
    fail(`Config file not found at ${resolvedPath}`);
  }

  return resolvedPath;
}

function parseConfig(configPath) {
  const resolvedPath = ensureConfigExists(configPath);
  const raw = fs.readFileSync(resolvedPath, "utf8");

  let data;
  try {
    data = JSON.parse(raw);
  } catch (error) {
    fail(`Invalid JSON in config file at ${resolvedPath}: ${error.message}`);
  }

  if (!data || typeof data !== "object" || Array.isArray(data)) {
    fail(`Config file must contain a JSON object: ${resolvedPath}`);
  }

  return { resolvedPath, data };
}

function validateConfigSchema(data, resolvedPath) {
  if (typeof data.chrome_profile !== "string") {
    fail(`Config field "chrome_profile" must be a string: ${resolvedPath}`);
  }

  if (!data.urls || typeof data.urls !== "object" || Array.isArray(data.urls)) {
    fail(`Config field "urls" must be an object: ${resolvedPath}`);
  }

  if (!data.apps || typeof data.apps !== "object" || Array.isArray(data.apps)) {
    fail(`Config field "apps" must be an object: ${resolvedPath}`);
  }

  if (!Array.isArray(data.docker_services)) {
    fail(`Config field "docker_services" must be an array: ${resolvedPath}`);
  }

  if (
    !data.delays ||
    typeof data.delays !== "object" ||
    Array.isArray(data.delays)
  ) {
    fail(`Config field "delays" must be an object: ${resolvedPath}`);
  }

  if (
    !data.state ||
    typeof data.state !== "object" ||
    Array.isArray(data.state)
  ) {
    fail(`Config field "state" must be an object: ${resolvedPath}`);
  }

  if (typeof data.state.in_progress !== "string") {
    fail(`Config field "state.in_progress" must be a string: ${resolvedPath}`);
  }

  if (typeof data.state.updated_at !== "string") {
    fail(`Config field "state.updated_at" must be a string: ${resolvedPath}`);
  }

  if (typeof data.state.last_morning_run_at !== "string") {
    fail(
      `Config field "state.last_morning_run_at" must be a string: ${resolvedPath}`,
    );
  }
}

function loadConfig(configPath) {
  const { resolvedPath, data } = parseConfig(configPath);
  validateConfigSchema(data, resolvedPath);

  return { resolvedPath, data };
}

function saveConfig(configPath, data) {
  fs.writeFileSync(configPath, `${JSON.stringify(data, null, 2)}\n`);
}

function delayFor(data, key) {
  const numeric = Number.parseInt(data.delays[key] ?? 0, 10);

  if (Number.isFinite(numeric)) {
    return String(numeric);
  }

  return "0";
}

function emitRows(rows) {
  for (const row of rows) {
    process.stdout.write(`${row.join("\t")}\n`);
  }
}

function nowIso() {
  return new Date().toISOString();
}

function cmdStateField(configPath, field) {
  const { data } = loadConfig(configPath);
  process.stdout.write(`${data.state[field] ?? ""}\n`);
}

function cmdChromeProfile(configPath) {
  const { data } = loadConfig(configPath);
  process.stdout.write(`${data.chrome_profile ?? ""}\n`);
}

function cmdListApps(configPath) {
  const { data } = loadConfig(configPath);
  const rows = Object.entries(data.apps).map(([key, value]) => [
    key,
    String(value),
    delayFor(data, key),
  ]);
  emitRows(rows);
}

function cmdListUrls(configPath) {
  const { data } = loadConfig(configPath);
  const rows = Object.entries(data.urls).map(([key, value]) => [
    key,
    String(value),
    delayFor(data, key),
  ]);
  emitRows(rows);
}

function cmdListDockerServices(configPath) {
  const { data } = loadConfig(configPath);
  const rows = [];

  for (const item of data.docker_services) {
    if (typeof item === "string") {
      rows.push(["command", item, ""]);
      continue;
    }

    if (!item || typeof item !== "object") {
      continue;
    }

    if (typeof item.command === "string") {
      rows.push(["command", item.command, ""]);
      continue;
    }

    const directory = item.directory ? String(item.directory) : "";
    const services = Array.isArray(item.services)
      ? item.services.map(String).join(",")
      : "";
    rows.push(["compose", directory, services]);
  }

  emitRows(rows);
}

function cmdSetInProgress(configPath, message) {
  const { resolvedPath, data } = loadConfig(configPath);
  data.state.in_progress = message;
  data.state.updated_at = nowIso();
  saveConfig(resolvedPath, data);
}

function cmdClearInProgress(configPath) {
  const { resolvedPath, data } = loadConfig(configPath);
  data.state.in_progress = "";
  data.state.updated_at = nowIso();
  saveConfig(resolvedPath, data);
}

function cmdMarkMorningRun(configPath) {
  const { resolvedPath, data } = loadConfig(configPath);
  data.state.last_morning_run_at = nowIso();
  saveConfig(resolvedPath, data);
}

function cmdValidate(configPath) {
  loadConfig(configPath);
}

function main(argv) {
  if (argv.length < 4) {
    fail("usage: routine-config-helper.js <command> <config> [args...]");
  }

  const command = argv[2];
  const configPath = argv[3];

  if (command === "state-field") {
    if (argv.length !== 5) {
      fail("state-field requires a field name");
    }
    cmdStateField(configPath, argv[4]);
    return;
  }

  if (command === "chrome-profile") {
    cmdChromeProfile(configPath);
    return;
  }

  if (command === "list-apps") {
    cmdListApps(configPath);
    return;
  }

  if (command === "list-urls") {
    cmdListUrls(configPath);
    return;
  }

  if (command === "list-docker-services") {
    cmdListDockerServices(configPath);
    return;
  }

  if (command === "set-in-progress") {
    if (argv.length !== 5) {
      fail("set-in-progress requires a message");
    }
    cmdSetInProgress(configPath, argv[4]);
    return;
  }

  if (command === "clear-in-progress") {
    cmdClearInProgress(configPath);
    return;
  }

  if (command === "mark-morning-run") {
    cmdMarkMorningRun(configPath);
    return;
  }

  if (command === "validate") {
    cmdValidate(configPath);
    return;
  }

  fail(`unknown command: ${command}`);
}

main(process.argv);
