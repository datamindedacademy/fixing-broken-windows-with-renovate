variable "gitlab_url" {
  description = "GitLab API URL."
  type        = string
  default     = "https://gitlab.com/api/v4/"
}

variable "project" {
  description = "Full path of the project that runs Renovate, e.g. my-group/renovate-runner."
  type        = string
}

variable "github_com_token" {
  description = "Read-only github.com PAT (no scopes) for release notes. Optional."
  type        = string
  sensitive   = true
  default     = ""
}

variable "cron" {
  description = "When Renovate runs."
  type        = string
  default     = "17 5 * * 1-5"
}

variable "cron_timezone" {
  type    = string
  default = "Europe/Brussels"
}
