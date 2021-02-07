resource "aws_security_group" "security_group" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
      for_each = var.incoming_ports

      iterator = i
      content {
        description     = i.value["description"]
        from_port       = i.value["from_port"]
        to_port         = i.value["to_port"]
        protocol        = i.value["protocol"]
        cidr_blocks     = i.value["cidr_blocks"]
        security_groups = i.value["security_groups"]
      }
  }

  dynamic "egress" {
      for_each = var.outgoing_ports

      iterator = i
      content {
        description     = i.value["description"]
        from_port       = i.value["from_port"]
        to_port         = i.value["to_port"]
        protocol        = i.value["protocol"]
        cidr_blocks     = i.value["cidr_blocks"]
        security_groups = i.value["security_groups"]
      }
  }

  tags = var.tags
}