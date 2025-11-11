from flask import Flask, render_template, jsonify, request, send_file
import subprocess, json, os, datetime

app = Flask(__name__)

# --- SAFE SCRIPTS (Expanded) ---

SAFE_SCRIPTS = {
    "aws": [
        # Baseline / old ones
        "harden_cloudtrail.sh",
        "enforce_encryption.sh",
        "enforce_console_security.sh",
        "enforce_db_privacy.sh",

        # New remediation scripts (from PDF and recent updates)
        "aws_storage_audit.sh",
        "aws_port_scan.sh",
        "aws_iam_audit.sh",
        "aws_vpc_segmentation_audit.sh",
        "aws_lambda_secret_audit.sh",
        "aws_monitoring_guardrails_setup.sh"
    ],

    "azure": [
        # Existing baseline scripts
        "azure_enforce_storage_and_disk_security.sh",
        "azure_enforce_mfa_policy.sh",
        "azure_restrict_public_access.sh",
        "azure_enable_subscription_logging.sh",

        # New ones from latest sets
        "storage_audit.sh",
        "port_scan.sh",
        "rbac_checklist.sh",
        "azure_vnet_segmentation_audit.sh",
        "azure_function_secret_audit.sh",
        "azure_monitoring_guardrails_setup.sh"
    ]
}

REPORT_PATH = os.path.join("reports", "security_audit_report.json")

# --- Utils ---
def run_cmd(cmd):
    res = subprocess.run(cmd, capture_output=True, text=True)
    return res.returncode, res.stdout.strip(), res.stderr.strip()

def detect_cloud():
    rc1, out1, _ = run_cmd(["aws", "sts", "get-caller-identity"])
    rc2, out2, _ = run_cmd(["az", "account", "show"])
    if rc1 == 0 and out1:
        return "aws"
    elif rc2 == 0 and out2:
        return "azure"
    return "none"

def run_script(script):
    path = os.path.join("scripts", script)
    if not os.path.exists(path):
        return {"script": script, "ok": False, "error": "File not found"}
    rc, out, err = run_cmd(["bash", path])
    return {
        "script": script,
        "ok": rc == 0,
        "stdout": out,
        "stderr": err
    }

# --- Routes ---

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/detect")
def detect():
    cloud = detect_cloud()
    return jsonify({"cloud": cloud})

@app.route("/audit", methods=["GET"])
def audit():
    cloud = detect_cloud()
    findings = []

    if cloud == "aws":
        findings = [
            {"issue": "Default VPC usage without segmentation", "script": "aws_vpc_segmentation_audit.sh"},
            {"issue": "Lambda functions with hardcoded secrets", "script": "aws_lambda_secret_audit.sh"},
            {"issue": "Lack of monitoring and guardrails", "script": "aws_monitoring_guardrails_setup.sh"},
            {"issue": "Public S3 buckets or missing encryption", "script": "aws_storage_audit.sh"},
            {"issue": "Security Groups with open ports", "script": "aws_port_scan.sh"},
            {"issue": "Over-privileged IAM users/roles", "script": "aws_iam_audit.sh"}
        ]

    elif cloud == "azure":
        findings = [
            {"issue": "Unsecured Blob storage or public disks", "script": "storage_audit.sh"},
            {"issue": "NSG ports open to public", "script": "port_scan.sh"},
            {"issue": "Excessive RBAC permissions", "script": "rbac_checklist.sh"},
            {"issue": "VNet or subnet misconfiguration", "script": "azure_vnet_segmentation_audit.sh"},
            {"issue": "Hardcoded secrets in Azure Functions", "script": "azure_function_secret_audit.sh"},
            {"issue": "Missing Defender and Policy guardrails", "script": "azure_monitoring_guardrails_setup.sh"}
        ]
    else:
        return jsonify({"error": "No cloud detected"})

    return jsonify({"cloud": cloud, "findings": findings})

@app.route("/fix", methods=["POST"])
def fix():
    data = request.get_json()
    cloud = data.get("cloud")
    scripts = SAFE_SCRIPTS.get(cloud, [])
    results = []

    for script in scripts:
        results.append(run_script(script))

    report = {
        "timestamp": datetime.datetime.utcnow().isoformat() + "Z",
        "cloud": cloud,
        "results": results
    }

    os.makedirs("reports", exist_ok=True)
    with open(REPORT_PATH, "w") as f:
        json.dump(report, f, indent=2)

    return jsonify({"status": "completed", "results": results})

@app.route("/report")
def report():
    if os.path.exists(REPORT_PATH):
        with open(REPORT_PATH) as f:
            data = json.load(f)
        return render_template("report.html", data=data)
    return "No report found."

@app.route("/download")
def download():
    if os.path.exists(REPORT_PATH):
        return send_file(REPORT_PATH, as_attachment=True)
    return "Report not found."

if __name__ == "__main__":
    os.makedirs("reports", exist_ok=True)
    app.run(debug=True)
