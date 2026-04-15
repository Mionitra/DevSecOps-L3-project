#!/bin/bash
set -e

PROJECT_DIR=$(pwd)
REPORTS_DIR="${PROJECT_DIR}/security-reports/build"
mkdir -p "$REPORTS_DIR"

echo "🔍 Running BUILD security scans..."
echo "Image: ${DOCKER_IMAGE}"

# Trivy
echo "▶ Running Trivy..."
docker compose -f "DevSecOps tools/docker-compose.yml" run --rm \
  -v "${PROJECT_DIR}:/app" \
  trivy fs /app -f json -o /app/security-reports/build/trivy.json || true

# OWASP Dependency-Check
echo "▶ Running OWASP Dependency-Check..."
docker compose -f "DevSecOps tools/docker-compose.yml" run --rm \
  -v "${PROJECT_DIR}:/src" \
  -v "${PROJECT_DIR}/security-reports/build:/report" \
  -v "dependency_check_data:/usr/share/dependency-check/data" \
  dependency-check --scan /src --format JSON --out /report || true

echo "✅ BUILD scans complete. Reports in $REPORTS_DIR"