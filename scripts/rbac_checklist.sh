#!/bin/bash
#
# Script: rbac_checklist.sh
# Description: Displays manual checklist for Azure RBAC Permission Audit.
#

echo "============================================================"
echo "Azure RBAC Permission Auditor"
echo "Finding 3.1: Excessive Permissions Check"
echo "============================================================"
echo ""

echo ">>> MANUAL AUDIT CHECKLIST <<<"
echo "1. Open Azure Portal: https://portal.azure.com"
echo "2. Navigate to: Resource Groups → Cybersec-Audit-RG"
echo "3. Click: 'Access control (IAM)' in left panel"
echo "4. Click: 'Role assignments'"
echo ""

echo ">>> FINDING SUMMARY <<<"
echo "Resource Group: Cybersec-Audit-RG"
echo "Observed Role: Owner (High Risk)"
echo "Recommendation: Downgrade to Contributor for least privilege."
echo ""

echo "============================================================"
echo "DOCUMENTATION GUIDANCE"
echo "============================================================"
echo "* Note the 'Owner' assignment."
echo "* Advise switching to 'Contributor' to limit over-permission."
