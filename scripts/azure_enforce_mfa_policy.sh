#!/bin/bash
# --- Enforce MFA for Admin Roles via Conditional Access ---
# NOTE: Requires Azure AD P1/P2 License and sufficient admin rights.
set -e

POLICY_NAME="Enforce-MFA-For-Admins"

echo "=== Getting Directory Role IDs for Admin Roles ==="
# These are template IDs, not object IDs.
ROLE_IDS=(
  "62e90394-69f5-4237-9190-012177145e10" # Global Administrator
  "194ae4cb-b126-40b2-bd5b-6091b380977d" # Security Administrator
  "29232cdf-9323-42fd-ade2-1d097af3e4de" # Exchange Administrator
  "f28a1f50-f6e7-4571-818b-6a12f2af6b6c" # SharePoint Administrator
)

echo "=== Checking for existing MFA Conditional Access policy ==="
POLICY_ID=$(az ad ca policy list --query "[?displayName=='$POLICY_NAME'].id" -o tsv)

if [ -z "$POLICY_ID" ]; then
  echo "🔧 Policy '$POLICY_NAME' not found. Creating..."

  CONDITIONS=$(cat <<EOF
{
  "users": {
    "includeRoles": [
      "${ROLE_IDS[0]}",
      "${ROLE_IDS[1]}",
      "${ROLE_IDS[2]}",
      "${ROLE_IDS[3]}"
    ]
  },
  "applications": { "includeApplications": [ "all" ] }
}
EOF
)

  CONTROLS=$(cat <<EOF
{
  "grantControls": {
    "operator": "OR",
    "builtInControls": [ "mfa" ]
  }
}
EOF
)

  az ad ca policy create \
    --name "$POLICY_NAME" \
    --state "enabled" \
    --conditions "$CONDITIONS" \
    --grant-controls "$CONTROLS" >/dev/null
    
  echo "✅ Created and **ENABLED** MFA policy '$POLICY_NAME' for admin roles."
else
  echo "✅ Policy '$POLICY_NAME' already exists."
fi
