resource "aws_route_table" "route_table" {
  vpc_id = var.vpc_id

  dynamic "route" {
      for_each = var.routes

      iterator = r
      content {
          cidr_block = r.value["cidr_block"]
          gateway_id = r.value["gateway_id"]
          ipv6_cidr_block = r.value["ipv6_cidr_block"]
      }
  }

  tags = var.tags
}