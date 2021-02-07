# Output variable definitions

output "out_security_group_id" {
  description = "id of the security group"
  value       = aws_security_group.security_group.id
}