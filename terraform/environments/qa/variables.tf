# ─── General ─────────────────────────────────────────────────
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type    = string
  default = "qa"
}

variable "project_name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "owner" {
  type    = string
  default = "platform-team"
}

# ─── Networking ──────────────────────────────────────────────
variable "vpc_cidr" {
  type    = string
  default = "10.2.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.2.11.0/24", "10.2.12.0/24", "10.2.13.0/24"]
}

# ─── EKS ─────────────────────────────────────────────────────
variable "eks_cluster_version" {
  type    = string
  default = "1.29"
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "Restrict EKS public API endpoint to these CIDRs."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "system_node_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "system_node_desired" { type = number; default = 2 }
variable "system_node_min"     { type = number; default = 1 }
variable "system_node_max"     { type = number; default = 3 }

variable "app_node_instance_types" {
  type    = list(string)
  default = ["t3.large"]
}

variable "app_node_capacity_type" {
  type    = string
  default = "SPOT"
}

variable "app_node_desired" { type = number; default = 2 }
variable "app_node_min"     { type = number; default = 1 }
variable "app_node_max"     { type = number; default = 8 }

# ─── ECR ─────────────────────────────────────────────────────
variable "ecr_repositories" {
  type    = list(string)
  default = ["frontend", "user-service", "product-service", "order-service", "payment-service"]
}

# ─── RDS ─────────────────────────────────────────────────────
variable "rds_instance_class" {
  type    = string
  default = "db.t3.medium"
}

variable "rds_master_username" {
  type      = string
  sensitive = true
}

variable "rds_master_password" {
  type      = string
  sensitive = true
}

# ─── Redis ───────────────────────────────────────────────────
variable "redis_node_type" {
  type    = string
  default = "cache.t3.small"
}

variable "redis_num_cache_clusters" {
  type    = number
  default = 2
}

# ─── Domain / ACM ────────────────────────────────────────────
variable "domain_name" {
  type = string
}

variable "create_hosted_zone" {
  type    = bool
  default = false
}

# ─── WAF ─────────────────────────────────────────────────────
variable "waf_rate_limit" {
  type    = number
  default = 3000
}

# ─── Monitoring ──────────────────────────────────────────────
variable "grafana_admin_password" {
  type      = string
  sensitive = true
}

variable "prometheus_retention" {
  type    = string
  default = "7d"
}

variable "prometheus_storage_size" {
  type    = string
  default = "30Gi"
}

# ─── Logging ─────────────────────────────────────────────────
variable "log_retention_days" {
  type    = number
  default = 14
}

# ─── GitHub Actions ──────────────────────────────────────────
variable "github_org" {
  type = string
}

variable "github_repo" {
  type = string
}
