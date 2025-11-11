#!/bin/bash
#
# Script: azure_monitoring_guardrails_setup.sh
# Description: Sets up Azure Policy, Defender for Cloud, and Log Analytics monitoring.
#

echo "============================================================"
echo "--- Azure Monitoring & Guardrails Setup ---"
echo "============================================================"

# Enable Defender for Cloud
az security pricing create --name VirtualMachines --tier standard

# Enable Azure Policy for compliance
az policy assignment create --name "BaselineSecurityAudit" \
    --scope "/subscriptions/$(az account show --query id -o tsv)" \
    --policy "/providers/Microsoft.Authorization/policyDefinitions/3a7b64d2-04ba-44b2-9e1a-4a3d1bcd0a33" \
    --display-name "Require VM encryption and NSG association"

# Enable Activity Log alerts
az monitor activity-log alert create --name "CriticalChangeAlert" \
    --scopes "/subscriptions/$(az account show --query id -o tsv)" \
    --condition "category=Administrative" \
    --action-group "DefaultEmailAlertGroup"

echo "============================================================"
echo "Verification Steps:"
echo "→ Check Defender alerts in Security Center."
echo "→ Validate Azure Policy compliance results."
echo "→ Ensure alerts notify your security team."
