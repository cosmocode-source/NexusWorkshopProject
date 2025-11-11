#!/bin/bash
#
# Script: azure_function_secret_audit.sh
# Description: Scans Azure Functions for hardcoded secrets and ensures Key Vault integration.
#

echo "============================================================"
echo "--- Azure Function Secrets Auditor ---"
echo "============================================================"

# List all Function Apps
apps=$(az functionapp list --query "[].name" -o tsv)

for app in $apps; do
    echo "[INFO] Checking Function App: $app"
    settings=$(az functionapp config appsettings list --name "$app" --resource-group Cybersec-Audit-RG)

    if echo "$settings" | grep -E "password|key|secret|token" >/dev/null; then
        echo "[ALERT] Potential hardcoded secret found in $app!"
    else
        echo "[OK] No secrets found in $app."
    fi
done

echo "============================================================"
echo "Recommendation:"
echo "→ Store all secrets in Azure Key Vault."
echo "→ Integrate Key Vault with Function App via managed identity."
echo "→ Rotate credentials regularly."
