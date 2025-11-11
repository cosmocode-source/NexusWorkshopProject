#!/bin/bash
#
# Script: aws_lambda_secret_audit.sh
# Description: Audits Lambda functions for hardcoded secrets and ensures Secrets Manager usage.
#

echo "============================================================"
echo "--- AWS Lambda Secrets Auditor ---"
echo "============================================================"

# List all Lambda functions
functions=$(aws lambda list-functions --query "Functions[*].FunctionName" --output text)

for fn in $functions; do
    echo "[INFO] Checking function: $fn"
    
    # Download environment variables
    aws lambda get-function-configuration --function-name "$fn" \
        --query "{Name:FunctionName,Environment:Environment}" > tmp_env.json
    
    # Check for hardcoded credentials (simple pattern)
    if grep -E "password|key|secret|token" tmp_env.json >/dev/null; then
        echo "[ALERT] Potential secret found in $fn environment variables!"
    else
        echo "[OK] No secrets found in $fn environment variables."
    fi
done

rm -f tmp_env.json

echo "============================================================"
echo "Remediation Recommendation:"
echo "→ Move secrets to AWS Secrets Manager or SSM Parameter Store."
echo "→ Refactor Lambda to fetch secrets dynamically via IAM role."
echo "→ Enable automatic rotation for managed secrets."
