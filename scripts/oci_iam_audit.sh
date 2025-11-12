#!/bin/bash
#
# Script: oci_iam_audit.sh
# Description: Detects and removes overly broad policies.
#

echo "============================================================"
echo "--- OCI IAM Audit & Fix ---"
echo "============================================================"

policies=$(oci iam policy list --all --query "data[?contains(statements[0],'Manage All-resources')].name" --raw-output)
if [ -z "$policies" ]; then
  echo "[OK] No overly broad policies found."
else
  echo "[ALERT] Overly broad policies detected:"
  echo "$policies"
  echo "[FIX] Disabling dangerous policies..."
  for p in $policies; do
    oci iam policy update --policy-id "$(oci iam policy list --all --query "data[?name=='$p'].id" --raw-output)" --is-enabled false >/dev/null
  done
fi

oci iam policy list --all --query "data[].{Name:name,Enabled:is-enabled}" --output table
