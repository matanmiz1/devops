# Output variable definitions

output "out_vpc_cidr" {
  description = "VPC CIDR"
  value       = module.create_vpc.out_vpc_cidr
}

output "out_public_subnet_cidr" {
  description = "Public subnet CIDR"
  value       = module.create_public_subnet.*.out_subnet_cidr
}

output "out_private_subnet_cidr" {
  description = "Private subnet CIDR"
  value       = module.create_private_subnet.*.out_subnet_cidr
}

output "out_public_route_table_id" {
  description = "Public route table ID"
  value       = module.create_public_route_table.*.out_route_table_id
}

output "out_private_route_table_id" {
  description = "Private route table ID"
  value       = module.create_private_route_table.*.out_route_table_id
}

output "out_public_security_group_id" {
  description = "Public security group ID"
  value       = module.create_public_security_group.*.out_security_group_id
}

output "out_private_security_group_id" {
  description = "Private security group ID"
  value       = module.create_private_security_group.*.out_security_group_id
}

output "out_public_security_group_seperated_id" {
  description = "Public security group seperated ID"
  value       = module.create_public_security_group_seperated.*.out_security_group_id
}

output "out_private_security_group_seperated_id" {
  description = "Private security group seperated ID"
  value       = module.create_private_security_group_seperated.*.out_security_group_id
}