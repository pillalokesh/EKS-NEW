# qa.tfvars

aws_region   = "us-east-1"
environment  = "qa"
project_name = "eks-platform"
cluster_name = "eks-platform-qa"
owner        = "platform-team"

vpc_cidr             = "10.2.0.0/16"
public_subnet_cidrs  = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
private_subnet_cidrs = ["10.2.11.0/24", "10.2.12.0/24", "10.2.13.0/24"]

eks_cluster_version = "1.29"

system_node_instance_types = ["t3.medium"]
system_node_desired        = 2
system_node_min            = 1
system_node_max            = 3

app_node_instance_types = ["t3.large"]
app_node_capacity_type  = "SPOT"
app_node_desired        = 2
app_node_min            = 1
app_node_max            = 8

ecr_repositories = ["frontend", "user-service", "product-service", "order-service", "payment-service"]

rds_instance_class = "db.t3.medium"

redis_node_type          = "cache.t3.small"
redis_num_cache_clusters = 2

domain_name        = "qa.example.com"
create_hosted_zone = false

waf_rate_limit = 3000

prometheus_retention    = "7d"
prometheus_storage_size = "30Gi"
log_retention_days      = 14

github_org  = "your-github-org"
github_repo = "your-repo-name"
