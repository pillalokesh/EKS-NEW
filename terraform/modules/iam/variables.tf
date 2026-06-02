variable "cluster_name" {
  type = string
}

variable "oidc_issuer_url" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

# Map of IRSA role name -> { namespace, service_account }
variable "irsa_roles" {
  type = map(object({
    namespace       = string
    service_account = string
  }))
  default = {
    "alb-controller" = {
      namespace       = "kube-system"
      service_account = "aws-load-balancer-controller"
    }
    "velero" = {
      namespace       = "velero"
      service_account = "velero"
    }
    "fluent-bit" = {
      namespace       = "logging"
      service_account = "fluent-bit"
    }
    "external-dns" = {
      namespace       = "kube-system"
      service_account = "external-dns"
    }
  }
}

variable "velero_bucket_arn" {
  type = string
}

variable "secrets_kms_key_arn" {
  type = string
}

variable "github_org" {
  description = "GitHub organization name"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
