# 7. Lab: custom managers and custom datasources

Renovate ships with 100+ managers and 90+ datasources. Real repositories still
have versions hidden in places nobody anticipated: a `pip install` in a
Dockerfile, a tool version in a Makefile, a cluster version in Terraform, the
Renovate version in your own CI templates…

| You need… | Because Renovate can't… | Use |
|-----------|-------------------------|-----|
| a **custom manager** | *find* the version in your file | `customManagers` (`regex` or `jsonata`) |
| a **custom datasource** | *look up* new versions from your source | `customDatasources` |

## 7.1 Custom managers: teach Renovate to *find* versions

A regex custom manager has:

- `managerFilePatterns`: which files to scan (`/regex/` or glob).
- `matchStrings`: regexes with **named groups**. Renovate needs `currentValue`, `depName` (or
  `packageName`) and `datasource`. Optional: `versioning`, `registryUrl`, `currentDigest`, `extractVersion`.
- `*Template` fields for anything not captured: `datasourceTemplate`, `depNameTemplate`, `versioningTemplate`, …

The most reusable pattern is an **annotation comment** on the line above the version:

```dockerfile
# renovate: datasource=pypi depName=uv
ARG UV_VERSION=0.1.0
RUN pip install uv==${UV_VERSION}
```

Renovate even ships presets for the common cases: `customManagers:dockerfileVersions`,
`customManagers:githubActionsVersions`, `customManagers:gitlabPipelineVersions`,
`customManagers:makefileVersions`, `customManagers:tfvarsVersions`,
`customManagers:helmChartYamlAppVersions`, …

### Exercise 7.1: the uv version in the Dockerfile

Module 2 showed Renovate doesn't see `uv==0.1.0`. Fix it:

1. Rewrite the `pip install` line in the `Dockerfile` as above (`ARG` + annotation).
2. Enable the `customManagers:dockerfileVersions` preset in `renovate.json`.
3. Dry-run locally (module 2). You should see a `regex` manager with `uv 0.1.0 → 0.x`.

### Exercise 7.2: Renovate updates its own runner

Our CI templates pin the Renovate image. The `gitlabci` and `bitbucket-pipelines`
managers update `image:` keys automatically. But in the CodeBuild buildspec, the
Azure pipeline, the GitHub Actions `renovate-version` input and the Dagger module,
the version is just a string:

```yaml
# ci-templates/aws-codebuild/buildspec.yml
    # renovate: datasource=docker depName=ghcr.io/renovatebot/renovate
    RENOVATE_VERSION: "44.210.2"
```

```python
# dagger/src/renovate_runner/main.py
# renovate: datasource=docker depName=ghcr.io/renovatebot/renovate
RENOVATE_VERSION = "44.210.2"
```

The annotations are already there. Write **one** `regex` custom manager that:

- scans `ci-templates/**/*.yml`, `.github/workflows/*.yml`, `dagger/src/**/*.py` and `*.tf`;
- matches a `# renovate: datasource=X depName=Y [versioning=Z]` line followed by a line
  `key: value`, `key = "value"` or `- key: value`;
- captures `datasource`, `depName`, optional `versioning`, and `currentValue`.

Test it on <https://regex101.com> (flavour *ECMAScript*), then with a local dry run.
Expected: 7 dependencies found by your manager (Renovate image ×4, the `renovate` npm
package in `ci.yml`, Dagger CLI ×2), plus EKS once you've done 7.3. (The report lists `uv`
from 7.1 under the same `regex` manager: presets are regex managers too.)

> Renovate has presets for some of these too (`customManagers:githubActionsVersions`,
> `customManagers:azurePipelinesVersions`, …). Writing your own once is how you learn to
> debug them.

<details><summary>Hint: a regex to start from</summary>

```text
#\s*renovate:\s*datasource=(?<datasource>\S+)\s+depName=(?<depName>\S+)(\s+versioning=(?<versioning>\S+))?\s*\n\s*-?\s*[\w.-]+\s*[:=]\s*["']?(?<currentValue>[^"'\s]+)["']?
```

In JSON every `\` doubles: `\\s`, `\\S`, `\\n`.
</details>

> **Gotcha**: with `config:best-practices`, Renovate wants to pin Docker digests. A regex that doesn't
> capture `currentDigest` can't write one back, so add a rule
> `{ "matchManagers": ["custom.regex"], "pinDigests": false }`.

## 7.2 Custom datasources: teach Renovate where to *look*

A custom datasource fetches a URL and turns the response into Renovate's release format
`{ "releases": [{ "version": "1.2.3", "releaseTimestamp": "…", "isDeprecated": false }] }`
using [JSONata](https://jsonata.org) `transformTemplates`. Formats: `json` (default),
`yaml`, `toml`, `plain` (one version per line), `html` (links on a page).

```json
"customDatasources": {
  "endoflife": {
    "defaultRegistryUrlTemplate": "https://endoflife.date/api/{{packageName}}.json",
    "transformTemplates": [
      "{ \"releases\": $map($, function($v) { { \"version\": $v.cycle, \"releaseTimestamp\": $v.releaseDate, \"isDeprecated\": $type($v.eol) = \"string\" and $toMillis($v.eol) < $millis() } }) }"
    ]
  }
}
```

Use it as datasource `custom.endoflife`.

Typical real-world uses:

- An **internal "golden versions" API** or a JSON file in S3 listing approved base images / runtimes.
- A vendor that publishes versions on a web page or in a plain-text file only.
- **Platform versions** with a lifecycle: Kubernetes/EKS/AKS, PostgreSQL in RDS, Python on Lambda.

### Exercise 7.3: keep EKS up to date

[`infra/variables.tf`](../infra/variables.tf) already has an annotated `eks_cluster_version = "1.29"`
with `datasource=custom.endoflife depName=amazon-eks versioning=loose`.

1. Add the `endoflife` custom datasource above to `renovate.json`.
2. Make sure your custom manager from 7.2 also scans `*.tf`.
3. Dry-run. Renovate should propose the newest EKS version.
4. Bonus: open <https://endoflife.date/api/amazon-eks.json> and try the transform in the
   [JSONata exerciser](https://try.jsonata.org). Add `"changelogUrl": $v.link` to get a link in the PR.

> Renovate also has a **built-in** `endoflife-date` datasource. We use a custom one here to learn
> the mechanism, which works for *any* JSON/YAML/plain-text endpoint, including internal ones.

Solution: [solutions/07-custom-managers.json](solutions/07-custom-managers.json) +
[solutions/Dockerfile](solutions/Dockerfile).

## 7.3 Beyond regex

- **JSONata custom managers** (`customType: "jsonata"`) query JSON/YAML/TOML files structurally
  instead of with regexes, e.g. a `versions.json` your build reads.
- **`postUpgradeTasks`** run commands after an update (regenerate code, re-render docs).
  Only commands listed in the **global** `allowedCommands` may run: the bot admin decides,
  not the repository.
- Something that should exist for everyone? Upstream it: managers and datasources are
  regular TypeScript modules in the Renovate repo.
