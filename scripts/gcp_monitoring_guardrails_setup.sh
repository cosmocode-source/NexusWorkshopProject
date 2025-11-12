#!/bin/bash
#
# Script: gcp_monitoring_guardrails_setup.sh
# Description: Enables GCP Monitoring alerts and audit logs.
#

echo "============================================================"
echo "--- GCP Monitoring & Guardrails Setup ---"
echo "============================================================"

echo "[STEP] Ensuring Cloud Audit Logs are enabled..."
gcloud services enable logging.googleapis.com monitoring.googleapis.com || true

echo "[STEP] Creating default alert policy for error rate..."
gcloud monitoring alert-policies create \
  --display-name="Error Rate Alert" \
  --combiner="OR" \
  --conditions='[{"displayName": "Error Rate Condition", "conditionThreshold": {"filter": "metric.type=\"run.googleapis.com/request_count\" AND metric.label.\"response_code\"=500", "comparison": "COMPARISON_GT", "thresholdValue": 10, "duration": "60s"}}]' || true

echo "[VERIFY] Active alert policies:"
gcloud monitoring alert-policies list --format="table(displayName,enabled)"
