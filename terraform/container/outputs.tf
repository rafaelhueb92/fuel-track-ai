output "ecr_repository_uri" {
  value = aws_ecr_repository.this.repository_url
}
