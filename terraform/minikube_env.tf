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
  default     = 1
}

# 1. Create VPC
resource "aws_vpc" "vpc_test" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "VPC_k8s"
  }
}

# 2. Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_test.id

  tags = {
    Name = "IGW_k8s"
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
    Name = "PublicRT_k8s"
  }
}

# 4.  Create public subnet
resource "aws_subnet" "public_subnet" {
  count                   = var.instances
  vpc_id                  = aws_vpc.vpc_test.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = cidrsubnet(aws_vpc.vpc_test.cidr_block, 8, count.index * 2)
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet_${count.index}_k8s"
  }
}

# 5. Associate subnets with route tables
resource "aws_route_table_association" "public_subnet_association" {
  count          = var.instances
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.route_public.id
}

# 6.  Create public security group
resource "aws_security_group" "public_security_group_test" {
  name        = "PublicSG_k8s"
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

  ingress {
    description = "HTTP from all"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from all"
    from_port   = 8080
    to_port     = 8080
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
    Name = "PublicSG_${count.index}_k8s"
  }
}

# Create public EC2 instance and install docker & minikube
# t2.micro doesn't have enough resources to host minikube
resource "aws_instance" "public_EC2" {
  count                       = var.instances
  ami                         = "ami-0885b1f6bd170450c"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet[count.index].id
  availability_zone           = aws_subnet.public_subnet[count.index].availability_zone
  associate_public_ip_address = true
  security_groups             = [aws_security_group.public_security_group_test[count.index].id]
  key_name                    = "MyKey01"

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get upgrade -y

              sudo apt install -y docker.io
              sudo service docker start
              
              sudo groupadd docker
              sudo usermod -aG docker ubuntu

              curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
              sudo install minikube-linux-amd64 /usr/local/bin/minikube
              sudo chmod 755 /usr/local/bin/minikube

              curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
              sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

              #minikube start --extra-config=kubeadm.ignore-preflight-errors=NumCPU --force --cpus 1
              EOF

  tags = {
    Name = "PublicEC2_minikube"
  }
}

output "ec2_public_ip" {
  value = aws_instance.public_EC2.*.public_ip
}
