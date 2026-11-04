# 6. Platforms, datasources and private registries

Renovate talks to two kinds of "providers":

- **Platforms**: where your code lives and PRs are opened.
- **Datasources**: where new versions come from (registries).

They're independent. A CodeBuild job can update a Bitbucket repository whose
Python packages come from CodeArtifact and whose base images come from ECR.

## 6.1 Platforms

| Platform | `RENOVATE_PLATFORM` | `RENOVATE_ENDPOINT` | Token | Dependency Dashboard | Platform automerge |
|----------|---------------------|---------------------|-------|----------------------|--------------------|
| GitHub.com / GHES | `github` | – / `https://ghe.example.com/api/v3/` | GitHub App installation token (preferred) or fine-grained PAT | ✅ (issues) | ✅ auto-merge |
| GitLab.com / self-managed | `gitlab` | – / `https://gitlab.example.com/api/v4/` | Project/group access token or bot PAT: `api`, `write_repository` | ✅ (issues) | ✅ merge when pipeline succeeds |
| Azure DevOps | `azure` | `https://dev.azure.com/<org>/` | `$(System.AccessToken)` or PAT | ✅ as an Azure Boards work item (`azureWorkItemType`, default `Issue`) | ✅ auto-complete |
| Bitbucket Cloud | `bitbucket` | – | Repository/workspace access token (app passwords are deprecated) | ❌ (Bitbucket removed its issue tracker) | ❌ (Renovate merges itself when green) |
| Bitbucket Data Center | `bitbucket-server` | `https://bitbucket.example.com` | HTTP access token | ❌ | ✅ |
| Gitea / Forgejo | `gitea` / `forgejo` | `https://gitea.example.com/api/v1/` | Access token | ✅ | ✅ |
| Gerrit | `gerrit` | `https://gerrit.example.com/` | HTTP password | ❌ | see docs |
| Local directory | `local` | – | – | – | – (dry run only) |

The feature matrix shifts between Renovate versions: check the
[platform docs](https://docs.renovatebot.com/modules/platform/) for your version.

Platform-specific things that bite:

- **GitHub**: `GITHUB_TOKEN` doesn't trigger workflows → use a GitHub App. Commits made
  with an App token through the API are signed/"Verified" (`platformCommit`).
- **GitLab**: tokens must expire → rotate them (see `rotation_configuration` in
  [terraform/gitlab](../terraform/gitlab/main.tf)). Protected-branch rules decide whether
  the bot's role can merge.
- **Azure DevOps**: secrets must be mapped to env explicitly; the *Build Service* identity
  needs Contribute / Create branch / Contribute to PRs on each repo
  ([terraform/azure-devops](../terraform/azure-devops/main.tf)). The Dependency Dashboard is
  a work item in Azure Boards, so Boards must be enabled and the identity must be allowed to create
  work items.
- **Bitbucket Cloud**: no issue tracker any more, so **no Dependency Dashboard**. Don't use
  `dependencyDashboardApproval` there: there's nowhere to approve! Schedules are 7-field cron in UTC.

## 6.2 Datasources: where versions come from

Every dependency has a `datasource` (+ `packageName`, `registryUrls`, `versioning`).
Usually the manager sets these for you. You override them in `packageRules`:

```json
{
  "packageRules": [
    {
      "description": "Use our Artifactory mirror for all npm packages",
      "matchDatasources": ["npm"],
      "registryUrls": ["https://artifactory.example.com/api/npm/npm-remote/"]
    },
    {
      "description": "Terraform modules from our private registry",
      "matchDatasources": ["terraform-module", "terraform-provider"],
      "registryUrls": ["https://app.terraform.io"]
    }
  ]
}
```

Frequently used datasources: `npm`, `pypi`, `maven`, `nuget`, `go`, `docker`,
`helm`, `terraform-provider`, `terraform-module`, `github-releases`,
`github-tags`, `gitlab-releases`, `git-tags`, `endoflife-date`,
`aws-machine-image`, `azure-pipelines-tasks`, `custom.*` (module 7).

## 6.3 Private registries: `hostRules`

Credentials go in **`hostRules`**, matched by host. Put them in the **global**
config (CI job), not in `renovate.json`, so secrets never live in a repository:

```js
// ci-templates/config.js
hostRules: [
  { matchHost: 'pkgs.dev.azure.com', hostType: 'npm', token: process.env.AZURE_ARTIFACTS_TOKEN },
  { matchHost: 'artifactory.example.com', username: 'renovate', password: process.env.ARTIFACTORY_TOKEN },
  { matchHost: 'app.terraform.io', token: process.env.TFC_TOKEN },
  { matchHost: '123456789012.dkr.ecr.eu-west-1.amazonaws.com', hostType: 'docker',
    username: process.env.AWS_ACCESS_KEY_ID, password: process.env.AWS_SECRET_ACCESS_KEY },
]
```

…or as JSON in an env var: `RENOVATE_HOST_RULES='[{"matchHost": "...", "token": "..."}]'`.

Short-lived credentials (AWS CodeArtifact, GCP Artifact Registry, Azure AD) can't be
refreshed by Renovate itself: **mint them in the CI job right before Renovate runs**,
see the commented CodeArtifact example in the [CodeBuild buildspec](../ci-templates/aws-codebuild/buildspec.yml).
This is one of the biggest reasons to self-host in CI.

> Hosted Mend app instead of self-hosted? Then secrets in `renovate.json` must be
> [encrypted](https://docs.renovatebot.com/getting-started/private-packages/) with Mend's public key.

## 6.4 Terraform providers in particular

The patient's `infra/main.tf` pins `hashicorp/aws 5.20.0`. Things to know:

- The `terraform` manager handles `required_providers`, `module` sources (registry, git,
  GitHub), `required_version` and some resources (`docker_image`, `helm_release`, …).
- **Commit `.terraform.lock.hcl`!** Renovate updates provider hashes in the lock file
  (it needs to `terraform init`, the Renovate image installs Terraform on demand). This
  repo's `.gitignore` excludes lock files: with it, Renovate can only bump the constraint.
- Private providers/modules: `registryUrls` + a `hostRules` token for the registry host.
- OpenTofu? Renovate looks up providers on `registry.terraform.io` by default; point it at
  `registry.opentofu.org` with `registryUrls` if that's what you use.

## 6.5 Demo

The facilitator shows `terraform/aws-codebuild` running Renovate against a
GitLab project, with no GitHub involved, and the CloudWatch logs (`LOG_FORMAT=json`)
queried with Logs Insights:

```text
fields @timestamp, msg, repository, branch
| filter level >= 40   # warn and above
| sort @timestamp desc
```
