# Input variable definitions

variable "tags" {
  description = "Tags to set on the internet gateway"
  type        = map(string)
  default     = {}
}