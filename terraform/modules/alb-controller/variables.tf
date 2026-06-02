variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the EKS cluster lives"
  type        = string
}

variable "domain_name" {
  description = "Primary domain for ACM certificate and Route53 (e.g. example.com)"
  type        = string
}

variable "create_hosted_zone" {
  description = "true = create a new Route53 hosted zone. false = look up an existing zone by domain_name."
  type        = bool
  default     = false
}

variable "alb_controller_role_arn" {
  description = "IRSA role ARN for the AWS Load Balancer Controller service account"
  type        = string
}

variable "cluster_autoscaler_role_arn" {
  description = "IRSA role ARN for the Cluster Autoscaler service account"
  type        = string
}

variable "alb_controller_chart_version" {
  description = "Helm chart version for aws-load-balancer-controller"
  type        = string
  default     = "1.7.1"
}

variable "metrics_server_chart_version" {
  description = "Helm chart version for metrics-server"
  type        = string
  default     = "3.12.0"
}

variable "cluster_autoscaler_chart_version" {
  description = "Helm chart version for cluster-autoscaler"
  type        = string
  default     = "9.36.0"
}

variable "tags" {
  description = "Common tags applied to all taggable resources"
  type        = map(string)
  default     = {}
}
