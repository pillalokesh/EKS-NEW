output "acm_certificate_arn" {
  value = aws_acm_certificate.main.arn
}

output "route53_zone_id" {
  value = local.zone_id
}

output "route53_zone_name_servers" {
  value = var.create_hosted_zone ? aws_route53_zone.main[0].name_servers : []
}
