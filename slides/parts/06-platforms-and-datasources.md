---
layout: section
---

# Platforms, datasources and <span class="dm-accent">private registries</span>

---
layout: default
label: 6 · Platforms
---

# Two kinds of <span class="dm-accent">providers</span>

<DmColumns class="mt-6">
<DmColumn header="Platform" tone="navy">

Where the code lives and PRs are opened.

`github` · `gitlab` · `azure` · `bitbucket` · `bitbucket-server` · `gitea` · `forgejo` · `gerrit` · `local`

</DmColumn>
<DmColumn header="Datasource" tone="violet" divider>

Where new versions come from.

`npm` · `pypi` · `docker` · `helm` · `terraform-provider` · `terraform-module` · `github-releases` · `endoflife-date` · `custom.*`

</DmColumn>
</DmColumns>

<p class="mt-8 text-center">Independent: a CodeBuild job can update a <b>Bitbucket</b> repo whose packages come from <b>CodeArtifact</b> and images from <b>ECR</b>.</p>

---
layout: default
label: 6 · Platforms
---

# Platforms <span class="dm-accent">compared</span>

<table class="dm-table dm-table--dense">
<tbody>
<tr><th style="width: 18%">Platform</th><th style="width: 32%">Token</th><th style="width: 28%">Dependency Dashboard</th><th>Platform automerge</th></tr>
<tr><td>GitHub</td><td>GitHub App or fine-grained PAT</td><td>✅ issue</td><td>✅ auto-merge</td></tr>
<tr><td>GitLab</td><td>Project/group access token, <code>api</code> + <code>write_repository</code></td><td>✅ issue</td><td>✅ merge when pipeline succeeds</td></tr>
<tr><td>Azure DevOps</td><td><code>$(System.AccessToken)</code> or PAT</td><td>✅ Azure Boards work item</td><td>✅ auto-complete</td></tr>
<tr><td>Bitbucket Cloud</td><td>Access token (app passwords deprecated)</td><td>❌ issue tracker removed</td><td>❌ Renovate merges itself</td></tr>
<tr><td>Bitbucket DC</td><td>HTTP access token</td><td>❌</td><td>✅</td></tr>
<tr><td>Gitea / Forgejo</td><td>Access token</td><td>✅</td><td>✅</td></tr>
</tbody>
</table>

<DmBanner tone="authentic" icon="i-mdi-alert-outline" title="Bitbucket Cloud has no dashboard any more" class="mt-4">
So don't use dependencyDashboardApproval there: there is nowhere to approve.
</DmBanner>

<!--
These changed recently: Azure DevOps gained the dashboard as a work item (azureWorkItemType,
default Issue), Bitbucket Cloud lost it when Atlassian removed its issue tracker. Checked
against the Renovate 44 source. Re-check the platform docs for your version.
-->

---
layout: default
label: 6 · Platforms
---

# Private registries: <span class="dm-accent">hostRules</span>

<DmColumns class="mt-2" :gap="24">
<DmColumn tone="plain" class="col-w2">

<div class="small-code">

```js
// global config.js, never renovate.json
hostRules: [
  { matchHost: 'pkgs.dev.azure.com', hostType: 'npm',
    token: process.env.AZURE_ARTIFACTS_TOKEN },
  { matchHost: 'artifactory.example.com',
    username: 'renovate',
    password: process.env.ARTIFACTORY_TOKEN },
  { matchHost: 'app.terraform.io',
    token: process.env.TFC_TOKEN },
]
```

</div>

</DmColumn>
<DmColumn tone="plain" divider class="col-w1">

- Matched by **host**
- Or as JSON in `RENOVATE_HOST_RULES`
- Mirrors: `registryUrls` in a package rule
- **Short-lived** credentials (CodeArtifact, Artifact Registry): mint them in the CI job right before Renovate runs

</DmColumn>
</DmColumns>

<!--
That last point is one of the strongest reasons to self-host in CI. See the commented
CodeArtifact block in ci-templates/aws-codebuild/buildspec.yml.
-->

---
layout: default
label: 6 · Platforms
---

# Terraform providers <span class="dm-accent">in particular</span>

- The `terraform` manager handles `required_providers`, `module` sources and `required_version`
- **Commit `.terraform.lock.hcl`**: Renovate then updates provider *hashes* too. This repo ignores it on purpose, so Renovate can only bump the constraint.
- Private providers and modules: `registryUrls` + a `hostRules` token
- OpenTofu: point `registryUrls` at `registry.opentofu.org`

---
layout: statement
---

# Demo

<div class="ex-grid ex-grid--single">
<div class="ex-item">
<p class="ex-name">CodeBuild → GitLab</p>
<p class="ex-desc">Renovate on AWS CodeBuild updating a GitLab project, with JSON logs in CloudWatch Logs Insights</p>
<p class="exercise-path"><code>terraform/aws-codebuild</code></p>
</div>
</div>
