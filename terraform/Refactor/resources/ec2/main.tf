resource "aws_instance" "ec2" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.is_public
  security_groups             = var.security_groups
  key_name                    = var.key
  user_data                   = var.user_data
  tags                        = var.tags
}