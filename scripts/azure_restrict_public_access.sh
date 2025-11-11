#!/bin/bash
# --- Restrict Public Access for SQL and Audit VM Ports ---
set -e

echo "=== Disabling Public Network Access for all Azure SQL Servers ==="
echo "    [!] WARNING: This is a high-risk command. See Section 6.2."

SQL_SERVER_IDS=$(az sql server list --query "[].id" -o tsv)

if [ -z "$SQL_SERVER_IDS" ]; then
    echo "No Azure SQL servers found."
else
    for id in $SQL_SERVER_IDS; do
      echo "🔧 Disabling public access for SQL server: $(basename $id)"
      # [!] CRITICAL RISK: This command can cause an outage by
      # breaking application connectivity.
      az sql server update \
        --ids "$id" \
        --public-network-access "Disabled" >/dev/null
    done
    echo "✅ Public access disabled for all Azure SQL servers."
fi

echo "=== Auditing NSGs for public admin ports (RDP/SSH) ==="
PUBLIC_RULES=$(az network nsg rule list \
  --query "[?direction=='Inbound' && access=='Allow' && \
            (sourceAddressPrefix=='*' || sourceAddressPrefix=='Internet' || sourceAddressPrefix=='0.0.0.0/0') && \
            (destinationPortRange=='22' || destinationPortRange=='3389')].{Name:name, NSG:networkSecurityGroup, RG:resourceGroup}" \
  -o tsv)

if [ -z "$PUBLIC_RULES" ]; then
  echo "✅ AUDIT PASSED: No NSG rules found exposing RDP/SSH to the internet."
else
  echo "⚠️  CRITICAL FINDING: Found NSG rules exposing RDP/SSH to 'Any'/'Internet':"
  echo "$PUBLIC_RULES"
fi
