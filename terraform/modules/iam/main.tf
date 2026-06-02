###############################################################
# IAM Module
# Creates: IRSA roles for ALB Controller, External DNS,
#          Velero, Secrets Manager CSI, CloudWatch Agent,
#          Fluent Bit, and application workloads
###############################################################

locals {
  oidc_provider = replace(var.oidc_issuer_url, "https://", "")
}

# ─── Helper: IRSA assume-role policy factory ─────────────────
data "aws_iam_policy_document" "irsa_assume" {
  for_each = var.irsa_roles

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider}:sub"
      values   = ["system:serviceaccount:${each.value.namespace}:${each.value.service_account}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "irsa" {
  for_each           = var.irsa_roles
  name               = "${var.cluster_name}-${each.key}-irsa"
  assume_role_policy = data.aws_iam_policy_document.irsa_assume[each.key].json
  tags               = var.tags
}

# ─── ALB Controller Policy ───────────────────────────────────
resource "aws_iam_policy" "alb_controller" {
  name        = "${var.cluster_name}-alb-controller"
  description = "AWS Load Balancer Controller IAM policy"
  policy      = file("${path.module}/policies/alb-controller-policy.json")
}

resource "aws_iam_role_policy_attachment" "alb_controller" {
  role       = aws_iam_role.irsa["alb-controller"].name
  policy_arn = aws_iam_policy.alb_controller.arn
}

# ─── Velero Policy ───────────────────────────────────────────
resource "aws_iam_policy" "velero" {
  name        = "${var.cluster_name}-velero"
  description = "Velero backup IAM policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeVolumes", "ec2:DescribeSnapshots",
          "ec2:CreateTags", "ec2:CreateVolume",
          "ec2:CreateSnapshot", "ec2:DeleteSnapshot"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject", "s3:DeleteObject", "s3:PutObject",
          "s3:AbortMultipartUpload", "s3:ListMultipartUploadParts"
        ]
        Resource = "${var.velero_bucket_arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = var.velero_bucket_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "velero" {
  role       = aws_iam_role.irsa["velero"].name
  policy_arn = aws_iam_policy.velero.arn
}

# ─── Fluent Bit / CloudWatch Policy ──────────────────────────
resource "aws_iam_policy" "fluent_bit" {
  name        = "${var.cluster_name}-fluent-bit"
  description = "Fluent Bit CloudWatch Logs policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "cloudwatch:PutMetricData",
        "ec2:DescribeVolumes",
        "ec2:DescribeTags",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams",
        "logs:DescribeLogGroups",
        "logs:CreateLogStream",
        "logs:CreateLogGroup"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "fluent_bit" {
  role       = aws_iam_role.irsa["fluent-bit"].name
  policy_arn = aws_iam_policy.fluent_bit.arn
}

# ─── Secrets Manager Read Policy ─────────────────────────────
resource "aws_iam_policy" "secrets_reader" {
  name        = "${var.cluster_name}-secrets-reader"
  description = "Allow workloads to read secrets from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:secretsmanager:*:*:secret:${var.cluster_name}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = var.secrets_kms_key_arn
      }
    ]
  })
}

# ─── GitHub Actions OIDC (CI/CD) ─────────────────────────────
data "aws_caller_identity" "current" {}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = var.tags
}

resource "aws_iam_role" "github_actions" {
  name = "${var.cluster_name}-github-actions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github_actions.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:*"
        }
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_policy" "github_actions" {
  name        = "${var.cluster_name}-github-actions"
  description = "GitHub Actions CI/CD permissions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions.arn
}
