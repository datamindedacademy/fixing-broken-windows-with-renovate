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
