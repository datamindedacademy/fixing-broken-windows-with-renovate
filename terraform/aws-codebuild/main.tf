locals {
  buildspec = file("${path.module}/../../ci-templates/aws-codebuild/buildspec.yml")

  plain_env = merge(
    {
      RENOVATE_PLATFORM   = var.platform
      RENOVATE_GIT_AUTHOR = "Renovate Bot <renovate@example.com>"
    },
    var.endpoint != "" ? { RENOVATE_ENDPOINT = var.endpoint } : {},
    length(var.repositories) > 0
    ? { RENOVATE_REPOSITORIES = join(",", var.repositories) }
    : merge(
      { RENOVATE_AUTODISCOVER = "true" },
      var.autodiscover_filter != "" ? { RENOVATE_AUTODISCOVER_FILTER = var.autodiscover_filter } : {},
    ),
  )
}

# --- Secrets -----------------------------------------------------------------
# Terraform creates the secret *containers* only. Put the values in out-of-band
# so tokens never end up in the Terraform state:
#   aws secretsmanager put-secret-value --secret-id renovate/token --secret-string "$TOKEN"

resource "aws_secretsmanager_secret" "renovate_token" {
  name        = "${var.name}/token"
  description = "Token Renovate uses to talk to ${var.platform}"
}

resource "aws_secretsmanager_secret" "github_com_token" {
  name        = "${var.name}/github-com-token"
  description = "Read-only github.com token for Renovate release notes"
}

# --- Logs --------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "renovate" {
  name              = "/aws/codebuild/${var.name}"
  retention_in_days = 30
}

# --- CodeBuild ---------------------------------------------------------------

resource "aws_codebuild_project" "renovate" {
  name          = var.name
  description   = "Self-hosted Renovate (${var.platform})"
  service_role  = aws_iam_role.codebuild.arn
  build_timeout = var.build_timeout_minutes

  # One Renovate run at a time: concurrent runs fight over the same branches.
  concurrent_build_limit = 1

  source {
    type      = "NO_SOURCE" # Renovate clones the repositories itself
    buildspec = local.buildspec
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_MEDIUM"
    image           = "aws/codebuild/amazonlinux-x86_64-standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true # we `docker run` the official Renovate image

    dynamic "environment_variable" {
      for_each = local.plain_env
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }

    environment_variable {
      name  = "RENOVATE_TOKEN"
      type  = "SECRETS_MANAGER"
      value = aws_secretsmanager_secret.renovate_token.arn
    }

    dynamic "environment_variable" {
      for_each = var.use_github_com_token ? [1] : []
      content {
        name  = "RENOVATE_GITHUB_COM_TOKEN"
        type  = "SECRETS_MANAGER"
        value = aws_secretsmanager_secret.github_com_token.arn
      }
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.renovate.name
    }
  }
}

# --- Schedule ----------------------------------------------------------------
# EventBridge Scheduler with a universal target: calls codebuild:StartBuild.

resource "aws_scheduler_schedule" "renovate" {
  name                         = var.name
  description                  = "Run Renovate on a schedule"
  schedule_expression          = var.schedule_expression
  schedule_expression_timezone = var.schedule_timezone

  flexible_time_window {
    mode                      = "FLEXIBLE"
    maximum_window_in_minutes = 15
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:codebuild:startBuild"
    role_arn = aws_iam_role.scheduler.arn
    input    = jsonencode({ ProjectName = aws_codebuild_project.renovate.name })

    retry_policy {
      maximum_retry_attempts = 0
    }
  }
}
