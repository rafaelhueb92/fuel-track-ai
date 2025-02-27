resource "aws_ecr_repository" "this" {
  name = "flask-fuel-ai-api-repo"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "flask-fuel-ai-api-repo"
    Environment = "production"
  }
}

resource "null_resource" "this" {
  depends_on = [aws_ecr_repository.this]

  provisioner "local-exec" {
    command = <<EOT
      # Log in to AWS ECR
      aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${aws_ecr_repository.this.repository_url}

      # Build the Docker image
      docker build -t flask-api:latest .

      # Tag the Docker image with the ECR repository URL
      docker tag flask-api:latest ${aws_ecr_repository.this.repository_url}:latest

      # Push the Docker image to the ECR repository
      docker push ${aws_ecr_repository.this.repository_url}:latest
    EOT
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}