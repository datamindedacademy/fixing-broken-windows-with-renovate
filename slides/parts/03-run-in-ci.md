---
layout: section
---

# Self-hosted Renovate <span class="dm-accent">in CI</span>

---
layout: default
label: 3 · Renovate in CI
---

# Every Renovate job has the same <span class="dm-accent">five ingredients</span>

<table class="dm-table mt-4">
<tbody>
<tr><th style="width: 22%">Trigger</th><td>A cron schedule, plus a "run now" button</td></tr>
<tr><th>Runtime</th><td>The official image <code>ghcr.io/renovatebot/renovate</code>: installs <code>uv</code>, <code>bun</code>, <code>helm</code>, … on demand to update lock files</td></tr>
<tr><th>Identity</th><td>A token that can push branches, open PRs and (for the dashboard) create issues</td></tr>
<tr><th>Targets</th><td><code>RENOVATE_REPOSITORIES</code>, or <code>RENOVATE_AUTODISCOVER</code> + a filter</td></tr>
<tr><th>Mutual exclusion</th><td>Never two runs at once: <code>concurrency</code>, <code>resource_group</code>, <code>concurrent_build_limit</code></td></tr>
</tbody>
</table>

<DmBanner tone="authentic" icon="i-mdi-github" title="Plus: a read-only github.com token, even if you're not on GitHub" class="mt-6">
Release notes and many versions come from github.com, and anonymous calls get 60 per hour.
</DmBanner>

---
layout: default
label: 3 · Renovate in CI
---

# One template per <span class="dm-accent">CI system</span>

<table class="dm-table">
<tbody>
<tr><th style="width: 21%">CI</th><th style="width: 24%">Schedule</th><th style="width: 30%">Token</th><th>Infra</th></tr>
<tr><td>GitHub Actions</td><td><code>on.schedule</code></td><td>GitHub App token</td><td><code>terraform/github</code></td></tr>
<tr><td>GitLab CI</td><td>Pipeline schedule</td><td>Project access token, rotated</td><td><code>terraform/gitlab</code></td></tr>
<tr><td>Azure Pipelines</td><td><code>schedules:</code> in YAML</td><td><code>$(System.AccessToken)</code></td><td><code>terraform/azure-devops</code></td></tr>
<tr><td>Bitbucket Pipelines</td><td>Schedule on a custom pipeline</td><td>Access token, secured variable</td><td><code>terraform/bitbucket</code></td></tr>
<tr><td>AWS CodeBuild</td><td>EventBridge Scheduler</td><td>Secrets Manager</td><td><code>terraform/aws-codebuild</code></td></tr>
<tr><td>Anything with Docker</td><td>Your CI's</td><td>Your CI's</td><td>Dagger, module 8</td></tr>
</tbody>
</table>

<p class="footnote text-sm opacity-70">All in <code>ci-templates/</code>. CodeBuild can update repos on <i>any</i> platform: it's only the runner.</p>

---
layout: default
label: 3 · Renovate in CI
---

# Why not <span class="dm-accent">GITHUB_TOKEN</span>?

<div class="punchline">PRs opened with <code>GITHUB_TOKEN</code> don't trigger workflows.</div>

<DmSteps dir="horizontal" class="mt-8">
<DmStep :n="1" label="No CI">

Your tests never run on Renovate PRs.

</DmStep>
<DmStep :n="2" label="No green">

No status checks, nothing to wait for.

</DmStep>
<DmStep :n="3" label="No automerge">

Automerge waits forever.

</DmStep>
</DmSteps>

<p class="mt-6 text-center">Use a <b>GitHub App</b>: short-lived tokens, shows up as <code>my-renovate[bot]</code>.</p>

<!--
App permissions: Contents RW, Pull requests RW, Issues RW, Workflows RW, Checks and Commit
statuses read. A fine-grained PAT also works but is tied to a person.
-->

---
layout: default
label: 3 · Renovate in CI
---

# The GitHub Actions <span class="dm-accent">workflow</span>

<div class="tight-code">

```yaml {all|2-4|6-8|12-16|17-24|all}
on:
  schedule:
    - cron: "17 5 * * 1-5"   # weekdays, avoid minute 0
  workflow_dispatch:
concurrency:
  group: renovate
  cancel-in-progress: false
jobs:
  renovate:
    runs-on: ubuntu-latest
    steps:
      - id: app-token
        uses: actions/create-github-app-token@v3.3.0
        with:
          client-id: ${{ vars.RENOVATE_APP_CLIENT_ID }}
          private-key: ${{ secrets.RENOVATE_APP_PRIVATE_KEY }}
      - uses: renovatebot/github-action@v46.3.12
        with:
          token: ${{ steps.app-token.outputs.token }}
          # renovate: datasource=docker depName=ghcr.io/renovatebot/renovate
          renovate-version: 44.210.2
        env:
          RENOVATE_REPOSITORIES: ${{ github.repository }}
          # RENOVATE_AUTODISCOVER: "true"
```

</div>

<!--
Full file: ci-templates/github-actions/renovate.yml. The real one also re-runs when someone
ticks a box in the Dependency Dashboard (issues: edited).
-->

---
layout: default
label: 3 · Renovate in CI
---

# Two schedules, <span class="dm-accent">not one</span>

<DmComparison :rows="['Defined in', 'Decides', 'Example']" :cols="['Job schedule', 'Renovate schedule']" class="mt-6">
<template #r0c0>The CI cron</template>
<template #r0c1><code>"schedule"</code> in renovate.json</template>
<template #r1c0>When the bot runs at all</template>
<template #r1c1>When it may create branches and PRs</template>
<template #r2c0><code>17 5 * * 1-5</code></template>
<template #r2c1><code>* 0-8 * * 1-5</code></template>
</DmComparison>

<DmBanner tone="navy" icon="i-mdi-alert-outline" title="Classic mistake" class="mt-6">
If the cron never falls inside the schedule window, Renovate never opens a PR. Running hourly is fine: it's cheap with the repository cache.
</DmBanner>

---
layout: statement
---

# Exercise 3

<div class="ex-grid ex-grid--single">
<div class="ex-item">
<p class="ex-name">3 · Renovate in GitHub Actions</p>
<p class="ex-desc">Create a GitHub App, add its credentials (by hand or with Terraform), add the workflow, run it and inspect the Dependency Dashboard and PRs</p>
<p class="exercise-path"><code>session/03-run-in-ci.md</code></p>
</div>
</div>
