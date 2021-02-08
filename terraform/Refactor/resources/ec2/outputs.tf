# Output variable definitions

output "out_ec2_public_ip" {
  description = "EC2 public IP"
  value       = aws_instance.ec2.public_ip
}

output "out_ec2_private_ip" {
  description = "EC2 private IP"
  value       = aws_instance.ec2.private_ip
}