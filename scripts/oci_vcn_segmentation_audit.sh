#!/bin/bash
#
# Script: oci_vcn_segmentation_audit.sh
# Description: Ensures each VCN has at least 2 subnets.
#

echo "============================================================"
echo "--- OCI VCN Segmentation Audit & Fix ---"
echo "============================================================"

vcns=$(oci network vcn list --all --query "data[*].{id:id,name:display-name}" --raw-output)
for v in $vcns; do
  subcount=$(oci network subnet list --vcn-id "$v" --query "length(data)" --raw-output)
  if [ "$subcount" -lt 2 ]; then
    echo "[ALERT] VCN $v has fewer than 2 subnets."
    echo "[FIX] Creating 'internal' and 'external' subnets..."
    oci network subnet create --vcn-id "$v" --cidr-block "10.$((RANDOM%200)).1.0/24" --display-name "internal" >/dev/null
    oci network subnet create --vcn-id "$v" --cidr-block "10.$((RANDOM%200)).2.0/24" --display-name "external" >/dev/null
  fi
done
