terraform {
  required_version = ">= 1.6"

  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 1.16"
    }
  }
}

# Authenticates with AZDO_ORG_SERVICE_URL + AZDO_PERSONAL_ACCESS_TOKEN
# (or a service principal / managed identity, see the provider docs).
provider "azuredevops" {
  org_service_url = "https://dev.azure.com/${var.organization}"
}
