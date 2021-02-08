# Output variable definitions

output "out_subnet_id" {
  description = "Subnet ID"
  value       = aws_subnet.subnet.id
}

output "out_subnet_cidr" {
  description = "Subnet CIDR"
  value       = aws_subnet.subnet.cidr_block
}