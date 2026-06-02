#!/usr/bin/env bash
# kubeconfig.sh
# Updates local kubeconfig for the given environment
# Usage: ./scripts/kubeconfig.sh <dev|qa|uat|prod>
set -euo pipefail

ENV="${1:?Usage: $0 <dev|qa|uat|prod>}"
AWS_REGION="${AWS_REGION:-us-east-1}"
CLUSTER_NAME="eks-platform-${ENV}"

echo "==> Updating kubeconfig for cluster: $CLUSTER_NAME"
aws eks update-kubeconfig \
  --region "$AWS_REGION" \
  --name "$CLUSTER_NAME" \
  --alias "$CLUSTER_NAME"

echo "==> Testing cluster connectivity..."
kubectl cluster-info
kubectl get nodes
