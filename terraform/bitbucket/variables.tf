variable "workspace" {
  description = "Bitbucket workspace slug."
  type        = string
}

variable "repository" {
  description = "Repository slug that contains bitbucket-pipelines.yml with the `renovate` custom pipeline."
  type        = string
  default     = "fixing-broken-windows-with-renovate"
}

variable "renovate_token" {
  description = "Repository/workspace access token for Renovate. Ephemeral + write-only: never stored in state. Pass it on the first apply and whenever you bump renovate_token_version."
  type        = string
  sensitive   = true
  ephemeral   = true
  default     = null
}

variable "renovate_token_version" {
  description = "Bump whenever you rotate renovate_token so Terraform re-writes it."
  type        = number
  default     = 1
}

variable "cron_pattern" {
  description = "Bitbucket uses 7-field cron with seconds (UTC): sec min hour day month weekday year."
  type        = string
  default     = "0 17 5 ? * MON-FRI *"
}
