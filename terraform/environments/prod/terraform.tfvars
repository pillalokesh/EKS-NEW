# prod.tfvars - Production environment values
# DO NOT commit sensitive values. Use TF_VAR_* env vars or AWS Secrets Manager.

aws_region   = "us-east-1"
environment  = "prod"
project_name = "eks-platform"
cluster_name = "eks-platform-prod"
owner        = "platform-team"

# Networking
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

# EKS
eks_cluster_version = "1.29"

# Restrict EKS public API endpoint to your corporate/VPN egress IPs in production
# cluster_endpoint_public_access_cidrs = ["YOUR_VPN_CIDR/32"]

system_node_instance_types = ["m5.large"]
system_node_desired        = 2
system_node_min            = 2
system_node_max            = 4

app_node_instance_types = ["m5.xlarge"]
app_node_capacity_type  = "ON_DEMAND"
app_node_desired        = 3
app_node_min            = 3
app_node_max            = 20

# ECR
ecr_repositories = ["frontend", "user-service", "product-service", "order-service", "payment-service"]

# RDS
rds_instance_class = "db.r6g.large"
# rds_master_username and rds_master_password via TF_VAR_* environment variables

# Redis
redis_node_type          = "cache.r6g.large"
redis_num_cache_clusters = 3

# Domain
domain_name        = "example.com"   # Replace with your domain
create_hosted_zone = false

# WAF
waf_rate_limit = 2000

# Monitoring
prometheus_retention    = "30d"
prometheus_storage_size = "100Gi"
# grafana_admin_password via TF_VAR_grafana_admin_password

# Logging
log_retention_days = 90

# GitHub
github_org  = "your-github-org"   # Replace
github_repo = "your-repo-name"    # Replace
