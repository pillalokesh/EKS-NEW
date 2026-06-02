###############################################################
# prod environment - root module
# Wires all infrastructure modules together
###############################################################

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket         = "eks-platform-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "eks-platform-terraform-locks"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
    Owner       = var.owner
  }
}

# ─── KMS ─────────────────────────────────────────────────────
module "kms" {
  source       = "../../modules/kms"
  cluster_name = var.cluster_name
  tags         = local.common_tags
}

# ─── Networking ──────────────────────────────────────────────
module "networking" {
  source               = "../../modules/networking"
  cluster_name         = var.cluster_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = local.common_tags
}

# ─── EKS ─────────────────────────────────────────────────────
module "eks" {
  source             = "../../modules/eks"
  cluster_name       = var.cluster_name
  cluster_version    = var.eks_cluster_version
  vpc_id             = module.networking.vpc_id
  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids
  cluster_sg_id      = module.networking.eks_cluster_sg_id
  nodes_sg_id        = module.networking.eks_nodes_sg_id
  kms_key_arn        = module.kms.eks_kms_key_arn

  system_node_instance_types = var.system_node_instance_types
  system_node_desired        = var.system_node_desired
  system_node_min            = var.system_node_min
  system_node_max            = var.system_node_max

  app_node_instance_types = var.app_node_instance_types
  app_node_capacity_type  = var.app_node_capacity_type
  app_node_desired        = var.app_node_desired
  app_node_min            = var.app_node_min
  app_node_max            = var.app_node_max

  tags = local.common_tags
}

# ─── ECR ─────────────────────────────────────────────────────
module "ecr" {
  source           = "../../modules/ecr"
  project_name     = var.project_name
  repository_names = var.ecr_repositories
  kms_key_arn      = module.kms.s3_kms_key_arn
  node_role_arn    = module.eks.node_role_arn
  tags             = local.common_tags
}

# ─── S3 ──────────────────────────────────────────────────────
module "s3" {
  source       = "../../modules/s3"
  cluster_name = var.cluster_name
  kms_key_arn  = module.kms.s3_kms_key_arn
  tags         = local.common_tags
}

# ─── RDS ─────────────────────────────────────────────────────
module "rds" {
  source             = "../../modules/rds"
  cluster_name       = var.cluster_name
  private_subnet_ids = module.networking.private_subnet_ids
  rds_sg_id          = module.networking.rds_sg_id
  kms_key_arn        = module.kms.rds_kms_key_arn
  instance_class     = var.rds_instance_class
  master_username    = var.rds_master_username
  master_password    = var.rds_master_password
  deletion_protection = true
  tags               = local.common_tags
}

# ─── ElastiCache ─────────────────────────────────────────────
module "elasticache" {
  source             = "../../modules/elasticache"
  cluster_name       = var.cluster_name
  private_subnet_ids = module.networking.private_subnet_ids
  elasticache_sg_id  = module.networking.elasticache_sg_id
  node_type          = var.redis_node_type
  num_cache_clusters = var.redis_num_cache_clusters
  tags               = local.common_tags
}

# ─── IAM ─────────────────────────────────────────────────────
module "iam" {
  source            = "../../modules/iam"
  cluster_name      = var.cluster_name
  oidc_issuer_url   = module.eks.cluster_oidc_issuer
  oidc_provider_arn = module.eks.oidc_provider_arn
  velero_bucket_arn = module.s3.velero_bucket_arn
  secrets_kms_key_arn = module.kms.secrets_kms_key_arn
  github_org        = var.github_org
  github_repo       = var.github_repo
  tags              = local.common_tags
}

# ─── Secrets Manager ────────────────────────────────────────
module "secrets" {
  source        = "../../modules/secrets"
  cluster_name  = var.cluster_name
  kms_key_arn   = module.kms.secrets_kms_key_arn
  node_role_arn = module.eks.node_role_arn
  tags          = local.common_tags
}

# ─── WAF ─────────────────────────────────────────────────────
module "waf" {
  source       = "../../modules/waf"
  cluster_name = var.cluster_name
  rate_limit   = var.waf_rate_limit
  tags         = local.common_tags
}

# ─── ALB Controller + ACM + Autoscaler ───────────────────────
module "alb_controller" {
  source                    = "../../modules/alb-controller"
  cluster_name              = var.cluster_name
  vpc_id                    = module.networking.vpc_id
  domain_name               = var.domain_name
  create_hosted_zone        = var.create_hosted_zone
  alb_controller_role_arn   = module.iam.irsa_role_arns["alb-controller"]
  cluster_autoscaler_role_arn = module.eks.cluster_autoscaler_role_arn
  tags                      = local.common_tags

  depends_on = [module.eks]
}

# ─── Monitoring ──────────────────────────────────────────────
module "monitoring" {
  source                  = "../../modules/monitoring"
  grafana_admin_password  = var.grafana_admin_password
  prometheus_retention    = var.prometheus_retention
  prometheus_storage_size = var.prometheus_storage_size
  tags                    = local.common_tags

  depends_on = [module.eks, module.alb_controller]
}

# ─── Logging ─────────────────────────────────────────────────
module "logging" {
  source              = "../../modules/logging"
  cluster_name        = var.cluster_name
  fluent_bit_role_arn = module.iam.irsa_role_arns["fluent-bit"]
  kms_key_arn         = module.kms.secrets_kms_key_arn
  log_retention_days  = var.log_retention_days
  tags                = local.common_tags

  depends_on = [module.eks]
}

# ─── Velero ──────────────────────────────────────────────────
module "velero" {
  source              = "../../modules/velero"
  velero_bucket_name  = module.s3.velero_bucket_name
  velero_role_arn     = module.iam.irsa_role_arns["velero"]
  tags                = local.common_tags

  depends_on = [module.eks]
}
