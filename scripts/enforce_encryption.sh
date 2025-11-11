#!/bin/bash
# --- Enforce Encryption for Data at Rest ---
# This script enforces encryption for all S3 buckets and enables EBS encryption by default.
# It overrides any user setting that disables encryption.

set -e

echo "=== Enforcing encryption for all S3 buckets ==="
for bucket in $(aws s3api list-buckets --query "Buckets[].Name" --output text); do
  echo "🔧 Bucket: $bucket"
  aws s3api put-bucket-encryption \
      --bucket "$bucket" \
      --server-side-encryption-configuration '{
        "Rules": [
          {
            "ApplyServerSideEncryptionByDefault": {
              "SSEAlgorithm": "aws:kms"
            }
          }
        ]
      }' >/dev/null
done
echo "✅ All S3 buckets now enforce KMS encryption."

echo "=== Enabling default EBS encryption for all regions ==="
for region in $(aws ec2 describe-regions --query "Regions[].RegionName" --output text); do
  echo "🔧 Region: $region"
  aws ec2 enable-ebs-encryption-by-default --region "$region" >/dev/null
done
echo "✅ Default EBS encryption enabled in all regions."
