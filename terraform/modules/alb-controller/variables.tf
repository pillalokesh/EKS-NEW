variable "cluster_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "domain_name" {
  description = "Primary domain name for ACM certificate and Route53"
  type        = string
}

variable "create_hosted_zone" {
  description = "Set to true to create a new Route53 hosted zone"
  type        = bool
  default     = false
}

variable "alb_controller_role_arn" {
  type = string
}

variable "cluster_autoscaler_role_arn" {
  type = string
}

variable "alb_controller_chart_version" {
  type    = string
  default = "1.7.1"
}

variable "metrics_server_chart_version" {
  type    = string
  default = "3.12.0"
}

variable "cluster_autoscaler_chart_version" {
  type    = string
  default = "9.36.0"
}

variable "tags" {
  type    = map(string)
  default = {}
}
