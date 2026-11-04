terraform {
  required_version = ">= 1.6"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.13"
    }
  }
}

# Authenticates with GITHUB_TOKEN (or `gh auth token`) and GITHUB_OWNER.
provider "github" {
  owner = var.owner
}
