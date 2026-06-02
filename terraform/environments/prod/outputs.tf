output "vpc_id" {
  value = module.networking.vpc_id
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "ecr_repository_urls" {
  value = module.ecr.repository_urls
}

output "rds_endpoint" {
  value     = module.rds.db_endpoint
  sensitive = true
}

output "redis_endpoint" {
  value     = module.elasticache.redis_endpoint
  sensitive = true
}

output "app_storage_bucket" {
  value = module.s3.app_storage_bucket_name
}

output "velero_bucket" {
  value = module.s3.velero_bucket_name
}

output "acm_certificate_arn" {
  value = module.alb_controller.acm_certificate_arn
}

output "monitoring_namespace" {
  value = module.monitoring.monitoring_namespace
}

output "logging_namespace" {
  value = module.logging.logging_namespace
}

output "github_actions_role_arn" {
  value = module.iam.github_actions_role_arn
}

output "waf_web_acl_arn" {
  value = module.waf.waf_web_acl_arn
}

output "secrets_arns" {
  description = "Secrets Manager ARNs to populate manually after deploy"
  value = {
    rds     = module.secrets.rds_secret_arn
    redis   = module.secrets.redis_secret_arn
    grafana = module.secrets.grafana_secret_arn
  }
}
