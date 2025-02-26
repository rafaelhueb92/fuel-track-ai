resource "aws_ecr_repository" "flask_api_repo" {
  name = "flask-fuel-ai-api-repo"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "flask-fuel-ai-api-repo"
    Environment = "production"
  }
}

resource "null_resource" "push_docker_image" {
  depends_on = [aws_ecr_repository.flask_api_repo]

  provisioner "local-exec" {
    command = <<EOT
      # Log in to AWS ECR
      aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${aws_ecr_repository.flask_api_repo.repository_url}

      # Build the Docker image
      docker build -t flask-api:latest .

      # Tag the Docker image with the ECR repository URL
      docker tag flask-api:latest ${aws_ecr_repository.flask_api_repo.repository_url}:latest

      # Push the Docker image to the ECR repository
      docker push ${aws_ecr_repository.flask_api_repo.repository_url}:latest
    EOT
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

# Output the ECR repository URL
output "ecr_repository_uri" {
  value = aws_ecr_repository.flask_api_repo.repository_url
}
