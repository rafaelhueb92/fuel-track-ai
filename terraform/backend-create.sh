#!/bin/bash

ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
BUCKET_NAME="terraform-backend-${ACCOUNT_ID}"

cat <<EOF > backend.hcl
bucket         = "${BUCKET_NAME}"
key           = "state/terraform.tfstate"
region        = "us-east-1"
dynamodb_table = "terraform-lock"
EOF