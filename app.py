import os
import subprocess
import json
import shutil
from flask import Flask, jsonify, render_template, request, send_file

app = Flask(__name__)

# === Helper to run shell commands safely ===
def run_cmd(cmd):
    # On Windows, use .cmd for CLI tools if available
    exe = cmd[0]
    if shutil.which(exe + ".cmd"):
        cmd[0] = shutil.which(exe + ".cmd")
    elif shutil.which(exe + ".exe"):
        cmd[0] = shutil.which(exe + ".exe")
    elif shutil.which(exe):
        cmd[0] = shutil.which(exe)
    try:
        res = subprocess.run(cmd, capture_output=True, text=True)
        return res.returncode, res.stdout.strip(), res.stderr.strip()
    except Exception as e:
        return 1, "", str(e)

# === Detect which cloud CLI is available ===
def detect_cloud():
    print("Starting cloud detection...")
    def exists(cmd):
        return shutil.which(cmd) or shutil.which(cmd + ".cmd") or shutil.which(cmd + ".exe")

    # --- AWS ---
    if exists("aws"):
        rc, out, err = run_cmd(["aws", "sts", "get-caller-identity"])
        print("AWS CLI check:", rc, err)
        if rc == 0 and out:
            return "aws"

    # --- Azure ---
    if exists("az"):
        rc, out, err = run_cmd(["az", "account", "show"])
        print("Azure CLI check:", rc, err)
        if rc == 0 and out:
            return "azure"

    # --- GCP ---
    if exists("gcloud"):
        rc, out, err = run_cmd(["gcloud", "config", "list", "account", "--format=json"])
        print("GCP CLI check:", rc, err)
        if rc == 0 and out:
            return "gcp"

    # --- OCI ---
    if exists("oci"):
        rc, out, err = run_cmd(["oci", "os", "ns", "get"])
        print("OCI CLI check:", rc, err)
        if rc == 0 and out:
            return "oci"

    return "none"

# === Flask Routes ===
@app.route("/")
def home():
    return render_template("index.html")

@app.route("/detect")
def detect():
    try:
        cloud = detect_cloud()
        return jsonify({"cloud": cloud})
    except Exception as e:
        import traceback
        print("Error in /detect:", traceback.format_exc())
        return jsonify({"error": str(e), "cloud": "error"}), 500

@app.route("/audit")
def audit():
    try:
        cloud = detect_cloud()
        if cloud == "none":
            return jsonify({"error": "No cloud detected", "cloud": "none"})

        scripts = [f for f in os.listdir("scripts") if f.startswith(cloud + "_")]
        findings = []

        for script in scripts:
            rc, out, err = run_cmd(["bash", os.path.join("scripts", script)])
            findings.append({
                "script": script,
                "ok": rc == 0,
                "issue": out if out else "(no output)",
                "error": err
            })

        return jsonify({"cloud": cloud, "findings": findings})
    except Exception as e:
        import traceback
        print("Error in /audit:", traceback.format_exc())
        return jsonify({"error": str(e), "cloud": "error"}), 500

@app.route("/fix", methods=["POST"])
def fix():
    try:
        data = request.get_json(force=True)
        cloud = data.get("cloud") or detect_cloud()

        if cloud == "none":
            return jsonify({"error": "No cloud detected, cannot apply fixes"})

        scripts = [f for f in os.listdir("scripts") if f.startswith(cloud + "_")]
        results = []
        os.makedirs("reports", exist_ok=True)

        for script in scripts:
            rc, out, err = run_cmd(["bash", os.path.join("scripts", script)])
            results.append({
                "script": script,
                "ok": rc == 0,
                "stdout": out,
                "stderr": err
            })

        report = {
            "timestamp": __import__("datetime").datetime.utcnow().isoformat(),
            "cloud": cloud,
            "results": results
        }

        with open("reports/security_audit_report.json", "w") as f:
            json.dump(report, f, indent=2)

        return jsonify(report)
    except Exception as e:
        import traceback
        print("Error in /fix:", traceback.format_exc())
        return jsonify({"error": str(e), "cloud": "error"}), 500

@app.route("/report")
def report():
    try:
        with open("reports/security_audit_report.json") as f:
            data = json.load(f)
        return render_template("report.html", data=data)
    except FileNotFoundError:
        return render_template("report.html", data={"cloud": "none", "results": []})
    except Exception as e:
        import traceback
        print("Error in /report:", traceback.format_exc())
        return f"Error rendering report: {e}", 500

@app.route("/download")
def download():
    try:
        return send_file("reports/security_audit_report.json", as_attachment=True)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    os.makedirs("reports", exist_ok=True)
    app.run(debug=True)
