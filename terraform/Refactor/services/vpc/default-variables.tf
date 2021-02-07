# Input variable definitions

################ VPC ################

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_tenancy" {
  description = "Instance tenancy (default / dedicated / host)"
  type        = string
  default     = "default"
}

variable "vpc_tags" {
  description = "Tags to set on the vpc"
  type        = map(string)
  default     = {}
}

################ Subnet ################

variable "az" {
  description = "Availability zone"
  type        = string
  default     = ""
}

variable "instances_public" {
  description = "Number of public subnets"
  type        = number
  default     = 1
}

variable "instances_private" {
  description = "Number of private subnets"
  type        = number
  default     = 1
}

variable "sub_public_tags" {
  description = "Tags to set on the public subnets"
  type        = map(string)
  default     = null
}

variable "sub_private_tags" {
  description = "Tags to set on the private subnets"
  type        = map(string)
  default     = null
}

################ Internet Gateway ################

variable "igw_tags" {
  description = "Tags to set on the internet gateway"
  type        = map(string)
  default     = null
}

################ Route Table ################

variable "rt_public_tags" {
  description = "Tags to set on the public route table"
  type        = map(string)
  default     = null
}

variable "rt_private_tags" {
  description = "Tags to set on the private route table"
  type        = map(string)
  default     = null
}

/*
variable "rt_public_routes" {
  description = "List of routes for public route table"
  type        = list(object({
    cidr_block      = string
    gateway_id      = string
    ipv6_cidr_block = string
  }))
  default     = []
}

variable "rt_private_routes" {
  description = "List of routes for private route table"
  type        = list(object({
    cidr_block      = string
    gateway_id      = string
    ipv6_cidr_block = string
  }))
  default     = []
}
*/

################ Security Group ################

variable "sg_public_incoming_ports" {
  description = "List of incoming ports"
  type        = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      description     = "SSH from all"
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      cidr_blocks     = ["0.0.0.0/0"]
    },
    {
      description     = "HTTP from all"
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      cidr_blocks     = ["0.0.0.0/0"]
    }
  ]
}

variable "sg_public_outgoing_ports" {
  description = "List of outgoing ports"
  type        = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      description     = "World"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    }
  ]
}

variable "sg_private_incoming_ports" {
  description = "List of incoming ports"
  type        = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      description     = "SSH from public subnet"
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      cidr_blocks     = []
    }
  ]
}

variable "sg_private_outgoing_ports" {
  description = "List of outgoing ports"
  type        = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      description     = "World"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    }
  ]
}