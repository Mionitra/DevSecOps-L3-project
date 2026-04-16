#!/bin/bash
set -e

PROJECT_DIR=$(pwd)
COMPOSE_FILE="${PROJECT_DIR}/DevSecOps-tools/docker-compose.yml"
TOOLS_DIR="${PROJECT_DIR}/DevSecOps-tools"

mkdir -p "${TOOLS_DIR}/security-reports/build"

echo "🔍 Running BUILD scans..."
echo "Image: ${DOCKER_IMAGE}"

# Login to Docker Hub so trivy can pull its DB
echo "${DOCKERHUB_PSW}" | docker login -u "${DOCKERHUB_USR}" --password-stdin

# Update Trivy DB only if cache is older than 24h
echo "▶ Updating Trivy DB if needed..."
docker compose -f "$COMPOSE_FILE" run --rm \
  -e TRIVY_DB_REPOSITORY=aquasec/trivy-db \
  trivy-db-updater || true

# Trivy image scan - skips re-downloading DB
echo "▶ Running Trivy..."
docker compose -f "$COMPOSE_FILE" run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e TRIVY_DB_REPOSITORY=aquasec/trivy-db \
  trivy image \
  --skip-db-update \
  --format json \
  --output /app/security-reports/build/trivy.json \
  "${DOCKER_IMAGE}" || true
echo "✅ Trivy done"

# pip-audit - fast Python dependency scan, no NVD download needed
echo "▶ Running pip-audit..."
docker compose -f "$COMPOSE_FILE" run --rm pip-audit \
  -r /app/src/requirements.txt \
  -f json \
  -o /app/security-reports/build/pip-audit.json || true
echo "✅ pip-audit done"

echo "✅ BUILD scans complete."