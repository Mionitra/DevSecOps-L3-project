#!/bin/bash
set -e

PROJECT_DIR=$(pwd)
COMPOSE_FILE="${PROJECT_DIR}/DevSecOps-tools/docker-compose.yml"
TOOLS_DIR="${PROJECT_DIR}/DevSecOps-tools"
SRC_DIR="${PROJECT_DIR}/src"
REPORTS_DIR="${TOOLS_DIR}/security-reports"

mkdir -p "${REPORTS_DIR}/pre-build"

echo "Running PRE-BUILD security scans..."

# Bandit
echo "▶ Running Bandit..."
docker compose -f "$COMPOSE_FILE" run --rm \
  -v "${SRC_DIR}:/scan/src:ro" \
  -v "${REPORTS_DIR}/pre-build:/scan/reports" \
  bandit \
  -r /scan/src \
  -f json \
  -o /scan/reports/bandit.json || true
echo "✅ Bandit done"

# Semgrep
echo "▶ Running Semgrep..."
docker compose -f "$COMPOSE_FILE" run --rm \
  -v "${SRC_DIR}:/scan/src:ro" \
  -v "${REPORTS_DIR}/pre-build:/scan/reports" \
  semgrep \
  scan --config auto --json \
  --no-git-ignore \
  --output /scan/reports/semgrep.json \
  /scan/src || true
echo "✅ Semgrep done"

# Gitleaks
echo "▶ Running Gitleaks..."
docker compose -f "$COMPOSE_FILE" run --rm \
  -v "${PROJECT_DIR}:/scan/src:ro" \
  -v "${REPORTS_DIR}/pre-build:/scan/reports" \
  gitleaks \
  detect \
  --source /scan/src \
  --no-git \
  --report-format json \
  --report-path /scan/reports/gitleaks.json || true
echo "✅ Gitleaks done"

echo "✅ PRE-BUILD scans complete. Reports in ${REPORTS_DIR}/pre-build"