# Input variable definitions

variable "tags" {
  description = "Tags to set on the route table"
  type        = map(string)
  default     = {}
}

variable "routes" {
  description = "List of routes"
  type        = list(object({
    cidr_block      = string
    gateway_id      = string
    ipv6_cidr_block = string
  }))
  default     = []
}