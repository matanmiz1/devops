# Output variable definitions

output "out_vpc_cidr" {
  description = "VPC CIDR"
  value       = aws_vpc.vpc.cidr_block
}

output "out_vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.vpc.id
}