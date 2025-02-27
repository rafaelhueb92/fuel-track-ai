output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.this.id
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = aws_nat_gateway.nat.id
}

output "nat_gateway_eip" {
  description = "The Elastic IP of the NAT Gateway"
  value       = aws_eip.nat_eip.public_ip
}

# Public Subnets
output "public_subnet_1_id" {
  description = "The ID of the first public subnet"
  value       = aws_subnet.public_subnet_1.id
}

output "public_subnet_2_id" {
  description = "The ID of the second public subnet"
  value       = aws_subnet.public_subnet_2.id
}

output "public_subnet_1_cidr" {
  description = "The CIDR block of the first public subnet"
  value       = aws_subnet.public_subnet_1.cidr_block
}

output "public_subnet_2_cidr" {
  description = "The CIDR block of the second public subnet"
  value       = aws_subnet.public_subnet_2.cidr_block
}

# Private Subnets
output "private_subnet_1_id" {
  description = "The ID of the first private subnet"
  value       = aws_subnet.private_subnet_1.id
}

output "private_subnet_2_id" {
  description = "The ID of the second private subnet"
  value       = aws_subnet.private_subnet_2.id
}

output "private_subnet_1_cidr" {
  description = "The CIDR block of the first private subnet"
  value       = aws_subnet.private_subnet_1.cidr_block
}

output "private_subnet_2_cidr" {
  description = "The CIDR block of the second private subnet"
  value       = aws_subnet.private_subnet_2.cidr_block
}

# Route Tables
output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public_rt.id
}

output "private_route_table_id" {
  description = "The ID of the private route table"
  value       = aws_route_table.private_rt.id
}

output "availability_zones" {
  description = "The availability zones used in this VPC"
  value       = [var.az_1, var.az_2]
}
