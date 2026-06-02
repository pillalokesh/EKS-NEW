# Production-Grade AWS EKS Platform

A complete, enterprise-ready AWS EKS infrastructure built with Terraform, following the AWS Well-Architected Framework.

---

## What This Repository Provides

| Layer | Components |
|-------|-----------|
| Networking | VPC, IGW, 3× NAT GW, 6 subnets (3 public + 3 private), SGs, NACLs |
| Kubernetes | EKS Cluster, 2 managed node groups, Cluster Autoscaler, Metrics Server, EBS CSI |
| Registry | Amazon ECR (5 repositories, KMS encrypted, lifecycle policies) |
| Database | RDS MySQL Multi-AZ, encrypted, enhanced monitoring, automated backups |
| Cache | ElastiCache Redis HA, encrypted in-transit + at-rest |
| Storage | S3 app bucket + Velero backup bucket (versioned, KMS encrypted) |
| Security | KMS (4 keys), IAM/IRSA, Secrets Manager, WAF v2, GitHub OIDC |
| Ingress | AWS Load Balancer Controller, ACM Certificate, Route53 |
| Monitoring | Prometheus + Grafana + kube-state-metrics + node-exporter |
| Logging | Fluent Bit → CloudWatch Logs |
| Backup | Velero with S3 backend, daily schedule |
| CI/CD | GitHub Actions: build/push ECR, Terraform plan/apply, EKS deploy |

**Not included by design (you manage these):** Deployment YAMLs, Services, ConfigMaps, Secrets, Ingress rules, app-specific manifests.

---

## Prerequisites

| Tool | Version |
|------|---------|
| Terraform | >= 1.6.0 |
| AWS CLI | >= 2.x |
| kubectl | >= 1.29 |
| Helm | >= 3.14 |
| Docker | >= 24.x |

### AWS Requirements

- AWS account with Administrator access (for initial setup)
- A registered domain name (for ACM + Route53)
- GitHub repository (for OIDC-based CI/CD)

---

## Deployment Order

### Step 1 — Bootstrap Remote State (Once)

```bash
# Set environment variables
export AWS_REGION=us-east-1
export STATE_BUCKET=eks-platform-terraform-state

# Bootstrap S3 + DynamoDB
./scripts/bootstrap.sh
```

### Step 2 — Configure Variables

Edit `terraform/environments/<env>/terraform.tfvars`:

```hcl
project_name = "eks-platform"
cluster_name = "eks-platform-prod"
domain_name  = "yourdomain.com"
github_org   = "your-org"
github_repo  = "your-repo"
```

Set sensitive variables as environment variables (never commit these):

```bash
export TF_VAR_rds_master_username="admin"
export TF_VAR_rds_master_password="<strong-password>"
export TF_VAR_grafana_admin_password="<strong-password>"
```

### Step 3 — Deploy dev First

```bash
cd terraform/environments/dev

terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

### Step 4 — Update kubeconfig

```bash
./scripts/kubeconfig.sh dev
kubectl get nodes
```

### Step 5 — Verify Platform Components

```bash
# Check system components
kubectl get pods -n kube-system
kubectl get pods -n monitoring
kubectl get pods -n logging
kubectl get pods -n velero

# Check ALB controller
kubectl get deployment -n kube-system aws-load-balancer-controller

# Check Cluster Autoscaler
kubectl get deployment -n kube-system cluster-autoscaler
```

### Step 6 — Configure GitHub Actions Secrets

In your GitHub repository settings → Secrets, add:

| Secret | Value |
|--------|-------|
| `AWS_ACCOUNT_ID` | Your AWS account ID |
| `AWS_GITHUB_ACTIONS_ROLE_ARN` | Output from `module.iam.github_actions_role_arn` |
| `RDS_MASTER_USERNAME` | RDS admin username |
| `RDS_MASTER_PASSWORD` | RDS admin password |
| `GRAFANA_ADMIN_PASSWORD` | Grafana admin password |

### Step 7 — Deploy to Higher Environments

```bash
# QA
./scripts/deploy-env.sh qa plan
./scripts/deploy-env.sh qa apply

# UAT
./scripts/deploy-env.sh uat plan
./scripts/deploy-env.sh uat apply

# Production
./scripts/deploy-env.sh prod plan
./scripts/deploy-env.sh prod apply
```

---

## Environment CIDR Summary

| Environment | VPC CIDR | Public Subnets | Private Subnets |
|-------------|----------|----------------|-----------------|
| dev | 10.1.0.0/16 | 10.1.1-3.0/24 | 10.1.11-13.0/24 |
| qa | 10.2.0.0/16 | 10.2.1-3.0/24 | 10.2.11-13.0/24 |
| uat | 10.3.0.0/16 | 10.3.1-3.0/24 | 10.3.11-13.0/24 |
| prod | 10.0.0.0/16 | 10.0.1-3.0/24 | 10.0.11-13.0/24 |

---

## Node Group Sizing

| Environment | System Nodes | App Nodes | Instance Types |
|-------------|-------------|-----------|----------------|
| dev | 1-2 | 1-5 SPOT | t3.medium / t3.large |
| qa | 1-3 | 1-8 SPOT | t3.medium / t3.large |
| uat | 2-4 | 2-10 ON_DEMAND | m5.large / m5.xlarge |
| prod | 2-4 | 3-20 ON_DEMAND | m5.large / m5.xlarge |

---

## After Platform Deployment — Your Responsibilities

Create and apply these manually in your namespaces:

1. **Namespace structure** — Create your app namespaces (e.g., `dev`, `staging`, `prod`)
2. **Deployment YAMLs** — Define your microservice pods
3. **Service YAMLs** — ClusterIP / NodePort services
4. **Ingress rules** — Use the ALB Controller IngressClass `alb`
5. **ConfigMaps** — Non-sensitive app configuration
6. **Secrets** — Reference values from AWS Secrets Manager
7. **HPA/KEDA** — Horizontal Pod Autoscaler rules
8. **PodDisruptionBudgets** — Availability guarantees

---

## Key Outputs

After `terraform apply` these outputs are available:

```bash
terraform output cluster_name
terraform output cluster_endpoint
terraform output ecr_repository_urls
terraform output acm_certificate_arn
terraform output github_actions_role_arn
terraform output -raw rds_endpoint     # sensitive
terraform output -raw redis_endpoint   # sensitive
```

---

## Accessing Monitoring

```bash
# Port-forward Grafana
kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring

# Default URL: http://localhost:3000
# Username: admin
# Password: (your TF_VAR_grafana_admin_password)
```

---

## Backup Strategy

Velero runs daily at 02:00 UTC, backing up all namespaces except `kube-system`, `monitoring`, `logging`.
Backups are retained for 30 days in the Velero S3 bucket.

Manual backup:
```bash
velero backup create manual-backup-$(date +%Y%m%d) --include-namespaces <your-namespace>
```

---

## Security Notes

- All EBS volumes, RDS, ElastiCache, S3, and ECR use KMS encryption
- Secrets Manager is provisioned for infrastructure use; store all app secrets there manually
- WAF protects the ALB with OWASP common rules, bad input rules, SQLi rules, and rate limiting
- ECR images are scanned on push with native ECR scanning
- Trivy scans are run in CI before push
- GitHub Actions uses OIDC (no long-lived AWS credentials)
- EKS control plane logs are shipped to CloudWatch
- RDS deletion protection is enabled in prod/uat

---

## Folder Structure

```
.
├── .github/
│   └── workflows/
│       ├── build-push-ecr.yml      # Docker build + ECR push
│       ├── terraform.yml           # Terraform plan/apply
│       ├── deploy-eks.yml          # kubectl deploy to EKS
│       └── ci-pipeline.yml         # Orchestrator
├── terraform/
│   ├── backend/                    # Bootstrap: S3 + DynamoDB
│   ├── modules/
│   │   ├── networking/             # VPC, subnets, SGs, NACLs
│   │   ├── eks/                    # EKS cluster, node groups, addons
│   │   ├── ecr/                    # ECR repositories
│   │   ├── kms/                    # KMS keys (4)
│   │   ├── rds/                    # MySQL Multi-AZ
│   │   ├── elasticache/            # Redis HA
│   │   ├── s3/                     # App storage + Velero
│   │   ├── iam/                    # IRSA roles, GitHub OIDC
│   │   ├── alb-controller/         # ALB Controller, ACM, Autoscaler
│   │   ├── monitoring/             # Prometheus + Grafana
│   │   ├── logging/                # Fluent Bit + CloudWatch
│   │   ├── velero/                 # Velero backup
│   │   └── waf/                    # WAFv2
│   └── environments/
│       ├── dev/
│       ├── qa/
│       ├── uat/
│       └── prod/
├── helm/
│   ├── monitoring/                 # Prometheus stack values
│   ├── logging/                    # Fluent Bit values
│   ├── velero/                     # Velero values
│   └── alb-controller/             # ALB Controller values
├── scripts/
│   ├── bootstrap.sh                # One-time backend setup
│   ├── deploy-env.sh               # Deploy environment
│   └── kubeconfig.sh               # Update kubeconfig
└── docs/
    └── diagrams/
        └── architecture.md         # All architecture diagrams
```
