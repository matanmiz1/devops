# Input variable definitions

variable "is_public" {
  description = "Map public ip to the EC2"
  type        = bool
  default     = true
}

variable "security_groups" {
  description = "Security group to associate with the EC2"
  type        = list(string)
  default     = []
}

variable "user_data" {
  description = "User data"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to set on the EC2"
  type        = map(string)
  default     = {}
}