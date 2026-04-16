#!/bin/bash
set -e

PROJECT_DIR=$(pwd)
COMPOSE_FILE="${PROJECT_DIR}/DevSecOps-tools/docker-compose.yml"
REPORTS_DIR="${PROJECT_DIR}/DevSecOps-tools/security-reports/build"

mkdir -p "$REPORTS_DIR"

echo "🔍 Running BUILD scans..."
echo "Image: ${DOCKER_IMAGE}"

# Trivy - scan the built Docker image (not filesystem)
echo "▶ Running Trivy..."
docker compose -f "$COMPOSE_FILE" run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  trivy image \
  --format json \
  --output /app/security-reports/build/trivy.json \
  "${DOCKER_IMAGE}" || true
echo "✅ Trivy done"

# OWASP Dependency-Check - NVD cache persisted via named volume
echo "▶ Running OWASP Dependency-Check..."
docker compose -f "$COMPOSE_FILE" run --rm dependency-check \
  --scan /src \
  --format JSON \
  --out /report/build \
  --nvdApiKey "${NVD_API_KEY}" || true   
echo "✅ Dependency-Check done"

echo "✅ BUILD scans complete. Reports in $REPORTS_DIR"