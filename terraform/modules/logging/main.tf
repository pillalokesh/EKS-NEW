###############################################################
# Logging Module — Fluent Bit + CloudWatch Log Groups
###############################################################

data "aws_region" "current" {}

resource "kubernetes_namespace" "logging" {
  metadata {
    name = "logging"
    labels = {
      name                           = "logging"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "aws_cloudwatch_log_group" "application" {
  name              = "/eks/${var.cluster_name}/application"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "system" {
  name              = "/eks/${var.cluster_name}/system"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "dataplane" {
  name              = "/eks/${var.cluster_name}/dataplane"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn
  tags              = var.tags
}

resource "helm_release" "fluent_bit" {
  name       = "fluent-bit"
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluent-bit"
  version    = var.fluent_bit_chart_version
  namespace  = kubernetes_namespace.logging.metadata[0].name

  values = [templatefile("${path.module}/../../helm/logging/fluent-bit-values.yaml", {
    cluster_name = var.cluster_name
    region       = data.aws_region.current.name
    log_group    = aws_cloudwatch_log_group.application.name
  })]

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "fluent-bit"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.fluent_bit_role_arn
  }

  depends_on = [kubernetes_namespace.logging]
}
