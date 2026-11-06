---
layout: default
label: 1 · How Renovate works
---

# Why update <span class="dm-accent">often</span>?

<DmImpact class="mt-6">
<DmImpactRow icon="i-mdi-shield-alert-outline" label="Security">

CVEs get fixed in new versions. They are rarely backported to the version you happen to run.

</DmImpactRow>
<DmImpactRow icon="i-mdi-chart-line-variant" label="Compound interest">

`next 13 → 16` is three breaking migrations at once. `13 → 14` on release day is one.

</DmImpactRow>
<DmImpactRow icon="i-mdi-account-question-outline" label="Bus factor">

"Why are we stuck on pydantic 1?" After a year, nobody remembers.

</DmImpactRow>
</DmImpact>

---
layout: default
label: 1 · How Renovate works
---

# One run of <span class="dm-accent">Renovate</span>

<DmProcess class="mt-8">
<DmPhase label="Clone" />
<DmPhase label="Extract" />
<DmPhase label="Look up" />
<DmPhase label="Filter" />
<DmPhase label="Branch + PR" />
<DmPhase label="Automerge?" />
</DmProcess>

<table class="dm-table mt-8">
<tbody>
<tr><th style="width: 22%">Extract</th><td><b>Managers</b> find dependencies in files: <code>bun</code>, <code>pep621</code>, <code>dockerfile</code>, <code>terraform</code>, <code>helmv3</code></td></tr>
<tr><th>Look up</th><td><b>Datasources</b> list versions in registries: <code>npm</code>, <code>pypi</code>, <code>docker</code>, <code>terraform-provider</code></td></tr>
<tr><th>Filter</th><td><b>packageRules</b>, <code>schedule</code>, limits, grouping decide what happens</td></tr>
<tr><th>Branch + PR</th><td>Update files <i>and</i> lock files, add release notes, open the PR</td></tr>
</tbody>
</table>

<!--
Platform: where the code lives (GitHub, GitLab, Azure DevOps, Bitbucket).
Manager: knows a file format. Datasource: knows a registry. Versioning: knows how to compare.
-->

---
layout: default
label: 1 · How Renovate works
---

# Two config layers, don't <span class="dm-accent">mix them up</span>

<DmColumns class="mt-6">
<DmColumn header="Global: the bot" tone="navy">

- Lives with the **runner**: `config.js`, `RENOVATE_*` env vars, CLI flags
- Owned by the platform team
- `platform`, `token`, `repositories`, `autodiscover`, `hostRules`, `onboardingConfig`, `allowedCommands`

</DmColumn>
<DmColumn header="Repository: the rules" tone="violet" divider>

- Lives in **each repo**: `renovate.json`
- Owned by the repo team
- `extends`, `schedule`, `packageRules`, `automerge`, `customManagers`

</DmColumn>
</DmColumns>

<p class="mt-6 text-sm opacity-70 text-center">Precedence: CLI flag &gt; env var &gt; <code>config.js</code> &gt; defaults, then the repository config on top.</p>

<!--
Secrets never go in renovate.json. hostRules with tokens belong in the global config.
-->
