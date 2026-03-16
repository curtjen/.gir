---
name: setup-cicd
description: Scaffold CI/CD pipeline and deployment workflows for a project. Auto-detects project type and target platform, confirms the plan with the user, then writes the workflow files and outputs a secrets checklist.
user-invocable: true
allowed-tools: Read, Write, Bash, Glob, Grep, AskUserQuestion
---

# Setup CI/CD

Follow these steps in order. Do not skip steps or write files before user confirmation.

---

## Step 1 — Detect project configuration

Read `package.json` (if present) and inspect the project root. Determine:

**Framework detection** (check `dependencies` and `devDependencies`):
- `vite` + `react` → React/Vite SPA, build output: `dist/`
- `next` → Next.js, check for `"output": "export"` in next.config → static to `out/`, otherwise skip (Vercel-native)
- `vue` or `nuxt` → Vue/Nuxt SPA, build output: `dist/`
- No build tool found → Static HTML, no build step, source dir: `./` or `public/`

**Build command detection** (from `scripts` in package.json):
- Use `build` script if present, else `vite build`

**Test/lint commands** (from `scripts`):
- `lint`, `test`, `type-check` — note which exist

**Existing workflows**: Check if `.github/workflows/` already exists and list any `.yml` files found.

**Package manager**: Check for `pnpm-lock.yaml` → pnpm, `yarn.lock` → yarn, else npm.

---

## Step 2 — Determine CI and hosting providers

**Default plan (current stack):**
- CI: GitHub Actions
- Hosting: surge.sh

If the project has a `vercel.json` or `netlify.toml`, note that as an alternative and ask the user which host to target. Otherwise proceed with surge.sh.

---

## Step 3 — Present the plan

Show the user a summary table like this:

```
Detected config
───────────────────────────────────
Framework:       React / Vite SPA
Build command:   npm run build
Build output:    dist/
Package manager: npm
CI provider:     GitHub Actions
Host:            surge.sh

Files to create
───────────────────────────────────
.github/workflows/ci.yml        ← lint + test on every PR and push
.github/workflows/deploy.yml    ← build + deploy to surge.sh on push to main
.github/workflows/preview.yml   ← PR preview deploy + comment with URL (optional)

Secrets required (configure in GitHub repo → Settings → Secrets → Actions)
───────────────────────────────────
SURGE_TOKEN    Your surge.sh auth token (run: npx surge token)
SURGE_DOMAIN   Your surge.sh domain (e.g. my-app.surge.sh)
```

Ask: "Does this look right? Type 'yes' to write the files, 'no' to cancel, or describe any changes."

If the user requests changes (different host, different branch, skip preview), adjust accordingly before writing.

---

## Step 4 — Write the workflow files

Only proceed after explicit confirmation. Create `.github/workflows/` if it doesn't exist.

### ci.yml

Write `.github/workflows/ci.yml` with this content, substituting the correct package manager install command (`npm ci`, `pnpm install --frozen-lockfile`, or `yarn install --frozen-lockfile`) and only including lint/test steps if those scripts exist in package.json:

```yaml
name: CI

on:
  push:
    branches: ["**"]
  pull_request:
    branches: ["**"]

jobs:
  build-and-test:
    name: Build & Test
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: "npm"

      - name: Install dependencies
        run: npm ci

      # Include this step only if a "lint" script exists in package.json
      - name: Lint
        run: npm run lint

      # Include this step only if a "type-check" or "typecheck" script exists
      - name: Type check
        run: npm run type-check

      # Include this step only if a "test" script exists
      - name: Test
        run: npm test -- --run

      - name: Build
        run: npm run build

      - name: Upload build artifact
        uses: actions/upload-artifact@v4
        with:
          name: dist
          path: dist/
          retention-days: 1
```

### deploy.yml

Write `.github/workflows/deploy.yml`:

```yaml
name: Deploy

on:
  push:
    branches:
      - main

jobs:
  deploy:
    name: Deploy to surge.sh
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: "npm"

      - name: Install dependencies
        run: npm ci

      - name: Build
        run: npm run build

      - name: Deploy to surge.sh
        run: npx surge dist/ ${{ secrets.SURGE_DOMAIN }} --token ${{ secrets.SURGE_TOKEN }}
```

### preview.yml

Write `.github/workflows/preview.yml` only if the user confirmed they want PR previews:

```yaml
name: PR Preview

on:
  pull_request:
    types: [opened, synchronize, reopened, closed]

permissions:
  pull-requests: write

jobs:
  preview:
    name: Deploy PR Preview
    runs-on: ubuntu-latest
    if: github.event.action != 'closed'

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: "npm"

      - name: Install dependencies
        run: npm ci

      - name: Build
        run: npm run build

      - name: Deploy preview
        id: deploy
        run: |
          PREVIEW_DOMAIN="pr-${{ github.event.pull_request.number }}-${{ secrets.SURGE_DOMAIN }}"
          npx surge dist/ $PREVIEW_DOMAIN --token ${{ secrets.SURGE_TOKEN }}
          echo "url=https://$PREVIEW_DOMAIN" >> $GITHUB_OUTPUT

      - name: Comment preview URL on PR
        uses: actions/github-script@v7
        with:
          script: |
            const { data: comments } = await github.rest.issues.listComments({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
            });
            const bot = comments.find(c => c.user.type === 'Bot' && c.body.includes('Preview deployed'));
            const body = `🚀 **Preview deployed:** [${{ steps.deploy.outputs.url }}](${{ steps.deploy.outputs.url }})`;
            if (bot) {
              github.rest.issues.updateComment({ owner: context.repo.owner, repo: context.repo.repo, comment_id: bot.id, body });
            } else {
              github.rest.issues.createComment({ owner: context.repo.owner, repo: context.repo.repo, issue_number: context.issue.number, body });
            }

  teardown:
    name: Teardown PR Preview
    runs-on: ubuntu-latest
    if: github.event.action == 'closed'

    steps:
      - name: Teardown surge preview
        run: |
          PREVIEW_DOMAIN="pr-${{ github.event.pull_request.number }}-${{ secrets.SURGE_DOMAIN }}"
          npx surge teardown $PREVIEW_DOMAIN --token ${{ secrets.SURGE_TOKEN }}
```

---

## Step 5 — Output post-setup checklist

After writing files, display this checklist:

```
Setup complete. Next steps:
───────────────────────────────────────────────────────
 [ ] Add SURGE_TOKEN secret to GitHub repo
     → Run: npx surge token
     → Add at: github.com/<owner>/<repo>/settings/secrets/actions

 [ ] Add SURGE_DOMAIN secret to GitHub repo
     → Your domain (e.g. my-app.surge.sh)
     → Claim it first: npx surge <build-dir> <domain>

 [ ] Commit and push the workflow files to trigger your first CI run

 [ ] Verify the Actions tab on GitHub shows the CI workflow running

 [ ] Merge a test PR to confirm preview deploy and teardown work
───────────────────────────────────────────────────────
Tip: Run `npx surge login` to authenticate, then `npx surge token` to get your token.
```

---

## Provider extension notes

This skill currently supports:
- **CI**: GitHub Actions
- **Hosts**: surge.sh

To add support for another host, follow the same pattern:
- Netlify: use `netlify deploy --dir=dist --prod` with `NETLIFY_AUTH_TOKEN` + `NETLIFY_SITE_ID`
- Vercel: use `vercel deploy --prod --token` with `VERCEL_TOKEN` + `VERCEL_ORG_ID` + `VERCEL_PROJECT_ID`
- GitHub Pages: use `actions/deploy-pages` with artifact upload pattern
