async function runAudit() {
  const logBox = document.getElementById("log");
  logBox.textContent = "Running audit...\n";
  const res = await fetch("/audit");
  const data = await res.json();
  if (data.error) {
    logBox.textContent += data.error;
    return;
  }
  logBox.textContent += `Cloud detected: ${data.cloud.toUpperCase()}\n`;
  data.findings.forEach(f => {
    logBox.textContent += `• ${f.issue} → ${f.script}\n`;
  });
}

async function runFix() {
  const logBox = document.getElementById("log");
  logBox.textContent += "\nApplying fixes...\n";
  const res = await fetch("/fix", {
    method: "POST",
    headers: {"Content-Type": "application/json"},
    body: JSON.stringify({ cloud: "aws" }) // Flask auto-detects anyway
  });
  const data = await res.json();
  data.results.forEach(r => {
    logBox.textContent += `${r.script}: ${r.ok ? "✅ Success" : "❌ Failed"}\n`;
  });
}

function viewReport() {
  window.location.href = "/report";
}
