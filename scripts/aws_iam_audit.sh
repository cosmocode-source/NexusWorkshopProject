#!/bin/bash
#
# Script: aws_iam_audit.sh
# Description: Displays manual checklist for AWS IAM Role Permission Audit.
#

echo "============================================================"
echo "AWS IAM Permission Auditor"
echo "Finding 3.1: Over-Privileged IAM Roles"
echo "============================================================"
echo ""

echo ">>> MANUAL AUDIT CHECKLIST <<<"
echo "1. Open AWS Console: https://console.aws.amazon.com/"
echo "2. Navigate to: IAM → Roles"
echo "3. Select each role used by the audit group (e.g., EC2AdminRole)"
echo "4. Review 'Permissions policies' and check for wildcard actions ('*')."
echo ""

echo ">>> FINDING SUMMARY <<<"
echo "Observed Role: AdminAccess (High Risk)"
echo "Recommendation: Replace with 'PowerUserAccess' or custom least-privilege policy."
echo ""

echo "============================================================"
echo "DOCUMENTATION GUIDANCE"
echo "============================================================"
echo "* Identify users or roles with excessive permissions."
echo "* Recommend policy adjustments to follow least-privilege principles."
