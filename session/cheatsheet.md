# Renovate cheat sheet

## Run

```bash
# Dry run on the current directory (no token, no platform)
docker run --rm -v "$PWD:/usr/src/app:ro" -w /usr/src/app ghcr.io/renovatebot/renovate:44 renovate --platform=local

# Validate config
docker run --rm -v "$PWD:/usr/src/app:ro" -w /usr/src/app ghcr.io/renovatebot/renovate:44 renovate-config-validator --strict

# Real run, one repo, nothing pushed
docker run --rm -e RENOVATE_TOKEN -e LOG_LEVEL=debug ghcr.io/renovatebot/renovate:44 \
  renovate --platform=github --dry-run=full my-org/my-repo

# Same, via Dagger
dagger call -m ./dagger run --token=env://RENOVATE_TOKEN --repositories=my-org/my-repo --dry-run=full
```

## Global (bot) options: env vars

| Env var | Example |
|---------|---------|
| `RENOVATE_PLATFORM` | `github`, `gitlab`, `azure`, `bitbucket`, `bitbucket-server`, `gitea`, `forgejo` |
| `RENOVATE_ENDPOINT` | `https://gitlab.example.com/api/v4/`, `https://dev.azure.com/my-org/` |
| `RENOVATE_TOKEN` | platform token |
| `RENOVATE_GITHUB_COM_TOKEN` | read-only github.com token (release notes, rate limits) |
| `RENOVATE_REPOSITORIES` | `org/a,org/b` |
| `RENOVATE_AUTODISCOVER` / `_FILTER` | `true` / `org/*` |
| `RENOVATE_ONBOARDING_CONFIG` | `{"extends":["local>org/renovate-config"]}` |
| `RENOVATE_HOST_RULES` | `[{"matchHost":"npm.example.com","token":"..."}]` |
| `RENOVATE_DRY_RUN` | `extract`, `lookup`, `full` |
| `RENOVATE_REPOSITORY_CACHE` | `enabled` |
| `LOG_LEVEL` / `LOG_FORMAT` | `debug` / `json` |

## Repository config: the 20 % you use 80 % of the time

```jsonc
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": ["config:best-practices"],          // or "local>my-org/renovate-config"
  "timezone": "Europe/Brussels",
  "schedule": ["* 0-8 * * 1-5"],                 // when PRs may be created
  "minimumReleaseAge": "3 days",                 // let releases settle
  "prConcurrentLimit": 10, "prHourlyLimit": 5,
  "lockFileMaintenance": { "enabled": true, "automerge": true },
  "packageRules": [                               // top to bottom, last match wins
    { "matchUpdateTypes": ["minor", "patch"], "matchCurrentVersion": "!/^(==)?v?0\\./", "automerge": true },
    { "matchPackageNames": ["@types/**"], "automerge": true },
    { "matchPackageNames": ["react", "react-dom", "next"], "groupName": "react", "automerge": false },
    { "matchManagers": ["terraform"], "matchUpdateTypes": ["major"], "dependencyDashboardApproval": true },
    { "matchDatasources": ["docker"], "matchPackageNames": ["python"], "allowedVersions": "<3.14" },
    { "matchPackageNames": ["some-abandoned-lib"], "enabled": false }
  ]
}
```

## `match*` selectors

| Selector | Matches | Example |
|----------|---------|---------|
| `matchPackageNames` | package name: exact, glob, `/regex/`, `!negation` | `["@aws-sdk/**", "!@aws-sdk/legacy"]` |
| `matchDepNames` | dependency name as written in the file | `["python"]` |
| `matchUpdateTypes` | `major` `minor` `patch` `pin` `digest` `pinDigest` `lockFileMaintenance` `rollback` `bump` `replacement` | `["minor","patch"]` |
| `matchCurrentVersion` | current version: range or `/regex/` | `"< 1.0.0"`, `"/^0\\./"` |
| `matchManagers` | manager | `["terraform", "custom.regex"]` |
| `matchDatasources` | datasource | `["docker"]` |
| `matchDepTypes` | dependency type | `["devDependencies"]`, `["required_provider"]` |
| `matchFileNames` | package file path (glob) | `["infra/**"]` |
| `matchCurrentAge` | age of the current release | `"> 1 year"` |
| `matchJsonata` | anything, as a JSONata expression | `["$exists(isVulnerabilityAlert)"]` |

## Custom manager template

```json
{
  "customType": "regex",
  "managerFilePatterns": ["/(^|/)buildspec\\.ya?ml$/"],
  "matchStrings": [
    "#\\s*renovate:\\s*datasource=(?<datasource>\\S+)\\s+depName=(?<depName>\\S+)(\\s+versioning=(?<versioning>\\S+))?\\s*\\n\\s*-?\\s*[\\w.-]+\\s*[:=]\\s*[\"']?(?<currentValue>[^\"'\\s]+)[\"']?"
  ]
}
```

## Debugging

- **No PRs?** Check the job ran inside the `schedule` window, `prConcurrentLimit`, and the Dependency Dashboard "Rate-limited" section.
- **Not automerging?** Required checks green? Repo allows auto-merge? Branch modified by a human? PR body says why.
- **Dependency not found?** `LOG_LEVEL=debug`, search for `packageFiles with updates`; is the file matched by the manager's `managerFilePatterns`?
- **Lock file not updated?** Use the official image (installs tools on demand), check `artifact errors` in the PR.
- **Rate-limited by github.com?** Set `RENOVATE_GITHUB_COM_TOKEN`.
