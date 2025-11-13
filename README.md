# Multi-Cloud Security Posture Management (CSPM) Dashboard

A Flask-based web application that automatically detects, audits, and remediates misconfigurations across multiple cloud environments — currently demonstrated on Microsoft Azure, but compatible with AWS, Google Cloud, and Oracle Cloud Infrastructure (OCI).

---

## Project Overview

This project provides a centralized dashboard for managing and securing cloud resources.  
It detects which cloud environment you’re authenticated to, executes CLI-based security audits, applies automated fixes, and generates compliance reports — all from a single interface.

Currently, the demo focuses on Microsoft Azure using the Azure CLI, but the same logic extends to other providers by switching the logged-in CLI.

---

## Features

- Automatic Cloud Detection: identifies Azure, AWS, GCP, or OCI via installed CLIs  
- Security Audits: scans for misconfigurations such as  
  - Public storage access  
  - Open NSG or firewall rules  
  - Disabled diagnostic logging  
  - Unencrypted disks  
- Automated Fixes: remediates common risks through CLI commands  
- Detailed Reports: generates JSON and HTML audit reports in the reports/ folder  
- Responsive Dashboard UI: built with HTML, CSS, and JavaScript  
- Extensible Architecture: easily add new scripts for other cloud providers  

---

## Folder Structure

<img width="640" height="581" alt="Screenshot 2025-11-12 182951" src="https://github.com/user-attachments/assets/ec44dff5-57aa-478a-83c1-846c39997298" />


## Setup and Run
1. Clone the repository
git clone https://github.com/cosmocode-source/NexusWorkshopProject
cd cspm_project

2. Create and activate a virtual environment
powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1

3. Install dependencies
bash
pip install -r requirements.txt

4. Log in to your cloud provider
For Azure (example):
bash
az login
az account show

5. Run the Flask app
bash
python app.py
Then open your browser at http://127.0.0.1:5000

Cloud-Specific Audits
Azure
Subscription Logging Audit: ensures diagnostic logging is enabled via Log Analytics
MFA Policy Audit: checks for Conditional Access MFA (skips gracefully if unsupported)
Storage and Disk Security Audit: enforces HTTPS-only storage access and verifies disk encryption
AWS
Checks S3 public access, Lambda environment secrets, CloudTrail logging, and Security Group rules
GCP
Audits Cloud Storage permissions, firewall rules, and Stackdriver logging
OCI
Validates Object Storage access policies and network ingress rules

Example Workflow
Detect Cloud — automatically identifies which CLI is authenticated
Run Audit — executes all scripts for that provider
Apply Fixes — remediates misconfigurations
View Report — opens a JSON or HTML summary in the reports/ folder

Clean-Up (Azure Demo)
After testing, you can safely remove temporary resources:
bash
az monitor log-analytics workspace delete --resource-group DefaultResourceGroup-CSPM --workspace-name cspm-log-workspace --yes
az logout
Tech Stack
Component	Technology
Backend	Python 3 + Flask
Front-End	HTML / CSS / JavaScript
Cloud SDKs	Azure CLI, AWS CLI, gcloud, OCI CLI
Reporting	JSON + HTML
Version Control	Git / GitHub

License
This project is for educational and research purposes under an open license.
Feel free to fork, modify, and extend it for multi-cloud security learning.
