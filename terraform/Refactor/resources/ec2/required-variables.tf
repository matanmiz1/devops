# Required input variable definitions

variable "ami" {
  description = "Image to use for the EC2 (AMI)"
  type        = string
}

variable "instance_type" {
  description = "Instance type to use for the EC2"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID to use for the EC2"
  type        = string
}

variable "key" {
  description = "Key name"
  type        = string
}