#!/bin/bash
#
# Script: gcp_vpc_segmentation_audit.sh
# Description: Ensures VPCs have segmented subnets per environment.
#

echo "============================================================"
echo "--- GCP VPC Segmentation Audit & Fix ---"
echo "============================================================"

vpcs=$(gcloud compute networks list --format="value(name)")
for vpc in $vpcs; do
  echo "[INFO] VPC: $vpc"
  subnets=$(gcloud compute networks subnets list --filter="network:$vpc" --format="value(name)")
  
  if [ -z "$subnets" ]; then
    echo "[ALERT] $vpc has no subnets. Creating default segmented ones..."
    for env in dev staging prod; do
      gcloud compute networks subnets create "${vpc}-${env}" \
        --network="$vpc" --region=us-central1 --range="10.$((RANDOM%200)).$((RANDOM%200)).0/24"
    done
  fi
done

echo "[VERIFY] Current subnet setup:"
gcloud compute networks subnets list --format="table(name,network,region,ipCidrRange)"
