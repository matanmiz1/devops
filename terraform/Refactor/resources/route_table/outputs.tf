# Output variable definitions

output "out_route_table_id" {
  description = "Route table ID"
  value       = aws_route_table.route_table.id
}