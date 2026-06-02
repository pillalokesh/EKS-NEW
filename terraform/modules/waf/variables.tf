variable "cluster_name" {
  type = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for WAF CloudWatch log group encryption"
  type        = string
}

variable "rate_limit" {
  description = "Maximum number of requests per 5-minute window per IP"
  type        = number
  default     = 2000
}

variable "tags" {
  type    = map(string)
  default = {}
}
