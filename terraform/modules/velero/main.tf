###############################################################
# Velero Module — Installs Velero via Helm with S3 backend + IRSA
###############################################################

data "aws_region" "current" {}

resource "kubernetes_namespace" "velero" {
  metadata {
    name = "velero"
    labels = {
      name                           = "velero"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "helm_release" "velero" {
  name       = "velero"
  repository = "https://vmware-tanzu.github.io/helm-charts"
  chart      = "velero"
  version    = var.velero_chart_version
  namespace  = kubernetes_namespace.velero.metadata[0].name

  values = [templatefile("${path.module}/../../helm/velero/values.yaml", {
    bucket   = var.velero_bucket_name
    region   = data.aws_region.current.name
    role_arn = var.velero_role_arn
  })]

  set {
    name  = "serviceAccount.server.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.velero_role_arn
  }

  set {
    name  = "configuration.backupStorageLocation[0].bucket"
    value = var.velero_bucket_name
  }

  set {
    name  = "configuration.backupStorageLocation[0].config.region"
    value = data.aws_region.current.name
  }

  set {
    name  = "configuration.volumeSnapshotLocation[0].config.region"
    value = data.aws_region.current.name
  }

  set {
    name  = "initContainers[0].name"
    value = "velero-plugin-for-aws"
  }

  set {
    name  = "initContainers[0].image"
    value = "velero/velero-plugin-for-aws:v1.9.0"
  }

  set {
    name  = "initContainers[0].volumeMounts[0].mountPath"
    value = "/target"
  }

  set {
    name  = "initContainers[0].volumeMounts[0].name"
    value = "plugins"
  }

  depends_on = [kubernetes_namespace.velero]
}
