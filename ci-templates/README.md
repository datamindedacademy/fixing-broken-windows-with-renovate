# CI templates

Copy-paste Renovate jobs. Every template runs the **official Renovate image**
(it installs `uv`, `bun`, `helm`, `terraform`, … on demand to update lock files),
runs **on a schedule**, never runs **twice at once**, and reads its token from the
CI system's **secret store**.

| CI system | Template | Schedule lives in | Token | Infra |
|-----------|----------|-------------------|-------|-------|
| GitHub Actions | [github-actions/renovate.yml](github-actions/renovate.yml) | `on.schedule` in the workflow | GitHub App via `actions/create-github-app-token` | [terraform/github](../terraform/github) |
| GitLab CI | [gitlab-ci/.gitlab-ci.yml](gitlab-ci/.gitlab-ci.yml) | Pipeline schedule (UI/API) | Project/group access token in a masked variable | [terraform/gitlab](../terraform/gitlab) |
| Azure Pipelines | [azure-devops/azure-pipelines.yml](azure-devops/azure-pipelines.yml) | `schedules:` in the YAML | `$(System.AccessToken)` | [terraform/azure-devops](../terraform/azure-devops) |
| Bitbucket Pipelines | [bitbucket/bitbucket-pipelines.yml](bitbucket/bitbucket-pipelines.yml) | Pipeline schedule (UI/API) on a custom pipeline | Access token in a secured variable | [terraform/bitbucket](../terraform/bitbucket) |
| AWS CodeBuild | [aws-codebuild/buildspec.yml](aws-codebuild/buildspec.yml) | EventBridge Scheduler | Secrets Manager | [terraform/aws-codebuild](../terraform/aws-codebuild) |
| Any (Docker + Dagger) | [dagger/](dagger/) | your CI's scheduler | your CI's secret store | – |

[`config.js`](config.js) is an example **global** config (bot-level settings such as
`onboardingConfig` and `hostRules`), read by the GitHub Actions template via
`configurationFile`. The other templates pass the same settings as `RENOVATE_*`
env vars; mount or check out a `config.js` and set `RENOVATE_CONFIG_FILE` to use a file instead.

## Keeping the templates themselves up to date

The `gitlabci` and `bitbucket-pipelines` managers detect the `image:` tag natively.
Everywhere else the version is annotated:

```yaml
# renovate: datasource=docker depName=ghcr.io/renovatebot/renovate
RENOVATE_VERSION: "44.210.2"
```

and a regex custom manager (see [module 7](../session/07-custom-managers-and-datasources.md)
and [solutions/renovate.json](../session/solutions/renovate.json)) bumps it.
