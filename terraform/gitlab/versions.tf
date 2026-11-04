terraform {
  required_version = ">= 1.6"

  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "~> 19.5"
    }
  }
}

# Authenticates with GITLAB_TOKEN (a PAT with `api` scope, Maintainer/Owner on the project).
provider "gitlab" {
  base_url = var.gitlab_url
}
