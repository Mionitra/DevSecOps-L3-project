#!/bin/bash
set -e

PROJECT_DIR=$(pwd)
COMPOSE_FILE="${PROJECT_DIR}/DevSecOps-tools/docker-compose.yml"
TOOLS_DIR="${PROJECT_DIR}/DevSecOps-tools"
SRC_DIR="${PROJECT_DIR}/src"
REPORTS_DIR="${TOOLS_DIR}/security-reports"

mkdir -p "${REPORTS_DIR}/build"

echo "🔍 Running BUILD scans..."
echo "Image: ${DOCKER_IMAGE}"

# Docker login
echo "${DOCKERHUB_PSW}" | docker login -u "${DOCKERHUB_USR}" --password-stdin

# Trivy DB update
echo "▶ Updating Trivy DB if needed..."
docker compose -f "$COMPOSE_FILE" run --rm \
  -v trivy-cache:/root/.cache/trivy \
  -e TRIVY_DB_REPOSITORY=aquasec/trivy-db \
  trivy-db-updater || true

# Trivy scan
echo "▶ Running Trivy..."
docker compose -f "$COMPOSE_FILE" run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v trivy-cache:/root/.cache/trivy \
  -v "${REPORTS_DIR}/build:/scan/reports" \
  -e TRIVY_DB_REPOSITORY=aquasec/trivy-db \
  trivy image \
  --skip-db-update \
  --format json \
  --output /scan/reports/trivy.json \
  "${DOCKER_IMAGE}" || true
echo "✅ Trivy done"

# pip-audit
echo "▶ Running pip-audit..."
docker compose -f "$COMPOSE_FILE" run --rm \
  -v "${SRC_DIR}:/scan/src:ro" \
  -v "${REPORTS_DIR}/build:/scan/reports" \
  --entrypoint sh \
  pip-audit -c "
    pip install -q -r /scan/src/requirements.txt 2>/dev/null || true &&
    pip-audit \
      --skip-editable \
      --format json \
      --output /scan/reports/pip-audit.json
  " || true
echo "✅ pip-audit done"

echo "✅ BUILD scans complete."