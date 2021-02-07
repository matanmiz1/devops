# Input variable definitions

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "tenancy" {
  description = "Instance tenancy (default / dedicated / host)"
  type        = string
  default     = "default"
}

variable "tags" {
  description = "Tags to set on the VPC"
  type        = map(string)
  default     = {}
}