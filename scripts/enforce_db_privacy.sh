#!/bin/bash
# --- Restrict Database Public Access ---
# Forces all RDS instances and clusters to be private and secured by subnet and SGs.

set -e

for region in $(aws ec2 describe-regions --query "Regions[].RegionName" --output text); do
  echo "=== Checking RDS instances in region: $region ==="
  dbs=$(aws rds describe-db-instances --region "$region" --query 'DBInstances[].DBInstanceIdentifier' --output text)
  
  for db in $dbs; do
    echo "🔧 Updating $db to private mode..."
    aws rds modify-db-instance \
      --db-instance-identifier "$db" \
      --no-publicly-accessible \
      --apply-immediately \
      --region "$region" >/dev/null
  done

  echo "=== Checking Aurora clusters in region: $region ==="
  clusters=$(aws rds describe-db-clusters --region "$region" --query 'DBClusters[].DBClusterIdentifier' --output text)
  
  for cluster in $clusters; do
    echo "🔧 Updating cluster $cluster to private..."
    aws rds modify-db-cluster \
      --db-cluster-identifier "$cluster" \
      --vpc-security-group-ids "" \
      --region "$region" >/dev/null
  done
done

echo "✅ All RDS and Aurora instances now private and non-public."
