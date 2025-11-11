#!/bin/bash
#
# Script: port_scan.sh
# Description: Executes the Azure NSG Port Auditor Python script ('port_scan.py').
#

echo "============================================================"
echo "--- Azure NSG (Network Security Group) Port Auditor ---"
echo "============================================================"
echo ""

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script requires root privileges to run (nmap scan)."
    echo "Please run with: sudo ./port_scan.sh"
    exit 1
fi

# Ensure Python script exists
if [ ! -f "port_scan.py" ]; then
    echo "ERROR: port_scan.py not found in current directory!"
    exit 1
fi

chmod +x port_scan.py 2>/dev/null

# Execute the Python script with sudo
sudo python3 port_scan.py
