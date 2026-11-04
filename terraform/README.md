# Terraform: infrastructure to *run* Renovate

> Not to be confused with [`infra/`](../infra), which is part of the outdated
> demo application that Renovate *updates*.

One self-contained root module per platform. Each has a `terraform.tfvars.example`.

| Stack | Provider | What it sets up |
|-------|----------|-----------------|
| [github](github) | `integrations/github` | Adopts your repo (import block): issues + auto-merge on, ruleset requiring the CI checks, Actions variable/secret for the Renovate GitHub App |
| [gitlab](gitlab) | `gitlabhq/gitlab` | Project access token with automatic rotation, masked + protected CI variables, pipeline schedule |
| [azure-devops](azure-devops) | `microsoft/azuredevops` | Project, repo imported from GitHub, YAML pipeline, variable group, git permissions for the Build Service identity |
| [bitbucket](bitbucket) | `DrFaust92/bitbucket` (community) | Secured repository variable (write-only, kept out of state), pipeline schedule on the `renovate` custom pipeline |
| [aws-codebuild](aws-codebuild) | `hashicorp/aws` | CodeBuild project (privileged, inline buildspec from `ci-templates/`), EventBridge Scheduler schedule, Secrets Manager secrets, IAM roles, CloudWatch log group |

```bash
cd terraform/<stack>
cp terraform.tfvars.example terraform.tfvars   # edit
terraform init
terraform plan
terraform apply
```

Works with OpenTofu too (`tofu init`, …). The Bitbucket stack uses a write-only
attribute and an ephemeral variable: that needs Terraform ≥ 1.11, or an OpenTofu
release that supports both.

## Secrets and state

Tokens are the crown jewels here: whoever has the Renovate token can push to every repo it processes.

- **aws-codebuild** creates the *secret containers* only; you put the value in with
  `aws secretsmanager put-secret-value`, so it never touches Terraform state.
- **bitbucket** uses a write-only attribute (`value_wo`) + an ephemeral variable: same result.
- **github** / **gitlab** / **azure-devops** do store secrets in state (the provider has no
  write-only alternative, or Terraform *creates* the token). Use a remote backend with
  encryption and tight access control, as you should anyway.

## Lock files

Commit the `.terraform.lock.hcl` that `terraform init` creates in each stack
(remove the `.terraform.lock.hcl` line from `.gitignore` first), so Renovate can keep
provider versions *and* hashes up to date. Generate hashes for every platform your
team uses:

```bash
terraform providers lock -platform=linux_amd64 -platform=darwin_arm64 -platform=windows_amd64
```
