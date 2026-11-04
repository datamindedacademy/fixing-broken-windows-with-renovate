data "gitlab_project" "this" {
  path_with_namespace = var.project
}

# A project access token creates a bot user scoped to this project. For
# Renovate across a whole group, use gitlab_group_access_token instead (paid
# tiers on gitlab.com) or a dedicated bot user with a PAT.
resource "gitlab_project_access_token" "renovate" {
  project      = data.gitlab_project.this.id
  name         = "renovate"
  description  = "Used by the scheduled Renovate pipeline"
  access_level = "maintainer" # developer is enough unless Renovate must merge into protected branches
  scopes       = ["api", "write_repository"]

  # GitLab tokens must expire; let Terraform rotate it before it does.
  rotation_configuration = {
    expiration_days    = 90
    rotate_before_days = 14
  }
}

resource "gitlab_project_variable" "renovate_token" {
  project     = data.gitlab_project.this.id
  key         = "RENOVATE_TOKEN"
  value       = gitlab_project_access_token.renovate.token
  masked      = true
  protected   = true # only exposed to pipelines on protected branches (main)
  raw         = true
  description = "Project access token for Renovate (managed by Terraform)"
}

resource "gitlab_project_variable" "github_com_token" {
  count = var.github_com_token == "" ? 0 : 1

  project   = data.gitlab_project.this.id
  key       = "RENOVATE_GITHUB_COM_TOKEN"
  value     = var.github_com_token
  masked    = true
  protected = true
  raw       = true
}

resource "gitlab_pipeline_schedule" "renovate" {
  project       = data.gitlab_project.this.id
  description   = "Renovate"
  ref           = "refs/heads/${data.gitlab_project.this.default_branch}"
  cron          = var.cron
  cron_timezone = var.cron_timezone
  active        = true
}
