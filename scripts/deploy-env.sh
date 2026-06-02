#!/usr/bin/env bash
# deploy-env.sh
# Usage: ./scripts/deploy-env.sh <env> <action>
# Example: ./scripts/deploy-env.sh prod plan
set -euo pipefail

ENV="${1:?Usage: $0 <dev|qa|uat|prod> <plan|apply|destroy>}"
ACTION="${2:?Usage: $0 <dev|qa|uat|prod> <plan|apply|destroy>}"

if [[ "$ACTION" == "destroy" && "$ENV" == "prod" ]]; then
  echo "ERROR: destroy is not allowed on prod via script. Use manual process."
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="$SCRIPT_DIR/../terraform/environments/$ENV"

echo "==> Terraform $ACTION on [$ENV]"
cd "$TF_DIR"

terraform init -upgrade

case "$ACTION" in
  plan)
    terraform plan \
      -var-file="terraform.tfvars" \
      -var="rds_master_username=${TF_VAR_rds_master_username:?Set TF_VAR_rds_master_username}" \
      -var="rds_master_password=${TF_VAR_rds_master_password:?Set TF_VAR_rds_master_password}" \
      -var="grafana_admin_password=${TF_VAR_grafana_admin_password:?Set TF_VAR_grafana_admin_password}" \
      -out=tfplan
    ;;
  apply)
    terraform apply tfplan
    ;;
  destroy)
    terraform destroy \
      -var-file="terraform.tfvars" \
      -var="rds_master_username=${TF_VAR_rds_master_username}" \
      -var="rds_master_password=${TF_VAR_rds_master_password}" \
      -var="grafana_admin_password=${TF_VAR_grafana_admin_password}" \
      -auto-approve
    ;;
esac
