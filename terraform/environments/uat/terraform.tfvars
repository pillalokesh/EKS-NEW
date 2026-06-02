# uat.tfvars

aws_region   = "us-east-1"
environment  = "uat"
project_name = "eks-platform"
cluster_name = "eks-platform-uat"
owner        = "platform-team"

vpc_cidr             = "10.3.0.0/16"
public_subnet_cidrs  = ["10.3.1.0/24", "10.3.2.0/24", "10.3.3.0/24"]
private_subnet_cidrs = ["10.3.11.0/24", "10.3.12.0/24", "10.3.13.0/24"]

eks_cluster_version                  = "1.29"
cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

system_node_instance_types = ["m5.large"]
system_node_desired        = 2
system_node_min            = 2
system_node_max            = 4

app_node_instance_types = ["m5.xlarge"]
app_node_capacity_type  = "ON_DEMAND"
app_node_desired        = 2
app_node_min            = 2
app_node_max            = 10

ecr_repositories = ["frontend", "user-service", "product-service", "order-service", "payment-service"]

rds_instance_class = "db.t3.large"

redis_node_type          = "cache.t3.medium"
redis_num_cache_clusters = 2

domain_name        = "uat.example.com"
create_hosted_zone = false

waf_rate_limit = 2000

prometheus_retention    = "15d"
prometheus_storage_size = "50Gi"
log_retention_days      = 30

github_org  = "your-github-org"
github_repo = "your-repo-name"
