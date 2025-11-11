#!/bin/bash
# --- Enforce Storage Secure Transfer & Audit Disk Encryption ---
set -e

echo "=== Enforcing HTTPS (Secure Transfer) for all Storage Accounts ==="
ACCOUNT_IDS=$(az storage account list --query "[].id" -o tsv)

if [ -z "$ACCOUNT_IDS" ]; then
    echo "No storage accounts found."
else
    for id in $ACCOUNT_IDS; do
      echo "🔧 Checking storage account: $(basename $id)"
      az storage account update --ids "$id" --https-only true >/dev/null
    done
    echo "✅ All storage accounts now enforce Secure Transfer (HTTPS-only)."
fi

echo "=== Auditing VM Disk Encryption (OS & Data Disks) ==="
DISK_IDS=$(az disk list --query "[].id" -o tsv)

if [ -z "$DISK_IDS" ]; then
    echo "No VM disks found."
else
    for id in $DISK_IDS; do
      ENCRYPTION_TYPE=$(az disk show --ids "$id" --query "encryption.type" -o tsv)
      DISK_NAME=$(basename $id)

      if [[ "$ENCRYPTION_TYPE" == "None" ]]; then
        echo "  - ⚠️  AUDIT FAILED: Disk '$DISK_NAME' has NO encryption."
      elif [[ "$ENCRYPTION_TYPE" == "EncryptionAtRestWithPlatformKey" ]]; then
        echo "  - ✅ OK (Default): Disk '$DISK_NAME' has Platform-Managed Key."
      else
        echo "  - ✅ OK (CMK): Disk '$DISK_NAME' is encrypted ($ENCRYPTION_TYPE)."
      fi
    done
fi
echo "✅ VM Disk encryption audit complete."
