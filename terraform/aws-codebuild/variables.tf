variable "region" {
  description = "AWS region to run Renovate in."
  type        = string
  default     = "eu-west-1"
}

variable "name" {
  description = "Name prefix for all resources."
  type        = string
  default     = "renovate"
}

variable "platform" {
  description = "Git hosting platform Renovate talks to: github, gitlab, bitbucket, azure, ..."
  type        = string
  default     = "github"
}

variable "endpoint" {
  description = "Platform API endpoint. Leave empty for github.com / gitlab.com / bitbucket.org."
  type        = string
  default     = ""
}

variable "repositories" {
  description = "Repositories to process (owner/name). Leave empty to use autodiscover."
  type        = list(string)
  default     = []
}

variable "autodiscover_filter" {
  description = "Autodiscover filter, used when repositories is empty, e.g. \"my-org/*\"."
  type        = string
  default     = ""
}

variable "schedule_expression" {
  description = "EventBridge Scheduler expression for Renovate runs."
  type        = string
  default     = "cron(17 5 ? * MON-FRI *)"
}

variable "schedule_timezone" {
  description = "Timezone for the schedule expression."
  type        = string
  default     = "Europe/Brussels"
}

variable "use_github_com_token" {
  description = "Inject RENOVATE_GITHUB_COM_TOKEN from Secrets Manager (set its value first)."
  type        = bool
  default     = false
}

variable "build_timeout_minutes" {
  description = "Hard timeout for one Renovate run."
  type        = number
  default     = 30
}
