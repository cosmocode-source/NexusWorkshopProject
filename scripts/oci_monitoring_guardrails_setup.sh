#!/bin/bash
#
# Script: oci_monitoring_guardrails_setup.sh
# Description: Ensures basic alarms and metrics exist.
#

echo "============================================================"
echo "--- OCI Monitoring & Guardrails Setup ---"
echo "============================================================"

alarms=$(oci monitoring alarm list --all --query "data[].display-name" --raw-output)
if [ -z "$alarms" ]; then
  echo "[FIX] No alarms found. Creating default security alarm..."
  oci monitoring alarm create --display-name "SecurityBaseline" --query "data.id" \
    --metric-compartment-id $(oci iam compartment list --query "data[0].id" --raw-output) \
    --namespace "oci_computeagent" --query-text "CpuUtilization[1m].max() > 90" \
    --severity CRITICAL --is-enabled true >/dev/null
fi

oci monitoring alarm list --all --query "data[].{Name:display-name,Enabled:is-enabled}" --output table
