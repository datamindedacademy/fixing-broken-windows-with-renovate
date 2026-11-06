---
layout: section
---

# Rolling out to a whole <span class="dm-accent">organisation</span>

---
layout: default
label: 9 · Rolling out
---

# One bot, <span class="dm-accent">many repositories</span>

<DmSteps dir="horizontal" class="mt-6">
<DmStep :n="1" label="Runner repo">

The CI job, the global `config.js` and its Terraform. Owned by the platform team.

</DmStep>
<DmStep :n="2" label="Autodiscover">

`my-org/*`, minus `!my-org/legacy-*`. With a GitHub App, "installed on" is the filter.

</DmStep>
<DmStep :n="3" label="Onboarding">

Teams opt in by merging the onboarding PR. `requireConfig` keeps the bot out until then.

</DmStep>
</DmSteps>

<p class="mt-6 text-center opacity-80">Big org? Shard runs by filter and set <code>executionTimeout</code>, so one slow repo doesn't hold up the rest.</p>

---
layout: default
label: 9 · Rolling out
---

# Policy as code: <span class="dm-accent">shared presets</span>

<DmColumns class="mt-2" :gap="24">
<DmColumn header="my-org/renovate-config: default.json" tone="navy" class="col-w2">

<div class="small-code">

```json
{
  "extends": ["config:best-practices",
    ":timezone(Europe/Brussels)",
    "customManagers:dockerfileVersions"],
  "schedule": ["* 0-8 * * 1-5"],
  "minimumReleaseAge": "3 days",
  "packageRules": [{
    "matchUpdateTypes": ["minor", "patch"],
    "matchCurrentVersion": "!/^(==)?v?0\\./",
    "automerge": true }]
}
```

</div>

</DmColumn>
<DmColumn header="Every repo: renovate.json" tone="violet" divider class="col-w1">

```json
{ "extends": [
  "local>my-org/renovate-config"
] }
```

- `local>` works on every platform
- `:python` reads `python.json`
- `#v2` pins a tagged version

</DmColumn>
</DmColumns>

---
layout: default
label: 9 · Rolling out
---

# Keep the bot <span class="dm-accent">healthy</span>

<DmColumns class="mt-4" :gap="16">
<DmColumn tone="plain">

<DmInfoCard icon="i-mdi-update" title="Renovate updates Renovate" iconTone="violet">

Several releases a day: pin the full version, automerge its minors and patches.

</DmInfoCard>

<DmInfoCard icon="i-mdi-text-box-search-outline" title="Watch the logs" iconTone="navy" class="mt-4">

`LOG_FORMAT=json`, alert on errors and on timed-out runs.

</DmInfoCard>

</DmColumn>
<DmColumn tone="plain">

<DmInfoCard icon="i-mdi-view-dashboard-outline" title="The dashboard is the inbox" iconTone="navy">

Errors, rate-limited and pending-approval updates show up there.

</DmInfoCard>

<DmInfoCard icon="i-mdi-key-chain" title="Token hygiene" iconTone="violet" class="mt-4">

App tokens per run, rotation for the rest, never in a repo.

</DmInfoCard>

</DmColumn>
</DmColumns>

---
layout: default
label: Wrap-up
---

# Take-<span class="dm-accent">aways</span>

<div class="dm-recap mt-4">

1. Run Renovate **often**, from **your own CI**: you control secrets, network and version.
2. **Two schedules**: the cron decides when the bot runs, `schedule` when it may open PRs.
3. **Automerge** what your tests can vouch for. Semver labels lie for 0.x and Docker tags.
4. A **custom manager** finds what Renovate can't see, a **custom datasource** looks it up.
5. Put the policy in a **shared preset**. Repos just `extends` it.

</div>

<!--
Go back to the whiteboard from the intro: which of the feared dependencies would you now
automerge, which would you group, which need a dashboard approval?
-->

---
layout: thanks
---

# Thank <span class="dm-accent">you</span>
