variable "owner" {
  description = "GitHub user or organisation that owns the repository."
  type        = string
}

variable "repository" {
  description = "Repository name (your fork/copy of this workshop repo)."
  type        = string
  default     = "fixing-broken-windows-with-renovate"
}

variable "visibility" {
  description = "Repository visibility."
  type        = string
  default     = "public"
}

variable "renovate_app_client_id" {
  description = "Client ID of the GitHub App Renovate authenticates as (Settings > Developer settings > GitHub Apps)."
  type        = string
}

variable "renovate_app_private_key_path" {
  description = "Path to the GitHub App's private key (.pem)."
  type        = string
}

variable "required_checks" {
  description = "CI job names that must pass before anything (including Renovate automerge) can land on main."
  type        = list(string)
  default     = ["backend", "frontend", "terraform", "renovate-config"]
}
