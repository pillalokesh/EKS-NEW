#!/usr/bin/env bash
# populate-secrets.sh
# Populates AWS Secrets Manager secret values after terraform apply.
# Run ONCE per environment after infrastructure is deployed.
# Usage: ./scripts/populate-secrets.sh <dev|qa|uat|prod>
set -euo pipefail

ENV="${1:?Usage: $0 <dev|qa|uat|prod>}"
CLUSTER_NAME="eks-platform-${ENV}"
REGION="${AWS_REGION:-us-east-1}"

echo "==> Populating Secrets Manager for cluster: ${CLUSTER_NAME}"

# ─── RDS Credentials ─────────────────────────────────────────
RDS_SECRET="${CLUSTER_NAME}/rds/master-credentials"
echo -n "Enter RDS master username: "
read -r RDS_USER
echo -n "Enter RDS master password: "
read -rs RDS_PASS
echo

aws secretsmanager put-secret-value \
  --region "${REGION}" \
  --secret-id "${RDS_SECRET}" \
  --secret-string "{\"username\":\"${RDS_USER}\",\"password\":\"${RDS_PASS}\"}" \
  --output text --query 'Name'

echo "  [OK] ${RDS_SECRET}"

# ─── Grafana Admin ───────────────────────────────────────────
GRAFANA_SECRET="${CLUSTER_NAME}/monitoring/grafana-admin"
echo -n "Enter Grafana admin password: "
read -rs GRAFANA_PASS
echo

aws secretsmanager put-secret-value \
  --region "${REGION}" \
  --secret-id "${GRAFANA_SECRET}" \
  --secret-string "{\"username\":\"admin\",\"password\":\"${GRAFANA_PASS}\"}" \
  --output text --query 'Name'

echo "  [OK] ${GRAFANA_SECRET}"

# ─── Redis Auth Token (optional) ─────────────────────────────
REDIS_SECRET="${CLUSTER_NAME}/redis/auth-token"
echo -n "Enter Redis auth token (leave blank to skip): "
read -rs REDIS_TOKEN
echo

if [[ -n "${REDIS_TOKEN}" ]]; then
  aws secretsmanager put-secret-value \
    --region "${REGION}" \
    --secret-id "${REDIS_SECRET}" \
    --secret-string "{\"auth_token\":\"${REDIS_TOKEN}\"}" \
    --output text --query 'Name'
  echo "  [OK] ${REDIS_SECRET}"
else
  echo "  [SKIP] Redis auth token not set"
fi

echo ""
echo "==> Secrets populated successfully for [${ENV}]"
echo "    Retrieve ARNs with: terraform output secrets_arns"
