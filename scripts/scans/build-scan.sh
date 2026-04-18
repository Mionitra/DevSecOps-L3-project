#!/bin/bash
set -e

# ----------------------------
# ROOT PATHS (Jenkins-safe)
# ----------------------------
PROJECT_DIR=$(pwd)
PROJECT_ROOT="${PROJECT_DIR}"
COMPOSE_FILE="${PROJECT_ROOT}/DevSecOps-tools/docker-compose.yml"

REPORTS_DIR="${PROJECT_ROOT}/DevSecOps-tools/security-reports"
SRC_DIR="${PROJECT_ROOT}/src"

mkdir -p "${REPORTS_DIR}/build"

echo "🔍 Running BUILD scans..."
echo "Image: ${DOCKER_IMAGE}"

# ----------------------------
# Docker login
# ----------------------------
echo "${DOCKERHUB_PSW}" | docker login -u "${DOCKERHUB_USR}" --password-stdin

# ----------------------------
# Trivy DB update
# ----------------------------
echo "▶ Updating Trivy DB if needed..."
docker compose -f "$COMPOSE_FILE" run --rm \
  -e TRIVY_DB_REPOSITORY=aquasec/trivy-db \
  trivy-db-updater || true

# ----------------------------
# Trivy scan
# ----------------------------
echo "▶ Running Trivy..."
docker compose -f "$COMPOSE_FILE" run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "${REPORTS_DIR}/build:/app/security-reports/build" \
  -e TRIVY_DB_REPOSITORY=aquasec/trivy-db \
  trivy image \
  --skip-db-update \
  --format json \
  --output /app/security-reports/build/trivy.json \
  "${DOCKER_IMAGE}" || true

echo "✅ Trivy done"

# ----------------------------
# pip-audit scan
# ----------------------------
echo "▶ Running pip-audit..."
docker compose -f "$COMPOSE_FILE" run --rm \
  -v "${SRC_DIR}:/app/src" \
  -v "${REPORTS_DIR}/build:/app/security-reports/build" \
  pip-audit \
  -r /app/src/requirements.txt \
  -f json \
  -o /app/security-reports/build/pip-audit.json || true

echo "✅ pip-audit done"

echo "✅ BUILD scans complete."