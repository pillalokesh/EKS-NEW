###############################################################
# Secrets Manager Module
# Creates infrastructure-level secret containers (shells only).
# Values are intentionally empty — populate manually post-deploy.
# Application secrets are NOT managed here.
###############################################################

data "aws_caller_identity" "current" {}

resource "aws_secretsmanager_secret" "rds" {
  name                    = "${var.cluster_name}/rds/master-credentials"
  description             = "RDS master credentials placeholder - populate manually"
  kms_key_id              = var.kms_key_arn
  recovery_window_in_days = var.recovery_window

  tags = merge(var.tags, { Type = "infrastructure" })
}

resource "aws_secretsmanager_secret" "redis" {
  name                    = "${var.cluster_name}/redis/auth-token"
  description             = "ElastiCache Redis auth token placeholder - populate manually"
  kms_key_id              = var.kms_key_arn
  recovery_window_in_days = var.recovery_window

  tags = merge(var.tags, { Type = "infrastructure" })
}

resource "aws_secretsmanager_secret" "grafana" {
  name                    = "${var.cluster_name}/monitoring/grafana-admin"
  description             = "Grafana admin credentials placeholder - populate manually"
  kms_key_id              = var.kms_key_arn
  recovery_window_in_days = var.recovery_window

  tags = merge(var.tags, { Type = "infrastructure" })
}

# Resource policy: only EKS node role can read secrets, deny cross-account
resource "aws_secretsmanager_secret_policy" "rds" {
  secret_arn = aws_secretsmanager_secret.rds.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEKSNodesRead"
        Effect = "Allow"
        Principal = { AWS = var.node_role_arn }
        Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
        Resource = "*"
      },
      {
        Sid    = "DenyExternalAccess"
        Effect = "Deny"
        Principal = { AWS = "*" }
        Action   = "secretsmanager:*"
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:PrincipalAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}
