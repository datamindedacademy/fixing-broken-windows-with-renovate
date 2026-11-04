# 9. Rolling out to a whole organisation

One repository is a lab. Two hundred repositories need a few more decisions.

## 9.1 One bot, many repositories

```text
            ┌──────────────── renovate-runner repo (platform team) ────────────────┐
schedule ─► │ CI job + global config.js: autodiscover "my-org/*", hostRules, token  │
            └───────────────────────────────┬──────────────────────────────────────┘
                                            │ for every repo with renovate.json
        ┌───────────────────────┬───────────┴────────────┬────────────────────────┐
     repo A                  repo B                    repo C              renovate-config repo
 { "extends":            { "extends":               (not onboarded:       (shared presets)
   ["local>my-org/         ["local>my-org/           gets an onboarding    default.json
    renovate-config"] }     renovate-config",        PR)                   python.json
                            "local>my-org/                                 terraform.json
                             renovate-config:python"] }
```

- **One runner repo** owned by the platform team: the CI job (templates from module 3),
  the global `config.js`, the Terraform for its secrets and schedule.
- **`autodiscover`** + `autodiscoverFilter` (`my-org/*`, `!my-org/legacy-*`) instead of maintaining a list.
  With a GitHub App, "installed on" = "processed": the install list *is* the filter.
- **Onboarding**: `onboardingConfig` decides what the onboarding PR proposes. Teams opt in
  by merging it. `requireConfig: "required"` keeps Renovate out of repos that haven't.
- Large orgs: shard runs (`autodiscoverFilter` per job, or a matrix in GitHub Actions) so one
  slow repo doesn't delay all others, and set `executionTimeout`.

## 9.2 Shared presets: your organisation's policy as code

Create a repository `my-org/renovate-config` with a `default.json`:

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "description": "My Org defaults: see https://github.com/my-org/renovate-config",
  "extends": ["config:best-practices", ":timezone(Europe/Brussels)", "customManagers:dockerfileVersions"],
  "schedule": ["* 0-8 * * 1-5"],
  "minimumReleaseAge": "3 days",
  "packageRules": [
    { "matchUpdateTypes": ["minor", "patch"], "matchCurrentVersion": "!/^(==)?v?0\\./", "automerge": true }
  ]
}
```

Repositories then only need:

```json
{ "extends": ["local>my-org/renovate-config"] }
```

`local>` means "on the same platform as this repo" and works on GitHub, GitLab,
Azure DevOps, Bitbucket and Gitea. Named presets: `local>my-org/renovate-config:python`
reads `python.json`. Version your presets with tags (`local>my-org/renovate-config#v2`) if
you want controlled rollouts.

Our [module 5](05-automerge.md) and [module 7](07-custom-managers-and-datasources.md) rules are prime
candidates: write them once, every repo benefits.

## 9.3 Keep the bot itself healthy

- **Renovate updates Renovate**: the runner repo's own `renovate.json` keeps the image tag current
  (module 7.2). Renovate releases several times per day; pin the full version and automerge
  minor/patch for it, so the bot never falls behind.
- **Watch the logs**, not just the PRs: `LOG_FORMAT=json` + your log platform; alert on
  `"level":50` (error) and on runs that time out.
- **The Dependency Dashboard** of each repo is the team's inbox: errors, rate-limited and
  pending-approval updates all show up there.
- **Token hygiene**: GitHub App tokens are minted per run (1 h); GitLab/Azure/Bitbucket tokens
  must be rotated (see `rotation_configuration` in [terraform/gitlab](../terraform/gitlab/main.tf)).
  Store them in the CI's secret store or a cloud secret manager, never in a repo.

## 9.4 Infrastructure as code for the runner

Everything you clicked through in module 3 is in [`terraform/`](../terraform/):

| Stack | Creates |
|-------|---------|
| [github](../terraform/github) | Repo settings (auto-merge, issues), ruleset with required checks, App client id + private key for Actions |
| [gitlab](../terraform/gitlab) | Project access token with auto-rotation, masked CI variables, pipeline schedule |
| [azure-devops](../terraform/azure-devops) | Project, imported repo, pipeline, variable group, git permissions for the Build Service |
| [bitbucket](../terraform/bitbucket) | Secured repository variable (write-only, never in state), pipeline schedule for the custom pipeline |
| [aws-codebuild](../terraform/aws-codebuild) | CodeBuild project, EventBridge Scheduler schedule, Secrets Manager secrets, IAM, log group |

## 9.5 Take-aways

1. Run Renovate **often** and from **your own CI**: you control secrets, network and version.
2. **Two schedules**: the CI cron decides when the bot runs, `schedule` decides when it may open PRs.
3. **Automerge** what your tests can vouch for; semver labels lie for 0.x and Docker tags.
4. Anything Renovate can't see, a **custom manager** can find and a **custom datasource** can look up.
5. Put the policy in a **shared preset**; repos just `extends` it.
