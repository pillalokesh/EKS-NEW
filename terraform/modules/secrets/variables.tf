variable "cluster_name" {
  type = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for Secrets Manager encryption"
  type        = string
}

variable "node_role_arn" {
  description = "EKS node IAM role ARN allowed to read secrets"
  type        = string
}

variable "recovery_window" {
  description = "Days before a deleted secret is permanently removed"
  type        = number
  default     = 30
}

variable "tags" {
  type    = map(string)
  default = {}
}
