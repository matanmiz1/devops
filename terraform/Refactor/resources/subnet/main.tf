resource "aws_subnet" "subnet" {
  vpc_id                  = var.vpc_id
  availability_zone       = var.az
  cidr_block              = var.cidr_block
  map_public_ip_on_launch = var.map_public_ip

  tags = var.tags
}