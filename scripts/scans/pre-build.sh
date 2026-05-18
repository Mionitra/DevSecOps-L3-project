#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

COMPOSE_FILE="${PROJECT_DIR}/DevSecOps-tools/docker-compose.yml"
TOOLS_DIR="${PROJECT_DIR}/DevSecOps-tools"
REPORTS_DIR="${TOOLS_DIR}/security-reports"

# ── Resolve the real host path if running inside a Jenkins container ────────
# Jenkins mounts its workspace from the host; we need the HOST path for
# Docker volume mounts, not the path inside the Jenkins container.
# WORKSPACE_HOST_PATH must be set in the Jenkins pipeline environment.
if [ -n "${WORKSPACE_HOST_PATH:-}" ]; then
  HOST_PROJECT_DIR="${WORKSPACE_HOST_PATH}"
else
  HOST_PROJECT_DIR="${PROJECT_DIR}"
fi

HOST_SRC_DIR="${HOST_PROJECT_DIR}/src"
HOST_REPORTS_DIR="${HOST_PROJECT_DIR}/DevSecOps-tools/security-reports"
# ────────────────────────────────────────────────────────────────────────────

mkdir -p "${REPORTS_DIR}/pre-build"

echo "Running PRE-BUILD security scans..."

# Bandit
echo "▶ Running Bandit..."
docker compose -f "$COMPOSE_FILE" run --rm \
  -v "${HOST_SRC_DIR}:/scan/src:ro" \
  -v "${HOST_REPORTS_DIR}/pre-build:/scan/reports" \
  bandit \
  -r /scan/src \
  -f json \
  -o /scan/reports/bandit.json || true
echo "✅ Bandit done"

# Semgrep
echo "▶ Running Semgrep..."
docker compose -f "$COMPOSE_FILE" run --rm \
  -v "${HOST_SRC_DIR}:/scan/src:ro" \
  -v "${HOST_REPORTS_DIR}/pre-build:/scan/reports" \
  semgrep \
  scan --config auto --json \
  --no-git-ignore \
  --output /scan/reports/semgrep.json \
  /scan/src || true
echo "✅ Semgrep done"

# Gitleaks
echo "▶ Running Gitleaks..."
docker compose -f "$COMPOSE_FILE" run --rm \
  -v "${HOST_PROJECT_DIR}:/scan/src:ro" \
  -v "${HOST_REPORTS_DIR}/pre-build:/scan/reports" \
  gitleaks \
  detect \
  --source /scan/src \
  --no-git \
  --report-format json \
  --report-path /scan/reports/gitleaks.json || true
echo "✅ Gitleaks done"

echo "✅ PRE-BUILD scans complete. Reports in ${REPORTS_DIR}/pre-build"