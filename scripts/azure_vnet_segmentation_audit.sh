#!/bin/bash
#
# Script: azure_vnet_segmentation_audit.sh
# Description: Audits Azure VNets for segmentation, subnet configuration, and NSG rules.
#

echo "============================================================"
echo "--- Azure VNet Segmentation & Isolation Auditor ---"
echo "============================================================"

# List all VNets
az network vnet list --query "[].{Name:name, ResourceGroup:resourceGroup, AddressSpace:addressSpace}" -o table

# List subnets with NSGs
az network vnet subnet list --resource-group Cybersec-Audit-RG --vnet-name MainVNet \
  --query "[].{Subnet:name,NSG:networkSecurityGroup.id,PrivateEndpoint:privateEndpointNetworkPolicies}" -o table

# Check for open NSG rules
echo "[INFO] Checking for open NSG rules (0.0.0.0/0)..."
az network nsg rule list --resource-group Cybersec-Audit-RG --nsg-name AppNSG \
  --query "[?sourceAddressPrefix=='*']" -o table

echo "============================================================"
echo "Recommendation:"
echo "→ Use separate VNets for dev, staging, prod."
echo "→ Restrict NSG inbound rules and use Service Tags when possible."
