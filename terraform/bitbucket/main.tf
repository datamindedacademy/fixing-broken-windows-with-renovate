# Pipelines must be enabled on the repository (Repository settings > Pipelines).

resource "bitbucket_repository_variable" "renovate_token" {
  repository = "${var.workspace}/${var.repository}" # <workspace>/<repo_slug>
  key        = "RENOVATE_TOKEN"
  secured    = true

  # Write-only: the token is sent to Bitbucket but never written to state.
  value_wo         = var.renovate_token
  value_wo_version = var.renovate_token_version
}

resource "bitbucket_pipeline_schedule" "renovate" {
  workspace    = var.workspace
  repository   = var.repository
  cron_pattern = var.cron_pattern
  enabled      = true

  target {
    ref_name = "main"
    ref_type = "branch"

    selector {
      type    = "custom"
      pattern = "renovate" # pipelines.custom.renovate in bitbucket-pipelines.yml
    }
  }
}
