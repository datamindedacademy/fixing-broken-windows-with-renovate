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
