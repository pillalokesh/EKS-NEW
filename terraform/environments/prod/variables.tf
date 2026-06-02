# ─── General ─────────────────────────────────────────────────
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type    = string
  default = "prod"
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
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

# ─── EKS ─────────────────────────────────────────────────────
variable "eks_cluster_version" {
  type    = string
  default = "1.29"
}

variable "system_node_instance_types" {
  type    = list(string)
  default = ["m5.large"]
}

variable "system_node_desired" { type = number; default = 2 }
variable "system_node_min"     { type = number; default = 2 }
variable "system_node_max"     { type = number; default = 4 }

variable "app_node_instance_types" {
  type    = list(string)
  default = ["m5.xlarge"]
}

variable "app_node_capacity_type" {
  type    = string
  default = "ON_DEMAND"
}

variable "app_node_desired" { type = number; default = 3 }
variable "app_node_min"     { type = number; default = 3 }
variable "app_node_max"     { type = number; default = 20 }

# ─── ECR ─────────────────────────────────────────────────────
variable "ecr_repositories" {
  type    = list(string)
  default = ["frontend", "user-service", "product-service", "order-service", "payment-service"]
}

# ─── RDS ─────────────────────────────────────────────────────
variable "rds_instance_class" {
  type    = string
  default = "db.r6g.large"
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
  default = "cache.r6g.large"
}

variable "redis_num_cache_clusters" {
  type    = number
  default = 3
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
  default = 2000
}

# ─── Monitoring ──────────────────────────────────────────────
variable "grafana_admin_password" {
  type      = string
  sensitive = true
}

variable "prometheus_retention" {
  type    = string
  default = "30d"
}

variable "prometheus_storage_size" {
  type    = string
  default = "100Gi"
}

# ─── Logging ─────────────────────────────────────────────────
variable "log_retention_days" {
  type    = number
  default = 90
}

# ─── GitHub Actions ──────────────────────────────────────────
variable "github_org" {
  type = string
}

variable "github_repo" {
  type = string
}
