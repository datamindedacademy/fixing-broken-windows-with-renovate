# Adopt the existing repository instead of creating a new one.
import {
  to = github_repository.this
  id = var.repository
}

resource "github_repository" "this" {
  name       = var.repository
  visibility = var.visibility

  # Renovate's Dependency Dashboard is an issue.
  has_issues = true

  # Renovate's platformAutomerge uses GitHub's native "auto-merge" feature:
  # Renovate enables it on the PR, GitHub merges once required checks pass.
  allow_auto_merge       = true
  allow_squash_merge     = true
  allow_merge_commit     = false
  allow_rebase_merge     = true
  delete_branch_on_merge = true
  allow_update_branch    = true

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [description, homepage_url, topics, template, has_wiki, has_projects, has_discussions, has_downloads, pages, security_and_analysis]
  }
}

# Without required checks, "automerge" means "merge immediately". The ruleset
# is what makes automerge safe: Renovate PRs only land when CI is green.
resource "github_repository_ruleset" "main" {
  name        = "protect-main"
  repository  = github_repository.this.name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  rules {
    deletion         = true
    non_fast_forward = true

    pull_request {
      # 0 approvals => Renovate can automerge. If you require reviews, Renovate
      # automerge only works for `automergeType: "branch"` with a bypass, or you
      # need an approver bot. Keep it simple for the workshop.
      required_approving_review_count = 0
      dismiss_stale_reviews_on_push   = true
    }

    required_status_checks {
      strict_required_status_checks_policy = false

      dynamic "required_check" {
        for_each = var.required_checks
        content {
          context = required_check.value
        }
      }
    }
  }
}

# --- Credentials for .github/workflows/renovate.yml -------------------------

resource "github_actions_variable" "renovate_app_client_id" {
  repository    = github_repository.this.name
  variable_name = "RENOVATE_APP_CLIENT_ID"
  value         = var.renovate_app_client_id
}

resource "github_actions_secret" "renovate_app_private_key" {
  repository  = github_repository.this.name
  secret_name = "RENOVATE_APP_PRIVATE_KEY"
  # Note: ends up (encrypted at rest, but readable) in the Terraform state.
  # Use a remote backend with encryption + restricted access.
  value = file(var.renovate_app_private_key_path)
}
