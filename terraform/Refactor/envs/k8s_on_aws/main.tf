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
  default     = "k8s"
}

module "create_vpc" {
  source                        = "../../services/vpc/"

  vpc_tags                      = { Name = "vpc_${var.suffix}"}
  instances_public              = 1
  instances_private             = 0
  sub_public_tags               = { Name = "PubSub_${var.suffix}"}
  sub_private_tags              = { Name = "PriSub_${var.suffix}"}
  sub_seperated_az_architecture = false
  igw_tags                      = { Name = "igw_${var.suffix}"}
  rt_public_tags                = { Name = "PubRT_${var.suffix}"}
  rt_private_tags               = { Name = "PriRT_${var.suffix}"}
  #TODO add incoming ports for k8s:
  #sg_public_incoming_ports      =
  #sg_public_outgoing_ports      = 
  #sg_private_incoming_ports     = 
  #sg_private_outgoing_ports     = 
}

module "create_master_ec2" {
  source          = "../../resources/ec2/"
  count           = 1  
  ami             = "ami-02fe94dee086c0c37"
  instance_type   = "t3a.small"
  subnet_id       = module.create_vpc.out_public_subnet_id[count.index]
  key             = "MyKey01"
  is_public       = true
  security_groups = [for sg in module.create_vpc.out_public_security_group_id: sg]
  user_data       = file("master.sh")
  tags            = { Name = "Master_${var.suffix}"}
}

module "create_worker_ec2" {
  source          = "../../resources/ec2/"
  count           = 1  
  ami             = "ami-02fe94dee086c0c37"
  instance_type   = "t3.micro"
  subnet_id       = module.create_vpc.out_public_subnet_id[count.index]
  key             = "MyKey01"
  is_public       = true
  security_groups = [for sg in module.create_vpc.out_public_security_group_id: sg]
  user_data       = file("worker.sh")
  tags            = { Name = "Worker_${var.suffix}"}
}

#output "out_all_vpc_info" {
#  value = module.create_vpc.*
#}

output "out_master_info" {
  value = module.create_master_ec2.*
}

output "out_worker_info" {
  value = module.create_worker_ec2.*
}