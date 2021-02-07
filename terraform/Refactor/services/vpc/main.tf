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

# Assigns data to locals to read the data only once
locals {
  az = data.aws_availability_zones.available.names
}

module "create_vpc" {
  source = "../../resources/vpc/"

  vpc_cidr = var.vpc_cidr
  tenancy  = var.vpc_tenancy
  tags     = var.vpc_tags
}

module "create_public_subnet" {
  source        = "../../resources/subnet/"
  count         = var.instances_public

  vpc_id        = module.create_vpc.out_vpc_id
  az            = var.az != "" ? var.az : local.az[count.index]
  cidr_block    = cidrsubnet(module.create_vpc.out_vpc_cidr, 8, count.index * 2)
  map_public_ip = true

  tags = var.sub_public_tags != null ? var.sub_public_tags : { Name = "PublicSubnet_${count.index}" }
}

module "create_private_subnet" {
  source        = "../../resources/subnet/"
  count         = var.instances_private

  vpc_id        = module.create_vpc.out_vpc_id
  az            = var.az != "" ? var.az : local.az[count.index]
  cidr_block    = cidrsubnet(module.create_vpc.out_vpc_cidr, 8, count.index * 2 + 1)
  map_public_ip = false

  tags = var.sub_private_tags != null ? var.sub_private_tags : { Name = "PrivateSubnet_${count.index}" }
}

module "create_internet_gateway" {
  source = "../../resources/internet_gateway/"

  vpc_id = module.create_vpc.out_vpc_id
  tags   = var.igw_tags
}

module "create_public_route_table" {
  source = "../../resources/route_table/"

  vpc_id = module.create_vpc.out_vpc_id

# TODO: Should I put in variables to get from user?
  routes = [
    {
      cidr_block      = "0.0.0.0/0"
      gateway_id      = module.create_internet_gateway.out_igw_id
      ipv6_cidr_block = ""
    },
    {
      cidr_block      = ""
      gateway_id      = module.create_internet_gateway.out_igw_id
      ipv6_cidr_block = "::/0"
    }
  ]

  tags = var.rt_public_tags
}

module "create_public_route_table_association" {
  source         = "../../resources/route_table_association/"
  count          = var.instances_public

  subnet_id      = module.create_public_subnet[count.index].out_subnet_id
  route_table_id = module.create_public_route_table.out_route_table_id
}

module "create_private_route_table" {
  source = "../../resources/route_table/"

  vpc_id = module.create_vpc.out_vpc_id

# TODO: Should I put in variables to get from user?
  routes = []

  tags   = var.rt_private_tags
}

module "create_private_route_table_association" {
  source         = "../../resources/route_table_association/"
  count          = var.instances_private

  subnet_id      = module.create_private_subnet[count.index].out_subnet_id
  route_table_id = module.create_private_route_table.out_route_table_id
}

module "create_public_security_group" {
  source      = "../../resources/security_group/"
  count       = var.instances_public

  description = "Allow TLS inbound traffic"
  vpc_id      = module.create_vpc.out_vpc_id

  incoming_ports = [
    for line in var.sg_public_incoming_ports:
    {
      description     = line.description
      from_port       = line.from_port
      to_port         = line.to_port
      protocol        = line.protocol
      cidr_blocks     = line.cidr_blocks
      security_groups = []
    }
  ]

  outgoing_ports = [
    for line in var.sg_public_outgoing_ports:
    {
      description     = line.description
      from_port       = line.from_port
      to_port         = line.to_port
      protocol        = line.protocol
      cidr_blocks     = line.cidr_blocks
      security_groups = []
    }
  ]
}

module "create_private_security_group" {
  source      = "../../resources/security_group/"
  count       = var.instances_private

  description = "Allow TLS inbound traffic"
  vpc_id      = module.create_vpc.out_vpc_id

  # Only from the public security group
  incoming_ports = [
    for line in var.sg_private_incoming_ports:
    {
      description     = line.description
      from_port       = line.from_port
      to_port         = line.to_port
      protocol        = line.protocol
      cidr_blocks     = line.cidr_blocks
      security_groups = [module.create_public_security_group[count.index].out_security_group_id]
    }
  ]

  outgoing_ports = [
    for line in var.sg_private_outgoing_ports:
    {
      description     = line.description
      from_port       = line.from_port
      to_port         = line.to_port
      protocol        = line.protocol
      cidr_blocks     = line.cidr_blocks
      security_groups = []
    }
  ]
}