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
  default     = "minikube"
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
  #TODO:
  #sg_public_incoming_ports      =
  #sg_public_outgoing_ports      = 
  #sg_private_incoming_ports     = 
  #sg_private_outgoing_ports     = 
}

module "create_public_ec2" {
  source          = "../../resources/ec2/"
  count           = 1  
  ami             = "ami-02fe94dee086c0c37"
  instance_type   = "t3a.medium"
  subnet_id       = module.create_vpc.out_public_subnet_id[count.index]
  key             = "MyKey01"
  is_public       = true
  security_groups = [for sg in module.create_vpc.out_public_security_group_id: sg]
  user_data       = <<-EOF
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

                    sudo apt install conntrack
                    #minikube start --extra-config=kubeadm.ignore-preflight-errors=NumCPU --force --cpus 1
                    EOF
  tags            = { Name = "Pub_EC2_${var.suffix}_${count.index}"}
}

output "out_all_vpc_info" {
  value = module.create_vpc.*
}

output "out_all_public_ec2_info" {
  value = module.create_public_ec2.*
}