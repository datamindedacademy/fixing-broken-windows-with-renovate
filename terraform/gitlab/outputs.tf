output "schedule_url" {
  value = "${data.gitlab_project.this.web_url}/-/pipeline_schedules"
}
