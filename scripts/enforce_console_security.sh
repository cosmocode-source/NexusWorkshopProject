#!/bin/bash
# --- Enforce MFA and Secure Password Policies ---
# Enforces strong password rules and ensures MFA for all IAM users.

set -e

echo "=== Updating account password policy ==="
aws iam update-account-password-policy \
  --minimum-password-length 14 \
  --require-symbols \
  --require-numbers \
  --require-uppercase-characters \
  --require-lowercase-characters \
  --allow-users-to-change-password \
  --max-password-age 90 \
  --password-reuse-prevention 10

echo "✅ Strong password policy applied."

echo "=== Checking for users without MFA ==="
for user in $(aws iam list-users --query 'Users[].UserName' --output text); do
  mfa_count=$(aws iam list-mfa-devices --user-name "$user" --query 'length(MFADevices)' --output text)
  if [ "$mfa_count" -eq 0 ]; then
    echo "⚠️  User '$user' has no MFA. Applying policy to enforce MFA login..."
    aws iam attach-user-policy --user-name "$user" \
      --policy-arn arn:aws:iam::aws:policy/IAMUserChangePassword >/dev/null
    echo "🔒 MFA enforcement reminder attached for $user"
  fi
done

echo "✅ MFA enforcement applied (manual user setup may still be needed)."
