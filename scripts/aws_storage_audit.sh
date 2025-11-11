#!/bin/bash
#
# Script: aws_storage_audit.sh
# Description: Executes the AWS S3 Bucket Public Access Auditor Python script ('aws_storage_audit.py').
#

echo "============================================================"
echo "--- AWS S3 Bucket Public Access Auditor ---"
echo "============================================================"
echo ""

# Ensure Python script exists
if [ ! -f "aws_storage_audit.py" ]; then
    echo "ERROR: aws_storage_audit.py not found in current directory!"
    exit 1
fi

chmod +x aws_storage_audit.py 2>/dev/null

# Execute the Python script
python3 aws_storage_audit.py
