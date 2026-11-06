---
layout: values
---

# Before we start, 30 <span class="dm-accent">seconds</span>

<template #badges>
<DmIconBadge icon="i-mdi-account-outline" label="Name" sub="Who are you?" />
<DmIconBadge icon="i-mdi-briefcase-outline" label="Role" sub="What do you build?" tone="dark" />
<DmIconBadge icon="i-mdi-package-variant-closed" label="Dependency" sub="One you fear updating" />
<DmIconBadge icon="i-mdi-robot-outline" label="Bots" sub="Dependabot? Renovate? None?" tone="dark" />
</template>

<!--
Write the "dependency you fear updating" answers on a whiteboard. Come back to them in the
automerge section: which of these would you never automerge, and why?
-->

---
layout: agenda
label: Contents
---

# Contents

1. How Renovate works
2. Lab: a dry run on your laptop
3. Lab: self-hosted Renovate in CI, on a schedule
4. Lab: taming the noise
5. Lab: automerge by semantic version and package name
6. Platforms, datasources and private registries
7. Lab: custom managers and custom datasources
8. Lab: CI-agnostic Renovate with Dagger
9. Rolling out to a whole organisation

<!--
About three hours with two breaks. Every lab has a page in session/ with the steps and a
solution in session/solutions/. Modules 6 to 9 can be demos if time is short.
-->

---
layout: default
label: Setup
---

# What you <span class="dm-accent">need</span>

<DmColumns class="mt-6">
<DmColumn header="Must have" tone="navy">

- A GitHub account
- Docker (or Node.js 24+ and `npx`)
- Your own copy of the repo: **Use this template**
- Issues enabled on that copy

</DmColumn>
<DmColumn header="Nice to have" tone="violet" divider>

- Terraform ≥ 1.11 or OpenTofu
- The Dagger CLI
- `jq`, `gh`

</DmColumn>
</DmColumns>

<DmBanner tone="authentic" icon="i-mdi-alert-outline" title="Don't install the hosted Renovate app" class="mt-6">
We run Renovate ourselves today. Running both gives you every PR twice.
</DmBanner>

<!--
Point to session/00-setup.md. The image pull is about 1 GB: ideally done before the session.
-->
