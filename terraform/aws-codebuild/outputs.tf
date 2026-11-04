output "codebuild_project" {
  description = "Start a run manually with: aws codebuild start-build --project-name <this>"
  value       = aws_codebuild_project.renovate.name
}

output "log_group" {
  value = aws_cloudwatch_log_group.renovate.name
}

output "token_secret_arn" {
  description = "Set the token out-of-band with: aws secretsmanager put-secret-value --secret-id <this> --secret-string ..."
  value       = aws_secretsmanager_secret.renovate_token.arn
}
