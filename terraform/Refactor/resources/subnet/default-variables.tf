# Input variable definitions

variable "map_public_ip" {
  description = "Map public ip to resources on this subnet"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to set on the subnet"
  type        = map(string)
  default     = null
}