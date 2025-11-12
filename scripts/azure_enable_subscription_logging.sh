#!/bin/bash
echo "=== Ensuring Logging Resource Group exists ==="

# Define safe region and resource group name
RESOURCE_GROUP="DefaultResourceGroup-CSPM"
LOCATION="eastus"

# Check if resource group exists
if ! az group show --name "$RESOURCE_GROUP" >/dev/null 2>&1; then
  echo "Creating resource group $RESOURCE_GROUP in $LOCATION..."
  az group create --name "$RESOURCE_GROUP" --location "$LOCATION" >/dev/null
else
  echo "Resource group $RESOURCE_GROUP already exists."
fi

echo "=== Ensuring Log Analytics Workspace exists ==="
WORKSPACE="cspm-log-workspace"

# Check if workspace exists, else create it in an allowed region
if ! az monitor log-analytics workspace show \
  --resource-group "$RESOURCE_GROUP" --workspace-name "$WORKSPACE" >/dev/null 2>&1; then
  echo "Creating workspace $WORKSPACE in $LOCATION..."
  az monitor log-analytics workspace create \
    --resource-group "$RESOURCE_GROUP" \
    --workspace-name "$WORKSPACE" \
    --location "$LOCATION" >/dev/null
else
  echo "Workspace $WORKSPACE already exists."
fi

echo "=== Linking Activity Log to Log Analytics Workspace ===
