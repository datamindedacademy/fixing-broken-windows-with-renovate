variable "organization" {
  description = "Azure DevOps organisation name (dev.azure.com/<organization>)."
  type        = string
}

variable "project_name" {
  description = "Project to create for the workshop."
  type        = string
  default     = "renovate-workshop"
}

variable "source_repository_url" {
  description = "Public git URL to import as the demo repository."
  type        = string
  default     = "https://github.com/datamindedacademy/fixing-broken-windows-with-renovate.git"
}

variable "github_com_token" {
  description = "Read-only github.com PAT for release notes. Optional."
  type        = string
  sensitive   = true
  default     = ""
}
