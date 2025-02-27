resource "aws_iam_role" "flask_dynamodb_role" {
  name = "fuel-track-ai-flask-dynamodb-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${var.aws_account_id}:oidc-provider/${module.eks.oidc_provider}"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        "StringEquals" = {
          "${module.eks.oidc_provider}:sub" = "system:serviceaccount:default:flask-app"
        }
      }
    }]
  })
}

resource "aws_iam_policy" "flask_dynamodb_policy" {
  name        = "fuel-track-ai-dynamodb-policy"
  description = "Policy to allow Flask app to access DynamoDB"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ]
        Resource = module.db.aws_dynamodb_table.this.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_dynamodb_policy" {
  role       = aws_iam_role.flask_dynamodb_role.name
  policy_arn = aws_iam_policy.flask_dynamodb_policy.arn
}
