# 1. How Renovate works

## The problem

Every dependency you don't update gets more expensive to update later:

- **Security**: CVEs are fixed in new versions, rarely backported to the one you run.
- **Compound interest**: `next 13 → 16` is three breaking migrations at once.
  `13 → 14` on release day is one.
- **Bus factor**: "who knows why we're stuck on pydantic 1?" Nobody, after a year.

Small, frequent, automated, tested updates are cheap. That's Renovate's job.

## One run of Renovate

```text
           ┌─────────────── global config (the bot) ───────────────┐
           │ platform, token, which repos, host rules, allowed cmds  │
           └───────────────────────────┬────────────────────────────┘
                                       │ for each repository
  clone ─► read renovate.json ─► EXTRACT ─► LOOK UP ─► FILTER ─► BRANCH/PR ─► AUTOMERGE?
           (+ presets)          managers    datasources  packageRules  update files,  if checks green
                                find deps   find new     schedule,     lock files,    and rules allow
                                in files    versions     grouping      changelogs
```

| Concept | What | Examples |
|---------|------|----------|
| **Platform** | Where the code lives, where PRs are opened | `github`, `gitlab`, `azure`, `bitbucket`, `bitbucket-server`, `gitea`, `forgejo`, `local` |
| **Manager** | Knows a *file format* and extracts dependencies from it | `npm`, `bun`, `pep621`, `dockerfile`, `terraform`, `helmv3`, `github-actions`, `custom.regex` |
| **Datasource** | Knows a *registry* and lists available versions | `npm`, `pypi`, `docker`, `terraform-provider`, `helm`, `github-releases`, `custom.*` |
| **Versioning** | Knows how to compare/classify versions | `semver`, `npm`, `pep440`, `docker`, `hashicorp`, `loose`, `regex:...` |
| **Preset** | Reusable chunk of config | `config:recommended`, `config:best-practices`, `github>my-org/renovate-config` |
| **packageRules** | "for deps matching X, set Y". Evaluated top to bottom, **later rules win** | `matchUpdateTypes`, `matchPackageNames`, `matchManagers`, `matchDepTypes` |

## Ways to run Renovate

| Option | Who runs the bot | Good for |
|--------|------------------|----------|
| Mend Renovate **Community Cloud** (GitHub App) | Mend | Public/small GitHub orgs, zero ops |
| **Self-hosted in CI** (this session) | You, as a scheduled pipeline | Any platform, private registries, network access to internal systems, full control over versions and secrets |
| Mend Renovate **Self-hosted CE/EE** | You, as a long-running server with webhooks | Large orgs that want instant reactions to events and a job queue |

Self-hosting in CI is the sweet spot for most teams: no server to run, the CI
system gives you scheduling, secrets, logs and network access for free.

## Two config layers: don't mix them up

| | Global (bot) config | Repository config |
|-|---------------------|-------------------|
| **Where** | CI job: `config.js`, `RENOVATE_*` env vars, CLI flags | `renovate.json` (or `.github/renovate.json5`, `.gitlab/renovate.json`, …) in each repo |
| **Owned by** | Platform team | Repository team |
| **Examples** | `platform`, `token`, `repositories`, `autodiscover`, `hostRules`, `onboardingConfig`, `allowedCommands` | `extends`, `schedule`, `packageRules`, `automerge`, `customManagers` |

Precedence: CLI flag > env var > `config.js` > defaults, then the repository config
is merged on top of that for repository-level options.
