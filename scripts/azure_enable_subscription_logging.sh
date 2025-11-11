#!/bin/bash
# --- Enable Subscription-Wide Activity Logging ---
set -e

LOG_RG="central-logging-rg"
LOG_LA_WORKSPACE="central-la-workspace"
LOG_STORAGE_ACCT="centralactivitylogs$(openssl rand -hex 6)"
LOCATION="eastus"

echo "=== Ensuring Logging Resource Group exists ==="
az group create --name "$LOG_RG" --location "$LOCATION" -o tsv >/dev/null

echo "=== Ensuring Log Analytics Workspace exists ==="
LA_WORKSPACE_ID=$(az monitor log-analytics workspace create \
  --resource-group "$LOG_RG" \
  --workspace-name "$LOG_LA_WORKSPACE" \
  --location "$LOCATION" --query "id" -o tsv)

echo "=== Ensuring Storage Account for logs exists ==="
STORAGE_ID=$(az storage account create \
  --name "$LOG_STORAGE_ACCT" \
  --resource-group "$LOG_RG" \
  --location "$LOCATION" \
  --sku "Standard_LRS" --query "id" -o tsv)

echo "=== Creating Subscription Diagnostic Setting ==="
# This command is idempotent; it will update if it exists
az monitor diagnostic-settings subscription create \
  --name "send-activity-log-to-central" \
  --location "$LOCATION" \
  --storage-account "$STORAGE_ID" \
  --workspace "$LA_WORKSPACE_ID" \
  --logs '[{"category": "Administrative", "enabled": true}, {"category": "Security", "enabled": true}, \
           {"category": "ServiceHealth", "enabled": true}, {"category": "Alert", "enabled": true}, \
           {"category": "Recommendation", "enabled": true}, {"category": "Policy", "enabled": true}]' \
  >/dev/null
           
echo "✅ Subscription-wide logging enabled and exporting to LA and Storage."
