output "acm_certificate_arn" {
  description = "ARN of the ACM certificate for the domain"
  value       = aws_acm_certificate.main.arn
}

output "acm_certificate_status" {
  description = "Status of the ACM certificate (should be ISSUED after validation)"
  value       = aws_acm_certificate_validation.main.id
}

output "route53_zone_id" {
  description = "Route53 hosted zone ID used for DNS validation"
  value       = local.zone_id
}

output "route53_zone_name_servers" {
  description = "Name servers for the hosted zone (only populated when create_hosted_zone = true)"
  value       = var.create_hosted_zone ? aws_route53_zone.main[0].name_servers : tolist([])
}

output "alb_controller_helm_status" {
  description = "Helm release status of the AWS Load Balancer Controller"
  value       = helm_release.alb_controller.status
}

output "cluster_autoscaler_helm_status" {
  description = "Helm release status of the Cluster Autoscaler"
  value       = helm_release.cluster_autoscaler.status
}

output "metrics_server_helm_status" {
  description = "Helm release status of the Metrics Server"
  value       = helm_release.metrics_server.status
}
