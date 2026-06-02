variable "prometheus_stack_version" {
  type    = string
  default = "56.6.2"
}

variable "grafana_admin_password" {
  description = "Grafana admin password - use a strong password, managed via secrets manager"
  type        = string
  sensitive   = true
}

variable "prometheus_retention" {
  type    = string
  default = "15d"
}

variable "prometheus_storage_size" {
  type    = string
  default = "50Gi"
}

variable "grafana_storage_size" {
  type    = string
  default = "10Gi"
}

variable "storage_class" {
  type    = string
  default = "gp3"
}

variable "tags" {
  type    = map(string)
  default = {}
}
