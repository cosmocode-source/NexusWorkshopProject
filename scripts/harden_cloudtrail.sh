#!/bin/bash
# --- Enforce CloudTrail Across All Regions ---
# Ensures CloudTrail is enabled, logs are encrypted, validated, and centralized.

set -e

TRAIL_NAME="SecureOrgTrail"
LOG_BUCKET="secure-cloudtrail-logs"
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

# Ensure bucket exists and is encrypted
if ! aws s3api head-bucket --bucket $LOG_BUCKET 2>/dev/null; then
  echo "Creating CloudTrail log bucket: $LOG_BUCKET"
  aws s3 mb s3://$LOG_BUCKET
fi

aws s3api put-bucket-encryption \
    --bucket "$LOG_BUCKET" \
    --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"aws:kms"}}]}'

aws s3api put-bucket-policy --bucket "$LOG_BUCKET" --policy "{
  \"Version\": \"2012-10-17\",
  \"Statement\": [
    {
      \"Effect\": \"Allow\",
      \"Principal\": {\"Service\": \"cloudtrail.amazonaws.com\"},
      \"Action\": \"s3:PutObject\",
      \"Resource\": \"arn:aws:s3:::$LOG_BUCKET/AWSLogs/$ACCOUNT_ID/*\",
      \"Condition\": {\"StringEquals\": {\"s3:x-amz-acl\": \"bucket-owner-full-control\"}}
    }
  ]
}"

# Create or update CloudTrail
if aws cloudtrail get-trail --name $TRAIL_NAME >/dev/null 2>&1; then
  echo "Updating existing CloudTrail: $TRAIL_NAME"
  aws cloudtrail update-trail \
      --name $TRAIL_NAME \
      --s3-bucket-name $LOG_BUCKET \
      --is-multi-region-trail \
      --enable-log-file-validation
else
  echo "Creating CloudTrail: $TRAIL_NAME"
  aws cloudtrail create-trail \
      --name $TRAIL_NAME \
      --s3-bucket-name $LOG_BUCKET \
      --is-multi-region-trail \
      --enable-log-file-validation
fi

aws cloudtrail start-logging --name $TRAIL_NAME
echo "✅ CloudTrail enforced with encryption and validation."
