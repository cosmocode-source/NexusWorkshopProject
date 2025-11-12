#!/bin/bash
#
# Script: gcp_storage_audit.sh
# Description: Audits GCP buckets for public access and disables it.
#

echo "============================================================"
echo "--- GCP Storage Audit & Fix ---"
echo "============================================================"

echo "[STEP] Checking for public GCS buckets..."
buckets=$(gcloud storage buckets list --format="value(name)" --filter="iamConfiguration.uniformBucketLevelAccess.enabled=false")

if [ -z "$buckets" ]; then
  echo "[OK] All buckets enforce uniform access."
else
  echo "[ALERT] Buckets without uniform access found:"
  echo "$buckets"
  echo "[FIX] Enabling uniform bucket-level access and removing public bindings..."

  for b in $buckets; do
    gcloud storage buckets update "$b" --uniform-bucket-level-access
    gcloud storage buckets remove-iam-policy-binding "$b" \
      --member=allUsers --role=roles/storage.objectViewer --quiet || true
  done
fi

echo "[VERIFY] Current bucket IAM bindings:"
gcloud storage buckets list --format="table(name, iamConfiguration.uniformBucketLevelAccess.enabled)"
