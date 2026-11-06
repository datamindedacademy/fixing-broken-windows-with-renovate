---
layout: section
---

# Custom managers and <span class="dm-accent">custom datasources</span>

---
layout: default
label: 7 · Custom
---

# When Renovate is <span class="dm-accent">blind</span>

<DmComparison :rows="['Problem', 'Fix', 'Example']" :cols="['Custom manager', 'Custom datasource']" class="mt-6">
<template #r0c0>Can't <b>find</b> the version in your file</template>
<template #r0c1>Can't <b>look up</b> new versions from your source</template>
<template #r1c0><code>customManagers</code>: regex or JSONata</template>
<template #r1c1><code>customDatasources</code>: URL + JSONata transform</template>
<template #r2c0><code>RUN pip install uv==0.1.0</code></template>
<template #r2c1>EKS versions on endoflife.date</template>
</DmComparison>

---
layout: default
label: 7 · Custom
---

# The annotation <span class="dm-accent">pattern</span>

<DmColumns class="mt-4" :gap="24">
<DmColumn tone="plain">

Before: invisible to Renovate

```dockerfile
RUN pip install uv==0.1.0
```

After: one comment, one variable

```dockerfile {1}
# renovate: datasource=pypi depName=uv
ARG UV_VERSION=0.1.0
RUN pip install uv==${UV_VERSION}
```

</DmColumn>
<DmColumn tone="plain" divider>

```json
{
  "extends": [
    "config:recommended",
    "customManagers:dockerfileVersions"
  ]
}
```

Presets for the common cases: `dockerfileVersions`, `githubActionsVersions`, `gitlabPipelineVersions`, `makefileVersions`, `tfvarsVersions`, …

</DmColumn>
</DmColumns>

---
layout: default
label: 7 · Custom
---

# Renovate updates <span class="dm-accent">its own runner</span>

<div class="small-code">

```yaml
# ci-templates/aws-codebuild/buildspec.yml (same pattern in Azure, GitHub Actions, Dagger)
# renovate: datasource=docker depName=ghcr.io/renovatebot/renovate
RENOVATE_VERSION: "44.210.2"
```

</div>

One `regex` custom manager, scanning `ci-templates/`, `.github/workflows/`, `dagger/src/` and `*.tf`:

<div class="small-code">

```text
#\s*renovate:\s*datasource=(?<datasource>\S+)\s+depName=(?<depName>\S+)
(\s+versioning=(?<versioning>\S+))?\s*\n
\s*-?\s*[\w.-]+\s*[:=]\s*["']?(?<currentValue>[^"'\s]+)["']?
```

</div>

<p class="text-sm opacity-70">One string in <code>matchStrings</code>, split here for reading. In JSON every <code>\</code> doubles. Full config: <code>session/solutions/07-custom-managers.json</code></p>

<!--
Named groups Renovate needs: datasource, depName (or packageName), currentValue. Test on
regex101 with the ECMAScript flavour, then double every backslash for JSON.
Gotcha with config:best-practices: add matchManagers custom.regex + pinDigests false.
-->

---
layout: default
label: 7 · Custom
---

# A custom datasource in <span class="dm-accent">a few lines</span>

<div class="tight-code">

```json
"customDatasources": {
  "endoflife": {
    "defaultRegistryUrlTemplate": "https://endoflife.date/api/{{packageName}}.json",
    "transformTemplates": ["<the JSONata below, on one line>"]
  }
}
```

```text
{ "releases": $map($, function($v) {
    { "version": $v.cycle, "releaseTimestamp": $v.releaseDate,
      "isDeprecated": $type($v.eol) = "string" and $toMillis($v.eol) < $millis() } }) }
```

```hcl
variable "eks_cluster_version" {
  # renovate: datasource=custom.endoflife depName=amazon-eks versioning=loose
  default = "1.29"
}
```

</div>

<p class="text-sm text-center">Result: a PR for <b>EKS 1.29 → 1.34</b>. Works for any JSON, YAML, TOML, plain-text or HTML endpoint, including internal ones.</p>

---
layout: statement
---

# Exercise 7

<div class="ex-grid">
<div class="ex-item">
<p class="ex-name">7.1 · uv</p>
<p class="ex-desc">Annotate the Dockerfile and enable the preset</p>
<p class="exercise-path"><code>Dockerfile</code></p>
</div>
<div class="ex-item">
<p class="ex-name">7.2 · Runner</p>
<p class="ex-desc">One regex manager for every annotated version in the repo</p>
<p class="exercise-path"><code>ci-templates/</code></p>
</div>
<div class="ex-item">
<p class="ex-name">7.3 · EKS</p>
<p class="ex-desc">A custom datasource on endoflife.date</p>
<p class="exercise-path"><code>infra/variables.tf</code></p>
</div>
</div>

<p class="exercise-path" style="margin-top: 22px"><code>session/07-custom-managers-and-datasources.md</code></p>
