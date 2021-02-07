# Input variable definitions

variable "name" {
  description = "Name of the security group"
  type        = string
  default     = ""
}

variable "description" {
  description = "Description of the security group"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to set on the security group"
  type        = map(string)
  default     = {}
}

variable "incoming_ports" {
  description = "ingress"
  type        = list
  default     = []
}

variable "outgoing_ports" {
  description = "egress"
  type        = list
  default     = []
}