variable "kms_key_arn" {
  description = "KMS key ARN for CloudWatch log group encryption"
  type        = string
}

variable "cluster_name" {
  type = string
}

variable "fluent_bit_role_arn" {
  type = string
}

variable "fluent_bit_chart_version" {
  type    = string
  default = "0.43.0"
}

variable "log_retention_days" {
  type    = number
  default = 30
}

variable "tags" {
  type    = map(string)
  default = {}
}
