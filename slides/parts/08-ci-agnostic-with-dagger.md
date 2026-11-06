---
layout: section
---

# CI-agnostic with <span class="dm-accent">Dagger</span>

---
layout: default
label: 8 · Dagger
---

# Five templates, <span class="dm-accent">five dialects</span>

<DmColumns class="mt-4">
<DmColumn header="Today" tone="navy">

- The same job written five times
- Each one debugged in its own CI
- None of them runs on your laptop

</DmColumn>
<DmColumn header="With Dagger" tone="violet" divider>

- The pipeline is **Python code** running in containers
- CI only provides Docker + one command
- Same run on the laptop and in CI, bit for bit

</DmColumn>
</DmColumns>

```bash
dagger call -m ./dagger run --token=env://RENOVATE_TOKEN \
  --platform=github --repositories=my-org/my-repo --dry-run=full
```

---
layout: default
label: 8 · Dagger
---

# The <span class="dm-accent">renovate-runner</span> module

<table class="dm-table">
<tbody>
<tr><th style="width: 22%">Function</th><th>Does</th></tr>
<tr><td><code>base</code></td><td>Renovate image + a persistent cache volume</td></tr>
<tr><td><code>version-info</code></td><td>Which Renovate is pinned?</td></tr>
<tr><td><code>validate</code></td><td><code>renovate-config-validator --strict</code> on the repo</td></tr>
<tr><td><code>local</code></td><td>Module 2's dry run, in one command</td></tr>
<tr><td><code>run</code></td><td>A real run, with the token as a Dagger <b>secret</b></td></tr>
</tbody>
</table>

<DmBanner tone="authentic" icon="i-mdi-key-outline" title="Why a secret and not an env variable?" class="mt-6">
Dagger caches and traces every operation. A plain env variable ends up in the cache key and the trace.
</DmBanner>

---
layout: default
label: 8 · Dagger
---

# When is it <span class="dm-accent">worth it</span>?

<DmComparison :rows="['Use it', 'Skip it']" class="mt-6">
<template #r0c0>Several CI systems (mergers, multi-cloud, on-prem + cloud) · you want to reproduce CI locally · you add testable pre-steps like minting CodeArtifact tokens</template>
<template #r1c0>One CI and a 20-line native template · runners that can't run privileged Docker · a team that doesn't want another tool</template>
</DmComparison>

<p class="footnote">Renovate is already "just a container", so the gain here is moderate. The pattern pays off more for build, test and publish.</p>

---
layout: statement
---

# Exercise 8

<div class="ex-grid ex-grid--single">
<div class="ex-item">
<p class="ex-name">8 · Dagger</p>
<p class="ex-desc">Explore the module, do a dry run from your laptop, then swap a native CI template for its Dagger version</p>
<p class="exercise-path"><code>session/08-ci-agnostic-with-dagger.md</code></p>
</div>
</div>
