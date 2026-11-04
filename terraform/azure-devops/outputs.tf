output "repository_url" {
  value = azuredevops_git_repository.demo.web_url
}

output "pipeline_id" {
  value = azuredevops_build_definition.renovate.id
}
