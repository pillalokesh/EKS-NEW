output "logging_namespace" {
  value = kubernetes_namespace.logging.metadata[0].name
}

output "application_log_group" {
  value = aws_cloudwatch_log_group.application.name
}

output "system_log_group" {
  value = aws_cloudwatch_log_group.system.name
}
