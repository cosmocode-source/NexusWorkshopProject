#!/bin/bash
#
# Script: oci_firewall_audit.sh
# Description: Audits and removes open ingress rules in NSGs.
#

echo "============================================================"
echo "--- OCI Firewall Audit & Fix ---"
echo "============================================================"

lists=$(oci network security-list list --all --query "data[*].id" --raw-output)
for l in $lists; do
  rules=$(oci network security-list get --security-list-id "$l" --query "data.ingress-security-rules[?source=='0.0.0.0/0']" --raw-output)
  if [ -n "$rules" ]; then
    echo "[ALERT] Found open ingress in $l"
    echo "[FIX] Removing all public ingress rules..."
    oci network security-list update --security-list-id "$l" --ingress-security-rules "[]" >/dev/null
  fi
done

echo "[VERIFY] Final ingress rule count per list:"
oci network security-list list --all --query "data[].{Name:display-name,Ingress:ingress-security-rules|length(@)}" --output table
