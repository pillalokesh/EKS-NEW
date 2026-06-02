# Architecture Diagrams

## 1. High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                          AWS Cloud (us-east-1)                       │
│                                                                       │
│   ┌──────────┐    ┌──────────────────────────────────────────────┐   │
│   │ Route53  │───▶│            CloudFront (optional)             │   │
│   └──────────┘    └──────────────────────────────────────────────┘   │
│                                         │                             │
│   ┌─────────────────────────────────────▼──────────────────────┐     │
│   │                    WAF v2 Web ACL                          │     │
│   └─────────────────────────────────────┬──────────────────────┘     │
│                                         │                             │
│   ┌─────────────────────────────────────▼──────────────────────┐     │
│   │              Application Load Balancer (ALB)               │     │
│   │              (AWS Load Balancer Controller)                 │     │
│   └─────────────────────────────────────┬──────────────────────┘     │
│                                         │                             │
│   ┌─────────────────────────────────────▼──────────────────────┐     │
│   │                    EKS Cluster                             │     │
│   │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │     │
│   │  │  System NG   │  │   App NG     │  │  App NG      │    │     │
│   │  │  (kube-sys,  │  │ (services)   │  │  (services)  │    │     │
│   │  │  monitoring) │  │  AZ-1        │  │  AZ-2/3      │    │     │
│   │  └──────────────┘  └──────────────┘  └──────────────┘    │     │
│   └───────────┬───────────────┬───────────────┬────────────────┘     │
│               │               │               │                       │
│   ┌───────────▼───┐  ┌────────▼────────┐  ┌──▼──────────────┐       │
│   │  RDS MySQL    │  │ ElastiCache     │  │   S3 Buckets    │       │
│   │  Multi-AZ     │  │ Redis (HA)      │  │ app + velero    │       │
│   └───────────────┘  └─────────────────┘  └─────────────────┘       │
│                                                                       │
│   ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────┐       │
│   │   ECR    │  │   KMS    │  │ Secrets  │  │  CloudWatch  │       │
│   │ (5 repos)│  │  (4 keys)│  │ Manager  │  │    Logs      │       │
│   └──────────┘  └──────────┘  └──────────┘  └──────────────┘       │
└─────────────────────────────────────────────────────────────────────┘
```

## 2. Network Architecture

```
VPC: 10.0.0.0/16
│
├── PUBLIC SUBNETS (Internet-facing)
│   ├── us-east-1a  10.0.1.0/24  ──┐
│   ├── us-east-1b  10.0.2.0/24  ──┼── IGW ──▶ Internet
│   └── us-east-1c  10.0.3.0/24  ──┘
│       │
│       ├── NAT Gateway AZ-a (EIP)
│       ├── NAT Gateway AZ-b (EIP)
│       └── NAT Gateway AZ-c (EIP)
│           │
├── PRIVATE SUBNETS (EKS + Databases)
│   ├── us-east-1a  10.0.11.0/24  ── Route ──▶ NAT GW AZ-a
│   ├── us-east-1b  10.0.12.0/24  ── Route ──▶ NAT GW AZ-b
│   └── us-east-1c  10.0.13.0/24  ── Route ──▶ NAT GW AZ-c
│
├── SECURITY GROUPS
│   ├── alb-sg:          0.0.0.0/0 → 80,443
│   ├── eks-cluster-sg:  alb-sg → 443
│   ├── eks-nodes-sg:    cluster-sg → 1025-65535, self-ref
│   ├── rds-sg:          nodes-sg → 3306
│   └── elasticache-sg:  nodes-sg → 6379
│
└── NACLs
    ├── public-nacl:  Allow 80,443 inbound; all outbound
    └── private-nacl: Allow VPC CIDR inbound; all outbound
```

## 3. EKS Architecture

```
EKS Control Plane (AWS Managed)
├── API Server (private + public endpoint)
├── etcd (encrypted with KMS)
├── Controller Manager
└── Scheduler
    │
    ├── System Node Group (ON_DEMAND, m5.large × 2-4)
    │   └── Workloads:
    │       ├── kube-system (CoreDNS, VPC CNI, kube-proxy)
    │       ├── monitoring  (Prometheus, Grafana, kube-state-metrics, node-exporter)
    │       ├── logging     (Fluent Bit)
    │       └── velero      (Velero)
    │
    └── Application Node Group (ON_DEMAND/SPOT, m5.xlarge × 3-20)
        └── Workloads: (YOUR microservices - managed manually)
            ├── frontend
            ├── user-service
            ├── product-service
            ├── order-service
            └── payment-service

EKS Addons:
├── vpc-cni       (IRSA: AmazonEKS_CNI_Policy)
├── coredns
├── kube-proxy
└── aws-ebs-csi-driver (IRSA: AmazonEBSCSIDriverPolicy)

Helm Releases (managed by Terraform):
├── aws-load-balancer-controller  (kube-system)
├── cluster-autoscaler            (kube-system)
├── metrics-server                (kube-system)
├── kube-prometheus-stack         (monitoring)
├── fluent-bit                    (logging)
└── velero                        (velero)
```

## 4. CI/CD Flow

```
Developer Push
     │
     ▼
GitHub Repository
     │
     ├── Push to develop/main
     │        │
     │        ▼
     │   GitHub Actions: build-push-ecr.yml
     │   ┌─────────────────────────────────┐
     │   │ 1. OIDC → Assume IAM Role       │
     │   │ 2. ECR Login                    │
     │   │ 3. Docker Build (Buildx)        │
     │   │ 4. Trivy Security Scan          │
     │   │ 5. Push to ECR                  │
     │   │    <project>/<service>:<tag>    │
     │   └─────────────────────────────────┘
     │                │
     │                ▼
     │   GitHub Actions: deploy-eks.yml
     │   ┌─────────────────────────────────┐
     │   │ 1. OIDC → Assume IAM Role       │
     │   │ 2. aws eks update-kubeconfig    │
     │   │ 3. kubectl set image            │
     │   │    (YOUR deployment manifests)  │
     │   │ 4. kubectl rollout status       │
     │   └─────────────────────────────────┘
     │
     └── PR to main (terraform changes)
              │
              ▼
         terraform.yml
         ┌─────────────────────────────────┐
         │ 1. terraform fmt check          │
         │ 2. terraform init               │
         │ 3. terraform validate           │
         │ 4. terraform plan (post to PR)  │
         │ 5. terraform apply (on merge)   │
         └─────────────────────────────────┘
```

## 5. Monitoring Flow

```
Kubernetes Cluster
     │
     ├── kube-state-metrics ──────────────────────────────┐
     ├── node-exporter (DaemonSet) ───────────────────────┤
     ├── Application Pods (/metrics endpoint) ────────────┤
     │                                                     │
     ▼                                                     ▼
Prometheus (scrapes metrics every 30s)            ServiceMonitor CRDs
     │
     ├── Stores TSDB (50-100Gi EBS gp3)
     ├── Evaluates AlertRules
     │        │
     │        ▼
     │   AlertManager ──▶ Slack/PagerDuty/Email (configure manually)
     │
     └──▶ Grafana (dashboards)
               │
               └── Pre-built dashboards:
                   ├── Kubernetes Cluster
                   ├── Node Exporter Full
                   ├── EKS cluster
                   └── Your custom dashboards
```

## 6. Logging Flow

```
Pod stdout/stderr
     │
     ▼
/var/log/containers/*.log (host path)
     │
     ▼
Fluent Bit DaemonSet (on every node)
     │
     ├── [FILTER] kubernetes  (enriches with pod/namespace metadata)
     │
     └── [OUTPUT] CloudWatch Logs
               │
               ├── /eks/<cluster>/application   (app logs)
               └── /eks/<cluster>/system        (kubelet logs)
                          │
                          ▼
                   CloudWatch Log Insights
                   (query, search, dashboards)
                          │
                          ▼
                   CloudWatch Alarms (configure manually)
```
