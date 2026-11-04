terraform {
  required_version = ">= 1.11" # write-only attributes

  required_providers {
    bitbucket = {
      source  = "DrFaust92/bitbucket"
      version = "~> 2.54"
    }
  }
}

# Community provider. Authenticates with BITBUCKET_USERNAME + BITBUCKET_PASSWORD
# (Atlassian account email + API token) or an OAuth client / access token.
provider "bitbucket" {}
