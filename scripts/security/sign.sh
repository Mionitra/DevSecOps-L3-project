#!/bin/bash
set -euo pipefail

echo "🔏 Starting image signing..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

COSIGN_DIR="${PROJECT_ROOT}/DevSecOps-tools/cosign"
COMPOSE_FILE="${PROJECT_ROOT}/DevSecOps-tools/docker-compose.yml"

SIGN_TARGET="${SIGN_TARGET}"

echo "📍 Using key: ${COSIGN_DIR}/cosign.key"
echo "📦 Signing: ${SIGN_TARGET}"

echo "${DOCKERHUB_PSW}" | docker login -u "${DOCKERHUB_USR}" --password-stdin

test -f "${COSIGN_DIR}/cosign.key" || { echo "❌ Missing cosign.key at ${COSIGN_DIR}"; exit 1; }

docker compose -f "${COMPOSE_FILE}" run --rm \
  -e COSIGN_PASSWORD="${COSIGN_PASSWORD}" \
  -v jenkins_home_jenkins_home:/jenkins_home:ro \
  -v "${HOME}/.docker/config.json:/root/.docker/config.json:ro" \
  cosign \
  sign \
  --key /jenkins_home/workspace/devsecops-project-pipeline/DevSecOps-tools/cosign/cosign.key \
  "${SIGN_TARGET}"

echo "✅ Image signed successfully."