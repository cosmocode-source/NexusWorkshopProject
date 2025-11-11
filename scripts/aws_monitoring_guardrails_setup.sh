#!/bin/bash
#
# Script: aws_monitoring_guardrails_setup.sh
# Description: Deploys AWS Config, GuardDuty, and Security Hub for continuous monitoring.
#

echo "============================================================"
echo "--- AWS Monitoring & Guardrails Setup ---"
echo "============================================================"

# Enable AWS Config
echo "[STEP] Enabling AWS Config..."
aws configservice start-configuration-recorder --configuration-recorder-name default || echo "Recorder may already be active."

# Enable GuardDuty
echo "[STEP] Enabling GuardDuty..."
aws guardduty create-detector --enable || echo "GuardDuty already enabled."

# Enable Security Hub
echo "[STEP] Enabling Security Hub..."
aws securityhub enable-security-hub || echo "Security Hub may already be active."

# Confirm integration
echo "[INFO] Verifying integration between GuardDuty and Security Hub..."
aws securityhub list-enabled-products-for-import

echo "============================================================"
echo "Verification Steps:"
echo "→ Check Config rules and conformance packs are active."
echo "→ Confirm findings appear in Security Hub dashboard."
echo "→ Link CloudWatch/EventBridge alerts to SNS or Slack."
echo "============================================================"
