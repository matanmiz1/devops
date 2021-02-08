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
  default     = "1az_clean"
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

output "out_testEnv1az_clean" {
  value = "Deployment succeeded!"
}

output "out_vpc_cidr" {
  value = module.create_vpc.out_vpc_cidr
}

output "out_public_subnet_cidr" {
  value = module.create_vpc.out_public_subnet_cidr
}

output "out_private_subnet_cidr" {
  value = module.create_vpc.out_private_subnet_cidr
}

output "out_all_vpc_info" {
  value = module.create_vpc.*
}
