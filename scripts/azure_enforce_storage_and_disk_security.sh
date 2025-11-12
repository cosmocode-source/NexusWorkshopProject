#!/bin/bash
echo "=== Enforcing HTTPS (Secure Transfer) for all Storage Accounts ==="

STORAGE_ACCOUNTS=$(az storage account list --query "[].name" -o tsv)
if [ -z "$STORAGE_ACCOUNTS" ]; then
  echo "⚠️ No storage accounts found in this subscription."
else
  for SA in $STORAGE_ACCOUNTS; do
    echo "Enforcing secure transfer on storage account: $SA"
    az storage account update --name "$SA" --https-only true >/dev/null
  done
  echo "✅ All storage accounts are now using HTTPS-only access."
fi

echo "=== Auditing VM Disk Encryption (OS & Data Disks) ==="
VM_LIST=$(az vm list --query "[].{name:name,rg:resourceGroup}" -o tsv)

if [ -z "$VM_LIST" ]; then
  echo "⚠️ No virtual machines found in this subscription."
else
  while read -r VM RG; do
    echo "Checking encryption status for VM: $VM in resource group: $RG"
    az vm encryption show --name "$VM" --resource-group "$RG" --query "{OS:osDisk.encryptionSettingsCollection}" -o table
  done <<< "$VM_LIST"
fi

echo "✅ Storage and Disk security audit completed successfully."
