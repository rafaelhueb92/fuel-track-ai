resource "aws_dynamodb_table" "fuel_control" {
  name           = "tb_fuel_control"
  billing_mode   = "PAY_PER_REQUEST"  # Use On-Demand mode (no need to define read/write capacity)
  hash_key       = "car_id"           # Partition key
  range_key      = "timestamp"        # Sort key (for querying based on time)
  
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

output "dynamodb_table_name" {
  value = aws_dynamodb_table.fuel_control.name
}
