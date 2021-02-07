# Output variable definitions

output "out_igw_id" {
  description = "id of the internet gateway"
  value       = aws_internet_gateway.igw.id
}