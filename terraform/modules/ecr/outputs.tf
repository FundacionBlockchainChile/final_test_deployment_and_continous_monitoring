output "repository_url" {
  description = "URL del repositorio ECR creado."
  value       = aws_ecr_repository.main.repository_url
} 