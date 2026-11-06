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
