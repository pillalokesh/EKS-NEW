output "rds_secret_arn" {
  description = "ARN of the RDS credentials secret — populate value manually"
  value       = aws_secretsmanager_secret.rds.arn
}

output "redis_secret_arn" {
  description = "ARN of the Redis auth token secret — populate value manually"
  value       = aws_secretsmanager_secret.redis.arn
}

output "grafana_secret_arn" {
  description = "ARN of the Grafana admin secret — populate value manually"
  value       = aws_secretsmanager_secret.grafana.arn
}
