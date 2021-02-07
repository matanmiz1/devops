# Required input variable definitions

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "az" {
  description = "Availability zone"
  type        = string
}

variable "cidr_block" {
  description = "cidr block"
  type        = string
}