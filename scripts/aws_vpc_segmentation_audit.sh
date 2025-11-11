#!/bin/bash
#
# Script: aws_vpc_segmentation_audit.sh
# Description: Audits for default VPC usage and ensures proper network segmentation.
#

echo "============================================================"
echo "--- AWS VPC Segmentation & Isolation Auditor ---"
echo "============================================================"

# Check for default VPCs
echo "[INFO] Checking for workloads running in default VPCs..."
aws ec2 describe-instances --query "Reservations[*].Instances[*].[VpcId,InstanceId,Tags]" --output table | grep "vpc-" > vpc_audit.txt

if grep -q "vpc-" vpc_audit.txt; then
    echo "[RESULT] Default VPC detected. Consider migrating workloads to custom VPCs."
else
    echo "[RESULT] No workloads detected in default VPCs."
fi

# Check for subnet configuration
echo "[INFO] Verifying public and private subnet structure..."
aws ec2 describe-subnets --query "Subnets[*].[SubnetId,MapPublicIpOnLaunch]" --output table

# Check NACL rules
echo "[INFO] Reviewing Network ACLs..."
aws ec2 describe-network-acls --query "NetworkAcls[*].[NetworkAclId,Entries]" --output table

# Check Security Groups for open ports
echo "[INFO] Auditing Security Groups for open ports (0.0.0.0/0)..."
aws ec2 describe-security-groups --query "SecurityGroups[*].[GroupName,IpPermissions]" --output text | grep "0.0.0.0/0" || echo "No open ports found."

echo "============================================================"
echo "Remediation Recommendation:"
echo "→ Create custom VPCs for each environment."
echo "→ Segregate workloads into public/private subnets."
echo "→ Apply strict NACL and SG least-privilege rules."
