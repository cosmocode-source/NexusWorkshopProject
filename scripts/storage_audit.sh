#!/bin/bash
#
# Script: storage_audit.sh
# Description: Executes the Azure Blob Storage Public Access Auditor Python script ('storage_audit.py').
#

echo "============================================================"
echo "--- Azure Blob Storage Public Access Auditor ---"
echo "============================================================"
echo ""

# Ensure Python script exists
if [ ! -f "storage_audit.py" ]; then
    echo "ERROR: storage_audit.py not found in current directory!"
    exit 1
fi

# Ensure the Python script is executable
chmod +x storage_audit.py 2>/dev/null

# Execute the Python script
python3 storage_audit.py
