variable "cluster_name" {
  type = string
}

variable "deletion_window" {
  description = "KMS key deletion window in days"
  type        = number
  default     = 30
}

variable "tags" {
  type    = map(string)
  default = {}
}
