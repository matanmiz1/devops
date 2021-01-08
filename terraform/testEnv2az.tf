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

# Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
}

variable "instances" {
  description = "Number of duplicated instances"
  type        = number
  default     = 2
}

# 1. Create VPC
resource "aws_vpc" "vpc_test" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "VPC_test"
  }
}

# 2. Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_test.id

  tags = {
    Name = "IGW_test"
  }
}

# 3.  Create custom route tables
# 3.1 Create custom route tables for public subnet
resource "aws_route_table" "route_public" {
  vpc_id = aws_vpc.vpc_test.id

  # Note: the default route, mapping the VPC's CIDR block to "local", is created implicitly and cannot be specified.

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "PublicRT_test"
  }
}

# 3.2 Create custom route tables for private subnet
resource "aws_route_table" "route_private" {
  vpc_id = aws_vpc.vpc_test.id

  # Note: the default route, mapping the VPC's CIDR block to "local", is created implicitly and cannot be specified.

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "PrivateRT_test"
  }
}

# 4.  Create subnets
# 4.1 Create public subnets
resource "aws_subnet" "public_subnet" {
  count                   = var.instances
  vpc_id                  = aws_vpc.vpc_test.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = cidrsubnet(aws_vpc.vpc_test.cidr_block, 8, count.index * 2)
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet_${count.index}_test"
  }
}

# 4.2 Create private subnets
resource "aws_subnet" "private_subnet" {
  count                   = var.instances
  vpc_id                  = aws_vpc.vpc_test.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = cidrsubnet(aws_vpc.vpc_test.cidr_block, 8, count.index * 2 + 1)

  tags = {
    Name = "PrivateSubnet_${count.index}_test"
  }
}

# 5. Associate subnets with route tables
resource "aws_route_table_association" "public_subnet_association" {
  count          = var.instances
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.route_public.id
}

resource "aws_route_table_association" "private_subnet_association" {
  count          = var.instances
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.route_private.id
}

# 6.  Create security groups
# 6.1 Create public security group
resource "aws_security_group" "public_security_group_test" {
  name        = "PublicSG_test"
  count       = var.instances
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc_test.id

  ingress {
    description = "SSH from all"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from all"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "PublicSG_${count.index}_test"
  }
}

# 6.2 Create private security group
resource "aws_security_group" "private_security_group_test" {
  name        = "PrivateSG_test"
  count       = var.instances
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc_test.id

  ingress {
    description = "SSH from public subnet"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_security_group_test[count.index].id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "PrivateSG_${count.index}_test"
  }
}

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

# Create public EC2 instance and install apache2 
resource "aws_instance" "public_EC2" {
  count                       = var.instances
  ami                         = "ami-04d29b6f966df1537"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet[count.index].id
  availability_zone           = aws_subnet.public_subnet[count.index].availability_zone
  associate_public_ip_address = true
  security_groups             = [aws_security_group.public_security_group_test[count.index].id]
  key_name                    = "MyKey01"

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install httpd -y
              sudo su -
              echo 'Welcome to my first EC2 server deployed by Terraform on AWS!' > index.html
              sudo mv index.html /var/www/html/index.html
              sudo systemctl start httpd
              EOF

  tags = {
    Name = "PublicEC2_${count.index}_Test"
  }
}

# Create private EC2 instance
resource "aws_instance" "private_EC2" {
  count                       = var.instances
  ami                         = "ami-04d29b6f966df1537"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private_subnet[count.index].id
  availability_zone           = aws_subnet.private_subnet[count.index].availability_zone
  security_groups             = [aws_security_group.private_security_group_test[count.index].id]
  key_name                    = "MyKey01"

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              EOF

  tags = {
    Name = "PrivateEC2_${count.index}_Test"
  }
}

output "ec2_public_ip" {
  value = aws_instance.public_EC2.*.public_ip
}

output "ec2_private_ip" {
  value = aws_instance.private_EC2.*.private_ip
}

output "nat_gateway_ip" {
  value = aws_nat_gateway.nat_gw.public_ip
}