# Output variable definitions

output "out_subnet_id" {
  description = "Subnet ID"
  value       = aws_subnet.subnet.id
}