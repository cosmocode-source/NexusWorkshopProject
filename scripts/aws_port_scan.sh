#!/bin/bash
#
# Script: aws_port_scan.sh
# Description: Executes the AWS Security Group Port Auditor Python script ('aws_port_scan.py').
#

echo "============================================================"
echo "--- AWS Security Group Port Auditor ---"
echo "============================================================"
echo ""

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script requires root privileges (nmap scan)."
    echo "Run with: sudo ./aws_port_scan.sh"
    exit 1
fi

# Ensure Python script exists
if [ ! -f "aws_port_scan.py" ]; then
    echo "ERROR: aws_port_scan.py not found in current directory!"
    exit 1
fi

chmod +x aws_port_scan.py 2>/dev/null

# Execute the Python script with sudo
sudo python3 aws_port_scan.py
