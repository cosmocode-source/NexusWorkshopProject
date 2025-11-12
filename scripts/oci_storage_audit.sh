#!/bin/bash
#
# Script: oci_storage_audit.sh
# Description: Audits and disables public object storage buckets.
#

echo "============================================================"
echo "--- OCI Storage Audit & Fix ---"
echo "============================================================"

buckets=$(oci os bucket list --all --query "data[?\"public-access-type\"!='NoPublicAccess'].name" --raw-output)

if [ -z "$buckets" ]; then
  echo "[OK] No public buckets found."
else
  echo "[ALERT] Public buckets detected:"
  echo "$buckets"
  echo "[FIX] Disabling public access..."
  for b in $buckets; do
    oci os bucket update --name "$b" --public-access-type NoPublicAccess >/dev/null
  done
fi

oci os bucket list --all --query "data[].{Name:name,Access:\"public-access-type\"}" --output table
