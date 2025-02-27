resource "aws_cognito_user_pool" "fuel_users" {
  name = "fuel-track-ai-user-pool"

  auto_verified_attributes = ["email"]

  schema {
    name                     = "email"
    attribute_data_type      = "String"
    required                 = true
    mutable                  = false
  }

  schema {
    name                     = "car_id"
    attribute_data_type      = "String"
    mutable                  = false
    required                 = false
    string_attribute_constraints {
      min_length = 8
      max_length = 20
    }
  }
}

resource "aws_cognito_user_pool_client" "fuel_client" {
  name                = "fuel-app-client"
  user_pool_id        = aws_cognito_user_pool.fuel_users.id
  generate_secret     = false
  explicit_auth_flows = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH"]
}

resource "aws_cognito_identity_pool" "fuel_identity_pool" {
  identity_pool_name               = "fuel-track-ai-identity-pool"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id = aws_cognito_user_pool_client.fuel_client.id
    provider_name = aws_cognito_user_pool.fuel_users.endpoint
  }
}