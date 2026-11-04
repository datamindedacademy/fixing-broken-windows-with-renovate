# 3. Lab: self-hosted Renovate in CI, on a schedule

Goal: Renovate runs every weekday from **your** CI, opens an onboarding PR and
then update PRs on your repository.

## 3.1 The anatomy of every Renovate CI job

Whatever the CI system, a Renovate job is always the same five things:

| Ingredient | How |
|------------|-----|
| **Trigger** | A cron schedule (+ a manual "run now" button) |
| **Runtime** | The official image `ghcr.io/renovatebot/renovate:<version>`. It installs `uv`, `bun`, `helm`, … on demand to update lock files. Running plain `npx renovate` can't do that unless those tools are already installed. |
| **Identity** | A token for the platform with rights to push branches, open PRs and (for the dashboard) issues |
| **Targets** | `RENOVATE_REPOSITORIES=org/a,org/b` or `RENOVATE_AUTODISCOVER=true` + `RENOVATE_AUTODISCOVER_FILTER` |
| **Mutual exclusion** | Never two runs at once: `concurrency` (GHA), `resource_group` (GitLab), `concurrent_build_limit` (CodeBuild) |

Plus one strongly recommended extra: a **read-only github.com token**
(`RENOVATE_GITHUB_COM_TOKEN`) even if you're not on GitHub. Renovate fetches
release notes and many versions (GitHub releases/tags) from github.com, and
anonymous API calls are rate-limited to 60/hour.

### Templates per CI system

| CI | Template | Infra as code | Notes |
|----|----------|---------------|-------|
| GitHub Actions | [github-actions/renovate.yml](../ci-templates/github-actions/renovate.yml) | [terraform/github](../terraform/github) | Uses `renovatebot/github-action` + a GitHub App token |
| GitLab CI | [gitlab-ci/.gitlab-ci.yml](../ci-templates/gitlab-ci/.gitlab-ci.yml) | [terraform/gitlab](../terraform/gitlab) | Uses the image directly; project access token; pipeline schedule |
| Azure Pipelines | [azure-devops/azure-pipelines.yml](../ci-templates/azure-devops/azure-pipelines.yml) | [terraform/azure-devops](../terraform/azure-devops) | `$(System.AccessToken)` + repo permissions for the build service |
| Bitbucket Pipelines | [bitbucket/bitbucket-pipelines.yml](../ci-templates/bitbucket/bitbucket-pipelines.yml) | [terraform/bitbucket](../terraform/bitbucket) | Custom pipeline + schedule; access token |
| AWS CodeBuild | [aws-codebuild/buildspec.yml](../ci-templates/aws-codebuild/buildspec.yml) | [terraform/aws-codebuild](../terraform/aws-codebuild) | EventBridge Scheduler → CodeBuild; token in Secrets Manager; can target *any* platform |
| Anything with Docker | [dagger/](../ci-templates/dagger/) | – | Module 8 |

## 3.2 Exercise: GitHub Actions

### Step 1: create a GitHub App (the bot's identity)

Why not the built-in `GITHUB_TOKEN`? **PRs opened with `GITHUB_TOKEN` don't
trigger workflows**, so CI never runs on Renovate PRs and automerge (module 5)
waits forever. A PAT works too, but is tied to a person and has broad access.

1. Go to *Settings → Developer settings → GitHub Apps → New GitHub App*
   (or the same under your organisation).
2. Name: `renovate-<your-handle>`, Homepage URL: your repo URL. Uncheck **Webhook → Active**.
3. **Repository permissions**:

   | Permission | Access | Why |
   |------------|--------|-----|
   | Contents | Read & write | push `renovate/*` branches |
   | Pull requests | Read & write | open/update PRs |
   | Issues | Read & write | Dependency Dashboard |
   | Workflows | Read & write | update `.github/workflows/*` (action versions) |
   | Checks / Commit statuses | Read | know whether CI is green before automerging |
   | Administration | Read | (optional) read branch protection |

4. *Create* → note the **Client ID** → *Generate a private key* (downloads a `.pem`).
5. *Install App* → only on `fixing-broken-windows-with-renovate`.

### Step 2: give the workflow the credentials

Either click through *Settings → Secrets and variables → Actions*:

- Variable `RENOVATE_APP_CLIENT_ID` = the Client ID
- Secret `RENOVATE_APP_PRIVATE_KEY` = contents of the `.pem`

…or let Terraform do it, together with the repository settings you need in module 5:

```bash
cd terraform/github
cp terraform.tfvars.example terraform.tfvars   # fill in owner, client id, key path
export GITHUB_TOKEN=$(gh auth token)
terraform init && terraform apply
```

### Step 3: add the workflow

```bash
mkdir -p .github/workflows
cp ci-templates/github-actions/renovate.yml .github/workflows/renovate.yml
git add .github/workflows/renovate.yml && git commit -m "ci: run Renovate on a schedule" && git push
```

Read the workflow. Find the five ingredients from 3.1. Then:
*Actions → Renovate → Run workflow* (log level `debug` the first time).

### Step 4: onboarding

Renovate doesn't touch a repository until it has been **onboarded**. The first
run opens a PR **"Configure Renovate"** that adds a `renovate.json`, listing what
it detected and what PRs it *would* open.

> This repository already has a `renovate.json`, so Renovate skips onboarding
> and starts right away. To see onboarding, temporarily rename it to
> `renovate.json.bak`, run the workflow again and look at the PR. Rename it back
> afterwards. (Close the onboarding PR without merging.)

### Step 5: look around

After the run you should have:

- [ ] An issue **Dependency Dashboard** listing every pending update
- [ ] Up to 20 PRs (`prConcurrentLimit` in `renovate.json`)
- [ ] CI (`.github/workflows/ci.yml`) running on those PRs. **If CI doesn't run,
      you're using `GITHUB_TOKEN`: go back to step 1.**
- [ ] Release notes in the PR bodies (thanks to the github.com token)

Open the PR for `next` and for `pydantic`: note the *Age*, *Adoption*, *Passing*
and *Confidence* badges. `config:recommended` adds those via Mend's Merge Confidence.

## 3.3 Two schedules, not one

There are **two** different schedules:

| | Defined in | Decides |
|-|-----------|---------|
| **Job schedule** | the CI cron (`17 5 * * 1-5`) | *when the bot runs at all* |
| **Renovate `schedule`** | `renovate.json` (`"schedule": ["* 0-8 * * 1-5"]`) | *what the bot may do while it runs*: create branches/PRs only inside this window |

Renovate outside its `schedule` still rebases PRs, updates the dashboard and
automerges (unless you set `automergeSchedule`). If the cron never overlaps
with the `schedule` window, Renovate never opens a PR. Classic mistake.

Running the job **more often** (hourly) is fine and common: each run is cheap
thanks to the repository cache, and PRs get rebased and automerged faster.

## 3.4 Bonus

- Switch to **autodiscover**: comment out `RENOVATE_REPOSITORIES`, uncomment
  `RENOVATE_AUTODISCOVER*`. Which repositories does it process? (Only those the App is installed on.)
- Tick a checkbox in the Dependency Dashboard. The workflow re-runs because of the
  `issues: edited` trigger.
- Pick another CI system from the table and read its template. What's different? (Mostly:
  how secrets reach the job, and how the token is created.)
