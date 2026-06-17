output "repository_urls" {
  description = "Map of service name to ECR repository URL for use in CI/CD push commands"
  value       = { for k, v in aws_ecr_repository.repos : k => v.repository_url }
}
