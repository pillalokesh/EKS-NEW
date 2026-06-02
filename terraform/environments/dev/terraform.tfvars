# dev.tfvars - Development environment (cost-optimized)

aws_region   = "us-east-1"
environment  = "dev"
project_name = "eks-platform"
cluster_name = "eks-platform-dev"
owner        = "platform-team"

vpc_cidr             = "10.1.0.0/16"
public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
private_subnet_cidrs = ["10.1.11.0/24", "10.1.12.0/24", "10.1.13.0/24"]

eks_cluster_version = "1.29"

system_node_instance_types = ["t3.medium"]
system_node_desired        = 1
system_node_min            = 1
system_node_max            = 2

app_node_instance_types = ["t3.large"]
app_node_capacity_type  = "SPOT"
app_node_desired        = 2
app_node_min            = 1
app_node_max            = 5

ecr_repositories = ["frontend", "user-service", "product-service", "order-service", "payment-service"]

rds_instance_class = "db.t3.small"

redis_node_type          = "cache.t3.micro"
redis_num_cache_clusters = 2

domain_name        = "dev.example.com"
create_hosted_zone = false

waf_rate_limit = 5000

prometheus_retention    = "7d"
prometheus_storage_size = "20Gi"
log_retention_days      = 7

github_org  = "your-github-org"
github_repo = "your-repo-name"
