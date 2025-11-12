#!/bin/bash
#
# Script: gcp_iam_audit.sh
# Description: Detects and removes over-privileged IAM roles.
#

echo "============================================================"
echo "--- GCP IAM Audit & Fix ---"
echo "============================================================"

PROJECT=$(gcloud config get-value project)
echo "[STEP] Checking IAM bindings for 'Owner' and 'Editor' roles..."
bindings=$(gcloud projects get-iam-policy "$PROJECT" --format="json" | jq -r '.bindings[] | select(.role=="roles/owner" or .role=="roles/editor") | .role + ":" + (.members|join(","))')

if [ -z "$bindings" ]; then
  echo "[OK] No over-privileged roles detected."
else
  echo "[ALERT] Over-privileged bindings found:"
  echo "$bindings"

  for role in roles/owner roles/editor; do
    members=$(gcloud projects get-iam-policy "$PROJECT" --format="json" | jq -r ".bindings[] | select(.role==\"$role\") | .members[]" || true)
    for m in $members; do
      echo "[FIX] Removing $m from $role"
      gcloud projects remove-iam-policy-binding "$PROJECT" --member="$m" --role="$role" --quiet
    done
  done
fi

echo "[VERIFY] Remaining IAM roles:"
gcloud projects get-iam-policy "$PROJECT" --format="table(bindings.role)"
