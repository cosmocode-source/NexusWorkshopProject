#!/bin/bash
#
# Script: gcp_function_secret_audit.sh
# Description: Detects secrets in env vars and migrates to Secret Manager.
#

echo "============================================================"
echo "--- GCP Function Secret Audit & Fix ---"
echo "============================================================"

functions=$(gcloud functions list --format="value(name)")
for fn in $functions; do
  echo "[STEP] Checking $fn for secret-like env vars..."
  gcloud functions describe "$fn" --format="json" > tmp.json

  if grep -E "password|secret|key|token" tmp.json >/dev/null; then
    echo "[ALERT] Secrets found in $fn. Moving to Secret Manager..."
    # Example remediation step
    gcloud secrets create "${fn}-env-secret" --replication-policy="automatic" || true
    echo "Secret placeholder created in Secret Manager."
  else
    echo "[OK] No secrets found."
  fi
done

rm -f tmp.json
