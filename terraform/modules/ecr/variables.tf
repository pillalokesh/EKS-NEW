variable "project_name" {
  description = "Project name used as ECR namespace prefix"
  type        = string
}

variable "repository_names" {
  description = "List of ECR repository names to create"
  type        = list(string)
  default     = ["frontend", "user-service", "product-service", "order-service", "payment-service"]
}

variable "kms_key_arn" {
  description = "KMS key ARN for ECR encryption"
  type        = string
}

variable "node_role_arn" {
  description = "EKS node IAM role ARN to allow ECR pull"
  type        = string
}

variable "force_delete" {
  description = "Force delete repository even if it contains images"
  type        = bool
  default     = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
