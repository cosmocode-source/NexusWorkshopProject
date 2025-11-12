#!/bin/bash
#
# Script: gcp_firewall_audit.sh
# Description: Audits open firewall rules and deletes insecure ones.
#

echo "============================================================"
echo "--- GCP Firewall Audit & Fix ---"
echo "============================================================"

echo "[STEP] Checking for open firewall rules..."
rules=$(gcloud compute firewall-rules list --format="value(name)" --filter="sourceRanges:0.0.0.0/0")

if [ -z "$rules" ]; then
  echo "[OK] No open rules found."
else
  echo "[ALERT] Found open rules:"
  echo "$rules"
  echo "[FIX] Deleting insecure rules..."
  for r in $rules; do
    gcloud compute firewall-rules delete "$r" -q
  done
fi

echo "[VERIFY] Remaining firewall rules:"
gcloud compute firewall-rules list --format="table(name,sourceRanges)"
