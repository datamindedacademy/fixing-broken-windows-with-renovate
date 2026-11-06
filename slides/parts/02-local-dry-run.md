---
layout: default
label: 2 · Dry run
---

# No token, no platform: <span class="dm-accent">platform=local</span>

```bash {all|1|3|all}
docker run --rm -v "$PWD:/usr/src/app:ro" -w /usr/src/app \
  -e LOG_LEVEL=debug \
  ghcr.io/renovatebot/renovate:44 renovate --platform=local
```

- Scans the **current directory**, never pushes, never opens a PR
- Look for `Dependency extraction complete` and `packageFiles with updates`
- Perfect for trying out config before you give the bot any rights

<!--
Without Docker: npx renovate@44 --platform=local. Lock file updates then need uv, bun, ... on
your PATH, which is exactly why CI uses the official image.
-->

---
layout: default
label: 2 · Dry run
---

# What the output <span class="dm-accent">tells you</span>

<v-clicks>

- `axios 0.27 → 0.35` is a **minor**. Safe? Before 1.0, semver says *anything may change*.
- `python:3.10 → 3.15` is a **minor** too. By Docker tag yes, for CPython and its wheels, no.
- `uv==0.1.0` in the Dockerfile: **not found**. A `RUN pip install` is a shell command.
- The EKS version in `infra/variables.tf`: **not found**. No manager, no datasource.
- No Terraform CLI versions: lookups on github.com need a **token**.

</v-clicks>

<!--
Ask the room before revealing each answer. The first two drive module 5, the next two drive
module 7, the last one drives the RENOVATE_GITHUB_COM_TOKEN advice in module 3.
-->

---
layout: statement
---

# Exercise 2

<div class="ex-grid ex-grid--single">
<div class="ex-item">
<p class="ex-name">2 · Dry run</p>
<p class="ex-desc">Run Renovate locally, summarise the report and answer the six questions</p>
<p class="exercise-path"><code>session/02-local-dry-run.md</code></p>
</div>
</div>
