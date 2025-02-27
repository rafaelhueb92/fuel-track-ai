resource "aws_api_gateway_rest_api" "fuel_api" {
  name = "FuelTrackAPI"
  description = "API for Fuel Tracking"
}

resource "aws_api_gateway_resource" "anomalies" {
  rest_api_id = aws_api_gateway_rest_api.fuel_api.id
  parent_id   = aws_api_gateway_rest_api.fuel_api.root_resource_id
  path_part   = "detect_anomalies"
}

resource "aws_api_gateway_method" "get_anomalies" {
  rest_api_id   = aws_api_gateway_rest_api.fuel_api.id
  resource_id   = aws_api_gateway_resource.anomalies.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.fuel_auth.id
}

resource "aws_api_gateway_resource" "consumption" {
  rest_api_id = aws_api_gateway_rest_api.fuel_api.id
  parent_id   = aws_api_gateway_rest_api.fuel_api.root_resource_id
  path_part   = "get_consumption"
}

resource "aws_api_gateway_method" "get_consumption" {
  rest_api_id   = aws_api_gateway_rest_api.fuel_api.id
  resource_id   = aws_api_gateway_resource.consumption.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.fuel_auth.id
}

resource "aws_api_gateway_resource" "save_fuel" {
  rest_api_id = aws_api_gateway_rest_api.fuel_api.id
  parent_id   = aws_api_gateway_rest_api.fuel_api.root_resource_id
  path_part   = "save_fuel_consumption"
}

resource "aws_api_gateway_method" "post_save_fuel" {
  rest_api_id   = aws_api_gateway_rest_api.fuel_api.id
  resource_id   = aws_api_gateway_resource.save_fuel.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.fuel_auth.id
}

resource "aws_api_gateway_authorizer" "fuel_auth" {
  name          = "FuelCognitoAuthorizer"
  rest_api_id   = aws_api_gateway_rest_api.fuel_api.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = [aws_cognito_user_pool.fuel_users.arn]
}