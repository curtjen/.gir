---
name: generate-surge-pipelines
description: Generate GitHub Actions workflow YAML files for surge.sh deployments (QA, Stage, Production).
user-invocable: true
allowed-tools: Read, Write, Bash
---

# Generate Surge.sh GitHub Actions Workflows

Generate one or more GitHub Actions workflow YAML files for deploying to surge.sh. The three environments are **qa**, **stage**, and **production**, each with a dedicated workflow file under `.github/workflows/`.

## Ask the user (if not already specified)

Before generating, confirm:
1. **Which environment(s)** to generate: qa, stage, and/or production (default: all three).
2. **Output path**: default is `.github/workflows/`.

Then generate the requested files using the templates below.

---

## QA — `deploy_qa.yml`

- **Trigger**: push to `development` branch, plus `workflow_dispatch` with a `ref` input (default: `development`).
- **Guard**: `if: ${{ inputs.ref != 'main' }}` — prevents deploying main to QA by accident.
- **Environment**: `qa`
- **Concurrency group**: `surge-deploy-qa`

```yaml
name: Deploy QA

on:
  push:
    branches:
      - development
  workflow_dispatch:
    inputs:
      ref:
        description: "Git ref to deploy (branch name)"
        default: "development"
        required: true

concurrency:
  group: surge-deploy-qa
  cancel-in-progress: true

jobs:
  deploy:
    if: ${{ inputs.ref != 'main' }}
    runs-on: ubuntu-latest
    environment: qa

    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ inputs.ref }}

      - uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: "npm"

      - run: npm ci
      - run: npm run build:static

      - name: Deploy to Surge (QA)
        env:
          SURGE_TOKEN: ${{ secrets.SURGE_TOKEN }}
          SITE_DOMAIN: ${{ vars.SITE_DOMAIN }}
        run: |
          echo "Deploying QA ref '${{ inputs.ref }}' to $SITE_DOMAIN"
          npx surge dist/static "$SITE_DOMAIN" --token "$SURGE_TOKEN"
```

---

## Stage — `deploy_stage.yml`

- **Trigger**: `workflow_dispatch` only, with a `ref` input (default: `release`).
- **Guard**: `startsWith(inputs.ref, 'release')` — accepts any branch like `release/foo` or `release/biz-bar-1234`.
- **Environment**: `stage`
- **Concurrency group**: `surge-deploy-stage`

```yaml
name: Deploy Stage

on:
  workflow_dispatch:
    inputs:
      ref:
        description: "Git ref to deploy (branch name, e.g. release/foo or release/biz-bar-1234)"
        default: "release"
        required: true

concurrency:
  group: surge-deploy-stage
  cancel-in-progress: true

jobs:
  deploy:
    if: ${{ startsWith(inputs.ref, 'release') }}
    runs-on: ubuntu-latest
    environment: stage

    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ inputs.ref }}

      - uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: "npm"

      - run: npm ci
      - run: npm run build:static

      - name: Deploy to Surge (Stage)
        env:
          SURGE_TOKEN: ${{ secrets.SURGE_TOKEN }}
          SITE_DOMAIN: ${{ vars.SITE_DOMAIN }}
        run: |
          echo "Deploying Stage ref '${{ inputs.ref }}' to $SITE_DOMAIN"
          npx surge dist/static "$SITE_DOMAIN" --token "$SURGE_TOKEN"
```

---

## Production — `deploy_production.yml`

- **Trigger**: `workflow_dispatch` only, with a `ref` input (no default — must be explicit).
- **Guard**: `if: ${{ inputs.ref == 'main' }}` — only `main` may deploy to production.
- **Environment**: `production`
- **Concurrency group**: `surge-deploy-production`

```yaml
name: Deploy Production

on:
  workflow_dispatch:
    inputs:
      ref:
        description: "Git ref to deploy (branch name)"
        required: true

concurrency:
  group: surge-deploy-production
  cancel-in-progress: true

jobs:
  deploy:
    if: ${{ inputs.ref == 'main' }}
    runs-on: ubuntu-latest
    environment: production

    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ inputs.ref }}

      - uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: "npm"

      - run: npm ci
      - run: npm run build:static

      - name: Deploy to Surge (Production)
        env:
          SURGE_TOKEN: ${{ secrets.SURGE_TOKEN }}
          SITE_DOMAIN: ${{ vars.SITE_DOMAIN }}
        run: |
          echo "Deploying Production (main) to $SITE_DOMAIN"
          npx surge dist/static "$SITE_DOMAIN" --token "$SURGE_TOKEN"
```

---

## After generating

- Write each requested file to `.github/workflows/deploy_<environment>.yml` using the Write tool.
- Confirm the files were written and note the key guard condition for each:
  - QA: `inputs.ref != 'main'`
  - Stage: `startsWith(inputs.ref, 'release')`
  - Production: `inputs.ref == 'main'`
- Remind the user to configure the following in their GitHub repo settings for each environment (`qa`, `stage`, `production`):
  - **Secret**: `SURGE_TOKEN`
  - **Variable**: `SITE_DOMAIN` (e.g. `my-site-qa.surge.sh`)
