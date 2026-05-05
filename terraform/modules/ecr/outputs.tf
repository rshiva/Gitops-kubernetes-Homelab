output "repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.devopsrt-home-lab.repository_url
}

output "repository_arn" {
  description = "The ARN of the ECR repository"
  value       = aws_ecr_repository.devopsrt-home-lab.arn
}

output "repository_name" {
  description = "The name of the ECR repository"
  value       = aws_ecr_repository.devopsrt-home-lab.name
}
