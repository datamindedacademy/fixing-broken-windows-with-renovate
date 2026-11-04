# 4. Lab: taming the noise

A first Renovate run on a neglected repo is a PR avalanche. Teams that get
30 PRs on day one disable the bot on day two. Let's make it pleasant.

## 4.1 The levers

| Lever | Option | Effect |
|-------|--------|--------|
| When | `schedule`, `timezone` | Only create PRs in a window (`"* 0-8 * * 1-5"` = weekday mornings) |
| How many | `prHourlyLimit`, `prConcurrentLimit` | Cap PR creation rate / open PRs |
| Together | `groupName` in a package rule | One PR for related packages |
| Wait | `minimumReleaseAge` | Ignore versions younger than N days: skips broken/yanked releases **and** most supply-chain attacks, which get detected within days |
| Ask first | `dependencyDashboardApproval` | Only create the PR after someone ticks the box in the dashboard |
| Overview | `:dependencyDashboard` (in `config:recommended`) | One issue listing everything pending, rate-limited, awaiting approval, errored |
| Noise in git | `:semanticCommits`, `labels`, `commitMessagePrefix` | Readable history, filterable PRs |

Presets you'll want to know:

- `config:recommended`: sensible defaults (dashboard, monorepo grouping, ignore `node_modules`, …).
- `config:best-practices`: recommended **plus** pin Docker digests and GitHub Actions to SHAs, pin devDependencies,
  `minimumReleaseAge` for npm, weekly lock file maintenance, config migration PRs, flag abandoned packages.
- `group:monorepos`, `group:allNonMajor`, `schedule:weekly`, `:automergeMinor`, … see the
  [preset docs](https://docs.renovatebot.com/presets-default/).

## 4.2 Exercise

Edit `renovate.json` so that:

1. Renovate only opens PRs on weekday mornings before 09:00 **Brussels time**.
2. At most 5 PRs per hour and 10 open PRs in total.
3. `react`, `react-dom`, their `@types/*` and `next` come in **one** PR.
4. `eslint`, anything starting with `eslint-`, `@typescript-eslint/*` packages and `prettier` come in **one** PR.
5. All non-major Python updates come in **one** PR.
6. Every Renovate PR gets the label `dependencies`; Terraform PRs also get `infra`.

Validate (module 2.3), dry-run locally, commit, push, re-run the workflow.
Watch how Renovate **closes** the now-superseded individual PRs and opens grouped ones.

<details><summary>Hints</summary>

- `matchPackageNames` accepts exact names, globs (`@types/**`, `eslint-*`) and regexes
  (`"/^eslint/"`). Prefix with `!` to exclude.
- Python deps come from the `pep621` manager.
- Adding a label to the labels you already have: `addLabels`.
</details>

Solution: [solutions/04-taming-the-noise.json](solutions/04-taming-the-noise.json)

## 4.3 Discuss

- Grouping reduces PRs, but one bad package now blocks the whole group. Where's the sweet spot?
- `minimumReleaseAge: "3 days"`: what do you gain, what do you lose? (Hint: security fixes. Renovate
  can treat vulnerability fixes separately via `vulnerabilityAlerts` / `osvVulnerabilityAlerts`.)
