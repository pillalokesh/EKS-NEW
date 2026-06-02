variable "cluster_name" {
  type = string
}

variable "kms_key_arn" {
  type = string
}

variable "force_destroy" {
  type    = bool
  default = false
}

variable "velero_backup_retention_days" {
  description = "Days to retain Velero backups in S3"
  type        = number
  default     = 30
}

variable "tags" {
  type    = map(string)
  default = {}
}
