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
