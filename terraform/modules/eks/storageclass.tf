###############################################################
# StorageClass
# Creates gp3 as the cluster default StorageClass.
# Required for: Prometheus, Grafana, and any PVC workload.
###############################################################
# Patch the existing gp2 default off so gp3 becomes the default
resource "kubernetes_annotations" "gp2_non_default" {
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  metadata {
    name = "gp2"
  }
  annotations = {
    "storageclass.kubernetes.io/is-default-class" = "false"
  }
  force = true
}

resource "kubernetes_storage_class_v1" "gp3" {
  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Retain"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true

  parameters = {
    type      = "gp3"
    encrypted = "true"
    fsType    = "ext4"
  }

  depends_on = [kubernetes_annotations.gp2_non_default]
}

# io1 StorageClass for high-IOPS workloads (opt-in)
resource "kubernetes_storage_class_v1" "io1" {
  metadata {
    name = "io1"
  }

  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Retain"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true

  parameters = {
    type      = "io1"
    iopsPerGB = "50"
    encrypted = "true"
    fsType    = "ext4"
  }
}
