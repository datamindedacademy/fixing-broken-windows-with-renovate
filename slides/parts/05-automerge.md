---
layout: section
---

# <span class="dm-accent">Automerge</span> the boring updates

---
layout: default
label: 5 · Automerge
---

# Automerge is only as safe as <span class="dm-accent">your tests</span>

<DmSteps dir="vertical" class="mt-4">
<DmStep :n="1" label="Checks">

`ci.yml` installs exactly what's in the lock files and smoke-tests the imports.

</DmStep>
<DmStep :n="2" label="Required">

A ruleset requires those checks, or a PR with *no checks yet* looks mergeable.

</DmStep>
<DmStep :n="3" label="Platform automerge">

Renovate turns on GitHub auto-merge (or GitLab / Azure DevOps equivalents). The platform merges the moment CI is green.

</DmStep>
</DmSteps>

<!--
terraform/github creates the ruleset with the four CI jobs as required checks and turns on
"Allow auto-merge" on the repository.
-->

---
layout: default
label: 5 · Automerge
---

# PR or <span class="dm-accent">branch</span>?

<DmComparison :rows="['What happens', 'Visible', 'Needs']" :cols="['automergeType: pr', 'automergeType: branch']" class="mt-6">
<template #r0c0>PR opened, merged when green</template>
<template #r0c1>No PR: branch tested, then merged straight into main</template>
<template #r1c0>Yes, traceable in the PR list</template>
<template #r1c1>Only in git history</template>
<template #r2c0>Required checks</template>
<template #r2c1>Push rights to main</template>
</DmComparison>

<p class="footnote">Use <code>branch</code> for zero-risk housekeeping: lock file maintenance, digests, pins.</p>

---
layout: default
label: 5 · Automerge
---

# Semantic versioning, <span class="dm-accent">and where it lies</span>

<DmColumns class="mt-4">
<DmColumn header="matchUpdateTypes" tone="navy">

| Type | Example |
| --- | --- |
| `patch` | `prettier 2.8.0 → 2.8.8` |
| `minor` | `requests 2.28 → 2.34` |
| `major` | `pydantic 1 → 2` |
| `digest`, `pin` | same version, made immutable |
| `lockFileMaintenance` | refresh transitive deps |

</DmColumn>
<DmColumn header="Where you need a rule" tone="violet" divider>

- **0.x**: semver §4, anything may change. `axios 0.27 → 0.35` is a "minor".
- **Docker tags** aren't semver: `python:3.10 → 3.15` is a "minor".
- **No semver at all**: CalVer, some cloud SDKs. Opt them out by name.

</DmColumn>
</DmColumns>

---
layout: default
label: 5 · Automerge
---

# The rules, <span class="dm-accent">top to bottom</span>

<div class="tight-code">

```json {all|2-5|6-9|10-13|14-18|all}
"packageRules": [
  { "description": "Stable: non-major updates are safe",
    "matchUpdateTypes": ["minor", "patch"],
    "matchCurrentVersion": "!/^(==)?v?0\\./",
    "automerge": true },
  { "description": "0.x: only patches are safe",
    "matchUpdateTypes": ["patch"],
    "matchCurrentVersion": "/^(==)?v?0\\./",
    "automerge": true },
  { "description": "Type definitions can't break production",
    "matchPackageNames": ["@types/**"],
    "automerge": true },
  { "description": "The framework always gets a review",
    "matchPackageNames": ["react", "react-dom", "@types/react",
      "@types/react-dom", "next"],
    "groupName": "react and next.js",
    "automerge": false }
]
```

</div>

<DmBanner tone="authentic" icon="i-mdi-sort-descending" title="Later rules win" class="mt-2">
Broad rules first, exceptions last. Conditions in one rule are AND, values in one array are OR.
</DmBanner>

<!--
(==)? because pep621 deps are written as ==0.95.0 and a regex is matched against the value as
written in the file. Full solution: session/solutions/05-automerge.json.
-->

---
layout: default
label: 5 · Automerge
---

# Expected <span class="dm-accent">result</span>

<table class="dm-table dm-table--dense">
<tbody>
<tr><th style="width: 22%">Dependency</th><th style="width: 18%">Current</th><th style="width: 18%">Update</th><th style="width: 16%">Automerge</th><th>Why</th></tr>
<tr><td>zod</td><td><code>3.19.0</code></td><td>minor</td><td>✅</td><td>stable, non-major</td></tr>
<tr><td>requests</td><td><code>==2.28.0</code></td><td>minor</td><td>✅</td><td>PEP 440 <code>==</code> prefix handled</td></tr>
<tr><td>axios</td><td><code>0.27.0</code></td><td>minor</td><td>❌</td><td>0.x</td></tr>
<tr><td>axios</td><td><code>0.27.0</code></td><td>patch</td><td>✅</td><td>0.x patch</td></tr>
<tr><td>@types/node</td><td><code>18.0.0</code></td><td><b>major</b></td><td>✅</td><td>package name rule</td></tr>
<tr><td>@types/react</td><td><code>18.0.0</code></td><td>minor</td><td>❌</td><td>framework rule comes later and wins</td></tr>
<tr><td>python image</td><td><code>3.10.0-slim</code></td><td>minor</td><td>❌</td><td>base images reviewed</td></tr>
<tr><td>aws provider</td><td><code>5.20.0</code></td><td>major</td><td>❌</td><td>needs dashboard approval</td></tr>
<tr><td>lock files</td><td>–</td><td>maintenance</td><td>✅</td><td>as a branch, no PR</td></tr>
</tbody>
</table>

<!--
Show this only after people have tried. Every row was checked against Renovate's own
package rule engine while building the course.
-->

---
layout: statement
---

# Exercise 5

<div class="ex-grid ex-grid--single">
<div class="ex-item">
<p class="ex-name">5 · Automerge</p>
<p class="ex-desc">Eight rules: semver, 0.x, housekeeping, @types, the framework group, base images, infra approvals and a minimum release age. Then break a PR on purpose.</p>
<p class="exercise-path"><code>session/05-automerge.md</code></p>
</div>
</div>
