// === Multi-Cloud Security Dashboard Frontend Logic ===

// Auto-run detection on page load
window.addEventListener("DOMContentLoaded", detectCloud);

async function fetchJSON(url, options = {}) {
  const res = await fetch(url, options);
  let data;
  try {
    data = await res.json();
  } catch (err) {
    const text = await res.text();
    throw new Error(
      `Server did not return JSON. Response was:\n${text.substring(0, 300)}...`
    );
  }
  return data;
}

// --- Detect Cloud ---
async function detectCloud() {
  const cloudElem = document.getElementById("cloudName");
  const logBox = document.getElementById("log");
  const auditStatus = document.getElementById("auditStatus");

  cloudElem.className = "cloud-status none";
  cloudElem.textContent = "Detecting...";
  auditStatus.textContent = "Detecting...";
  logBox.textContent = "Running environment detection...\n";

  try {
    const data = await fetchJSON("/detect");

    if (data.error) {
      throw new Error(data.error);
    }

    const cloud = data.cloud?.toLowerCase() || "none";
    if (cloud !== "none" && cloud !== "error") {
      cloudElem.textContent = cloud.toUpperCase();
      cloudElem.className = "cloud-status " + cloud;
      logBox.textContent += `✅ Detected cloud: ${cloud.toUpperCase()}\n`;
      auditStatus.textContent = "Detected";
    } else {
      cloudElem.textContent = "Unknown";
      logBox.textContent += "⚠️  No supported cloud environment detected.\n";
      auditStatus.textContent = "Unknown";
    }
  } catch (err) {
    cloudElem.textContent = "ERROR";
    cloudElem.className = "cloud-status none";
    logBox.textContent += `❌ Detection error: ${err.message}\n`;
    auditStatus.textContent = "Error";
  }
}

// --- Run Audit ---
async function runAudit() {
  const logBox = document.getElementById("log");
  const cloudElem = document.getElementById("cloudName");
  const auditStatus = document.getElementById("auditStatus");

  logBox.textContent = "🧩 Running audit...\n";
  auditStatus.textContent = "Running...";

  try {
    const data = await fetchJSON("/audit");

    if (data.error) {
      logBox.textContent += `❌ ${data.error}\n`;
      auditStatus.textContent = "Error";
      return;
    }

    const cloud = data.cloud || "unknown";
    cloudElem.textContent = cloud.toUpperCase();
    cloudElem.className = "cloud-status " + cloud.toLowerCase();

    logBox.textContent += `🌐 Cloud: ${cloud.toUpperCase()}\n`;
    data.findings.forEach(f => {
      logBox.textContent += `• ${f.issue} (${f.script})\n`;
    });

    auditStatus.textContent = "Completed";
    logBox.textContent += "\n✅ Audit finished.\n";
  } catch (err) {
    auditStatus.textContent = "Error";
    logBox.textContent += `❌ Audit failed: ${err.message}\n`;
  }
}

// --- Apply Fixes ---
async function runFix() {
  const logBox = document.getElementById("log");
  const auditStatus = document.getElementById("auditStatus");

  logBox.textContent += "\n🛠 Applying fixes...\n";
  auditStatus.textContent = "Applying fixes...";

  try {
    const data = await fetchJSON("/fix", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({})
    });

    if (data.error) {
      logBox.textContent += `❌ ${data.error}\n`;
      auditStatus.textContent = "Error";
      return;
    }

    data.results.forEach(r => {
      logBox.textContent += `${r.script}: ${r.ok ? "✅ Success" : "❌ Failed"}\n`;
    });

    auditStatus.textContent = "Fixes Applied";
    logBox.textContent += "\n✅ All applicable fixes executed.\n";
  } catch (err) {
    auditStatus.textContent = "Error";
    logBox.textContent += `❌ Fix failed: ${err.message}\n`;
  }
}

// --- View Report ---
function viewReport() {
  window.location.href = "/report";
}
