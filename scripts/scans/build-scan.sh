#!/bin/bash
set -e

PROJECT_DIR=$(pwd)
COMPOSE_FILE="${PROJECT_DIR}/DevSecOps-tools/docker-compose.yml"
REPORTS_DIR="${PROJECT_DIR}/DevSecOps-tools/security-reports/build"

mkdir -p "$REPORTS_DIR"

echo "🔍 Running BUILD scans..."
echo "Image: ${DOCKER_IMAGE}"

# Trivy - scan the built Docker image
echo "▶ Running Trivy..."
docker compose -f "$COMPOSE_FILE" run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  trivy image \
  --format json \
  --output /app/security-reports/build/trivy.json \
  --db-repository docker.io/aquasec/trivy-db \
  "${DOCKER_IMAGE}" || true
echo "✅ Trivy done"

# pip-audit - replacement for OWASP Dependency-Check
echo "▶ Running pip-audit..."
docker compose -f "$COMPOSE_FILE" run --rm  \
  pip-audit \
  -r /app/requirements.txt \
  --format json \
  --output /app/security-reports/build/pip-audit.json || true   
echo "✅ pip-audit done"

echo "✅ BUILD scans complete. Reports in $REPORTS_DIR"