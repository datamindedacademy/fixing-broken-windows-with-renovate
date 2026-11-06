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
