terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Provider
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

variable "suffix" {
  description = ""
  type        = string
  default     = "1az"
}

module "create_vpc" {
  source                        = "../../services/vpc/"

  vpc_tags                      = { Name = "vpc_${var.suffix}"}
  instances_public              = 1
  instances_private             = 1
  sub_public_tags               = { Name = "PubSub_${var.suffix}"}
  sub_private_tags              = { Name = "PriSub_${var.suffix}"}
  sub_seperated_az_architecture = false
  igw_tags                      = { Name = "igw_${var.suffix}"}
  rt_public_tags                = { Name = "PubRT_${var.suffix}"}
  rt_private_tags               = { Name = "PriRT_${var.suffix}"}
  #sg_public_incoming_ports      = 
  #sg_public_outgoing_ports      = 
  #sg_private_incoming_ports     = 
  #sg_private_outgoing_ports     = 
}

module "create_public_ec2" {
  source          = "../../resources/ec2/"
  count           = 1  
  ami             = "ami-047a51fa27710816e"
  instance_type   = "t2.micro"
  subnet_id       = module.create_vpc.out_public_subnet_id[count.index]
  key             = "MyKey01"
  is_public       = true
  security_groups = [for sg in module.create_vpc.out_public_security_group_id: sg]
  user_data       = <<-EOF
                    #!/bin/bash
                    sudo yum update -y
                    sudo yum install httpd -y
                    sudo su -
                    echo 'Welcome to my first EC2 server deployed by Terraform on AWS!' > index.html
                    sudo mv index.html /var/www/html/index.html
                    sudo systemctl start httpd
                    EOF
  tags            = { Name = "Pub_EC2_${var.suffix}"}
}

module "create_private_ec2" {
  source          = "../../resources/ec2/"
  count           = 1
  ami             = "ami-047a51fa27710816e"
  instance_type   = "t2.micro"
  subnet_id       = module.create_vpc.out_private_subnet_id[count.index]
  key             = "MyKey01"
  is_public       = false
  security_groups = [for sg in module.create_vpc.out_private_security_group_id: sg]
  user_data       = <<-EOF
                    #!/bin/bash
                    sudo yum update -y
                    EOF
  tags            = { Name = "Pri_EC2_${var.suffix}"}
}

/*
output "out_all_vpc_info" {
  value = module.create_vpc.*
}
*/
output "out_all_public_ec2_info" {
  value = module.create_public_ec2.*
}

output "out_all_private_ec2_info" {
  value = module.create_private_ec2.*
}

/*
# Create elasitc IP for the NAT Gateway
resource "aws_eip" "eip_nat_gateway" {
  vpc         = true
  depends_on  = [aws_internet_gateway.igw]
}

# Create NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip_nat_gateway.id
  subnet_id     = aws_subnet.public_subnet[0].id
  depends_on    = [aws_internet_gateway.igw]

  tags = {
    Name = "NAT_GW_test"
  }
}
*/

/*
output "nat_gateway_ip" {
  value = aws_nat_gateway.nat_gw.public_ip
}
*/