#!/bin/bash
set -e

PROJECT_DIR=$(pwd)
REPORTS_DIR="${PROJECT_DIR}/security-reports/pre-build"
mkdir -p "$REPORTS_DIR"

echo "🔐 Running PRE-BUILD security scans..."
echo "Project: $PROJECT_DIR"
echo "Reports: $REPORTS_DIR"

# Bandit
echo "▶ Running Bandit..."
docker compose -f "DevSecOps tools/docker-compose.yml" run --rm \
  -v "${PROJECT_DIR}:/app" \
  bandit -r /app -f json -o /app/security-reports/pre-build/bandit.json || true

# Semgrep
echo "▶ Running Semgrep..."
docker compose -f "DevSecOps tools/docker-compose.yml" run --rm \
  -v "${PROJECT_DIR}:/app" \
  semgrep scan --config auto --json --output /app/security-reports/pre-build/semgrep.json /app || true

# Gitleaks
echo "▶ Running Gitleaks..."
docker compose -f "DevSecOps tools/docker-compose.yml" run --rm \
  -v "${PROJECT_DIR}:/app" \
  gitleaks detect --source /app --report-format json \
  --report-path /app/security-reports/pre-build/gitleaks.json || true

echo "✅ PRE-BUILD scans complete. Reports in $REPORTS_DIR"
