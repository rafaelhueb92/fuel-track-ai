# ALB for EKS
resource "aws_lb" "eks_alb" {
  name               = "fuel-track-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets           = aws_subnet.public[*].id
}

# Target Group for EKS Pods
resource "aws_lb_target_group" "eks_tg" {
  name        = "fuel-track-eks-tg"
  target_type = "ip"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.fuel_track_vpc.id
}

# ALB Listener
resource "aws_lb_listener" "eks_listener" {
  load_balancer_arn = aws_lb.eks_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.eks_tg.arn
  }
}

# Kubernetes Ingress (applied inside EKS)
resource "kubernetes_ingress" "fuel_track_ingress" {
  metadata {
    name = "fuel-track-ingress"
    annotations = {
      "kubernetes.io/ingress.class" = "alb"
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
    }
  }

  spec {
    rule {
      http {
        path {
          path = "/"
          backend {
            service_name = "fuel-api"
            service_port = 5000
          }
        }
      }
    }
  }
}
