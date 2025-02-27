resource "aws_dynamodb_table" "this" {
  name           = "tb_fuel_control"
  billing_mode   = "PAY_PER_REQUEST"   
  hash_key       = "car_id"           
  range_key      = "timestamp"         
  
  attribute {
    name = "car_id"
    type = "S"  # String type
  }

  attribute {
    name = "timestamp"
    type = "S"  # String type (could also be a number or other types based on your needs)
  }

  attribute {
    name = "fuel_consumption"
    type = "N"  # Numeric type for fuel level, can store percentage, liters, etc.
  }

  tags = {
    Name        = "FuelControlTable"
    Environment = "production"
  }
}


