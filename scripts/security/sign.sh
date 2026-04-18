#!/bin/bash
set -euo pipefail

echo "🔏 Starting image signing..."

# --- Resolve paths (robust for Jenkins + local) ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

COSIGN_DIR="${PROJECT_ROOT}/DevSecOps-tools/cosign"
COMPOSE_FILE="${PROJECT_ROOT}/DevSecOps-tools/docker-compose.yml"


# --- Build target (digest format required) ---
SIGN_TARGET="${SIGN_TARGET}"

echo "📍 Using key: ${COSIGN_DIR}/cosign.key"
echo "📦 Signing: ${SIGN_TARGET}"

# Login to Docker Hub
echo "${DOCKERHUB_PSW}" | docker login -u "${DOCKERHUB_USR}" --password-stdin
# Ensure the key exists on the host
test -f "${COSIGN_DIR}/cosign.key" || { echo "❌ Missing cosign.key at ${COSIGN_DIR}"; exit 1; }

docker compose -f "${COMPOSE_FILE}" run --rm \
  -e COSIGN_PASSWORD="${COSIGN_PASSWORD}" \
  -v "${COSIGN_DIR}/cosign.key:/app/cosign.key:ro" \
  -v "$HOME/.docker:/root/.docker" \
  cosign sign \
  --key /app/cosign.key \
  "${SIGN_TARGET}"

echo "✅ Image signed successfully."