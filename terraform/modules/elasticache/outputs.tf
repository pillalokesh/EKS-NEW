output "redis_endpoint" {
  value     = aws_elasticache_replication_group.main.primary_endpoint_address
  sensitive = true
}

output "redis_reader_endpoint" {
  value     = aws_elasticache_replication_group.main.reader_endpoint_address
  sensitive = true
}

output "redis_port" {
  value = aws_elasticache_replication_group.main.port
}

output "redis_replication_group_id" {
  value = aws_elasticache_replication_group.main.id
}
