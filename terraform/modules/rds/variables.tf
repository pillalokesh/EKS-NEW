variable "cluster_name" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "rds_sg_id" {
  type = string
}

variable "kms_key_arn" {
  type = string
}

variable "engine_version" {
  type    = string
  default = "8.0.35"
}

variable "instance_class" {
  type    = string
  default = "db.t3.medium"
}

variable "allocated_storage" {
  type    = number
  default = 100
}

variable "max_allocated_storage" {
  type    = number
  default = 500
}

variable "database_name" {
  description = "Initial database name (infrastructure only, no schemas created)"
  type        = string
  default     = "platform"
}

variable "master_username" {
  description = "RDS master username - store in secrets manager"
  type        = string
  sensitive   = true
}

variable "master_password" {
  description = "RDS master password - store in secrets manager"
  type        = string
  sensitive   = true
}

variable "backup_retention_period" {
  type    = number
  default = 7
}

variable "deletion_protection" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
