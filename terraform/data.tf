data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "backend_bucket_name" {
  name = "/backend-tf/name"
}