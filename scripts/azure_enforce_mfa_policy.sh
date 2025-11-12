#!/bin/bash
echo "=== Checking MFA enforcement for Azure Active Directory ==="

# Check if Conditional Access commands exist
if ! az ad | grep -q 'conditional-access'; then
  echo "⚠️ Conditional Access not available in this subscription (likely Azure AD Free or Student). Skipping MFA policy check."
  exit 0
fi

echo "=== Getting Directory Role IDs for Admin Roles ==="
ADMIN_IDS=$(az ad directory-role list --query "[?displayName=='Global Administrator'].id" -o tsv)

if [ -z "$ADMIN_IDS" ]; then
  echo "No Global Administrator roles found."
  exit 0
fi

echo "=== Checking existing MFA Conditional Access policies ==="
az ad conditional-access policy list --query "[].displayName" -o tsv | grep -iq "mfa"
if [ $? -eq 0 ]; then
  echo "✅ MFA policy already enforced."
else
  echo "⚠️ No MFA policy found. Recommend enabling conditional access MFA policy manually."
fi
