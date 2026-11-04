# 5. Lab: automerge by semantic version and package name

Reviewing 40 patch bumps a month by hand isn't review, it's clicking.
Automerge the boring updates, so humans have time for the risky ones.

## 5.1 Automerge is only as safe as your tests

Renovate automerges a PR **only when all status checks are green**. So:

1. You need checks: here, [`.github/workflows/ci.yml`](../.github/workflows/ci.yml)
   installs exactly what's in the lock files and smoke-tests imports.
2. Those checks must be **required**, or a PR with *no checks yet* looks mergeable.
   [`terraform/github`](../terraform/github/main.tf) creates a ruleset that requires
   `backend`, `frontend`, `terraform` and `renovate-config`, and enables *Allow auto-merge*.
3. With `platformAutomerge: true` (default) Renovate turns on the **platform's own**
   auto-merge (GitHub auto-merge, GitLab "merge when pipeline succeeds", Azure DevOps
   auto-complete, …). The platform merges the moment checks pass, no need to wait for the next Renovate run.

| `automergeType` | What happens |
|-----------------|--------------|
| `pr` (default) | PR is opened, merged when green. Visible, traceable. |
| `branch` | No PR at all: Renovate pushes a branch, waits for green checks, merges it directly into `main` (a later run does the merge). Zero noise, but needs push rights to `main` (not compatible with "require PR" rules unless Renovate can bypass them). |

## 5.2 Semantic versioning, and where it lies

`matchUpdateTypes` classifies each update with the dependency's **versioning** scheme:

| updateType | Meaning (semver) | Example from this repo |
|------------|------------------|------------------------|
| `patch` | bug fixes | `prettier 2.8.0 → 2.8.8` |
| `minor` | new features, backwards compatible | `requests 2.28.0 → 2.34.2` |
| `major` | breaking changes | `pydantic 1.10.7 → 2.x` |
| `pin`, `digest`, `pinDigest` | same version, made explicit/immutable | `node:18 → node:18@sha256:…` |
| `lockFileMaintenance` | refresh transitive deps in the lock file | `uv.lock`, `bun.lock` |

Where the label lies, and you need a rule:

- **0.x versions**: semver §4 says *anything may change* before 1.0. `axios 0.27 → 0.35`
  and `fastapi 0.95 → 0.162` are "minor" but break things. Match them with
  `matchCurrentVersion: "/^(==)?v?0\\./"`.
- **Docker tags** aren't semver. `python:3.10 → 3.15` is "minor" by tag, but a new
  CPython minor drops deprecated APIs and breaks binary wheels.
- **Packages that don't follow semver at all** (some cloud SDKs, CalVer projects): use
  `matchPackageNames` to opt them out, or `separateMinorPatch`/`versioning` overrides.

## 5.3 Exercise

Extend your `renovate.json` (from module 4) so that:

1. **minor + patch** updates of **stable (≥ 1.0)** dependencies automerge.
2. For **0.x** dependencies, only **patch** updates automerge.
3. **lock file maintenance**, pins and digest updates automerge **without a PR** (`automergeType: "branch"`), weekly on Monday morning.
4. Anything in **`@types/**`** automerges, even majors.
5. The **React/Next.js** group never automerges, whatever the update type.
6. **`python` and `node` base images**: minor and major updates never automerge.
7. **Terraform providers and Helm charts** never automerge, and their **majors** only get a PR
   after someone approves them in the Dependency Dashboard.
8. Ignore releases younger than **3 days**.

Expected result, so you can check yourself:

| Dependency | Current | Update | Automerge? | Why |
|------------|---------|--------|------------|-----|
| zod | 3.19.0 | minor | ✅ | rule 1 |
| requests | ==2.28.0 | minor | ✅ | rule 1 (PEP 440 `==` prefix!) |
| axios | 0.27.0 | minor | ❌ | 0.x |
| axios | 0.27.0 | patch | ✅ | rule 2 |
| python-dotenv | ==0.21.0 | patch | ✅ | rule 2 |
| @types/node | 18.0.0 | **major** | ✅ | rule 4 |
| @types/react | 18.0.0 | minor | ❌ | rule 5 comes **after** rule 4 and wins |
| next | 13.0.0 | minor | ❌ | rule 5 |
| python (docker) | 3.10.0-slim | minor | ❌ | rule 6 |
| random (terraform) | 3.5.0 | minor | ❌ | rule 7 |
| aws (terraform) | 5.20.0 | major | ❌, needs dashboard approval | rule 7 |
| lock files | – | lockFileMaintenance | ✅ as branch | rule 3 |

<details><summary>Hints</summary>

- `packageRules` are applied **in order**; for the same option, the **last** matching rule wins.
  Put broad rules first, exceptions last.
- All `match*` conditions in one rule must match (AND). Values inside one `match*` array are OR.
- `matchCurrentVersion` takes a semver range or a `/regex/`; with a regex it's matched against the
  *current value* as written in the file, so Python's `==0.95.0` needs `(==)?`.
- `lockFileMaintenance` is its own config object: `"lockFileMaintenance": { "enabled": true, ... }`.
- Package rules can be tested without a git host: run module 2's dry run with `LOG_LEVEL=debug`.
</details>

Solution: [solutions/05-automerge.json](solutions/05-automerge.json)

## 5.4 See it happen

Commit, push, run the Renovate workflow. Then:

- PRs for `requests` / `zod`: the PR body says **"Automerge: Enabled"**, GitHub shows
  *auto-merge enabled*. They merge once CI is green.
- PR for `next`: "Automerge: Disabled by config", waiting for you.
- Dependency Dashboard: section **"Pending Approval"** lists the Terraform/Helm majors.
- Break something on purpose: in the `uvicorn` PR's branch, push a commit that makes
  `ci.yml`'s backend smoke test fail. Renovate won't merge it, and since the branch was
  modified by someone else, Renovate stops touching it ("edited/blocked").

## 5.5 Discuss

- Would you automerge on a **library** the same way as on an **application**?
  (Libraries: widen ranges with `rangeStrategy: "widen"`/`"bump"` and keep majors manual.)
- Who gets notified when an automerged update breaks production? Consider
  `automergeSchedule` (only merge during office hours) and `minimumReleaseAge`.
