#!/usr/bin/env bash
# bootstrap.sh
# Run ONCE to create Terraform backend S3 bucket + DynamoDB lock table
set -euo pipefail

AWS_REGION="${AWS_REGION:-us-east-1}"
STATE_BUCKET="${STATE_BUCKET:-eks-platform-terraform-state}"
LOCK_TABLE="${LOCK_TABLE:-eks-platform-terraform-locks}"

echo "==> Bootstrapping Terraform backend..."
echo "    Region: $AWS_REGION"
echo "    Bucket: $STATE_BUCKET"
echo "    Table:  $LOCK_TABLE"

cd "$(dirname "$0")/../terraform/backend"

terraform init
terraform apply \
  -var="aws_region=$AWS_REGION" \
  -var="state_bucket_name=$STATE_BUCKET" \
  -var="dynamodb_table_name=$LOCK_TABLE" \
  -auto-approve

echo "==> Backend bootstrap complete!"
