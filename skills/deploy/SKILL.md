---
name: deploy
description: Build and deploy the current project to its configured hosting provider. Reads project config to determine the deployment target, runs the build, and deploys. Supports surge.sh, Netlify CLI, and Vercel CLI.
user-invocable: true
allowed-tools: Read, Bash, Glob
---

# Deploy

Follow these steps in order.

---

## Step 1 — Detect deployment target

Check in this order:

1. **`.deploy-config`** file in project root (JSON or YAML with `host`, `domain`, `buildDir` fields)
2. **`package.json`** for a `deploy` script — show it to the user and confirm before running
3. **`.github/workflows/deploy.yml`** — extract the host and domain from workflow env/secrets references
4. **`vercel.json`** present → host is Vercel
5. **`netlify.toml`** present → host is Netlify
6. No config found → ask the user which host to deploy to

---

## Step 2 — Confirm before deploying

Show the user:
```
Deploy plan
─────────────────────────────────
Host:          surge.sh
Domain:        <SURGE_DOMAIN from env or detected config>
Build command: npm run build
Build output:  dist/
Branch:        <current git branch>
```

Ask: "Ready to build and deploy? (yes/no)"

Do not proceed without explicit confirmation.

---

## Step 3 — Run the deployment

### surge.sh

Check for `SURGE_TOKEN` and `SURGE_DOMAIN` in the environment (`.env.local`, shell env, or `.env`). If missing, tell the user:
```
Missing required environment variables:
  SURGE_TOKEN  — run: npx surge token
  SURGE_DOMAIN — your surge.sh domain (e.g. my-app.surge.sh)

Add them to your .env.local or export them before running /deploy.
```

If available:
```bash
npm run build && npx surge dist/ $SURGE_DOMAIN --token $SURGE_TOKEN
```

### Netlify CLI

```bash
npm run build && npx netlify deploy --dir=dist --prod
```

Requires `NETLIFY_AUTH_TOKEN` and `NETLIFY_SITE_ID` in env or `netlify.toml`.

### Vercel CLI

```bash
npx vercel deploy --prod
```

Requires `VERCEL_TOKEN` in env or active Vercel CLI login.

---

## Step 4 — Report result

On success, output:
```
Deployed successfully
─────────────────────────────
URL: https://<domain>
```

On failure, show the error output and suggest:
- Check that secrets/env vars are set correctly
- Verify the build output directory exists and is not empty
- Check that the domain is already claimed (surge.sh requires first-time claim via `npx surge dist/ <domain>`)
