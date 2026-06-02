variable "velero_bucket_name" {
  type = string
}

variable "velero_role_arn" {
  type = string
}

variable "velero_chart_version" {
  type    = string
  default = "6.3.0"
}

variable "tags" {
  type    = map(string)
  default = {}
}
