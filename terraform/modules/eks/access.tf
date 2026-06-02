###############################################################
# EKS Access Entries
# Grants kubectl/API access to IAM roles without aws-auth ConfigMap.
# Required for EKS clusters using Access Entries API (v1.29+).
###############################################################

variable "github_actions_role_arn" {
  description = "GitHub Actions IAM role ARN that needs EKS access for CI/CD deployments"
  type        = string
  default     = ""
}

variable "admin_iam_role_arns" {
  description = "List of IAM role ARNs granted cluster-admin access (e.g. your ops team roles)"
  type        = list(string)
  default     = []
}

# GitHub Actions — needs deploy access
resource "aws_eks_access_entry" "github_actions" {
  count         = var.github_actions_role_arn != "" ? 1 : 0
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = var.github_actions_role_arn
  type          = "STANDARD"
  tags          = var.tags
}

resource "aws_eks_access_policy_association" "github_actions" {
  count         = var.github_actions_role_arn != "" ? 1 : 0
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = var.github_actions_role_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.github_actions]
}

# Admin roles — full cluster-admin
resource "aws_eks_access_entry" "admins" {
  for_each      = toset(var.admin_iam_role_arns)
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = each.value
  type          = "STANDARD"
  tags          = var.tags
}

resource "aws_eks_access_policy_association" "admins" {
  for_each      = toset(var.admin_iam_role_arns)
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = each.value
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.admins]
}
