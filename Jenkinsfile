#!/bin/bash
set -euo pipefail

echo "🔏 Starting image signing..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

COMPOSE_FILE="${PROJECT_ROOT}/DevSecOps-tools/docker-compose.yml"

SIGN_TARGET="${SIGN_TARGET}"

echo "📦 Signing: ${SIGN_TARGET}"

# Login to Docker Hub
echo "${DOCKERHUB_PSW}" | docker login -u "${DOCKERHUB_USR}" --password-stdin

# Extract auth token
DOCKER_AUTH=$(python3 -c "
import sys, json
cfg = json.load(open('/root/.docker/config.json'))
print(cfg['auths']['https://index.docker.io/v1/']['auth'])
")

# Read the key content from the file Jenkins provided
COSIGN_KEY_CONTENT=$(cat "${COSIGN_KEY_FILE}")

docker compose -f "${COMPOSE_FILE}" run --rm \
  -e COSIGN_PASSWORD="${COSIGN_PASSWORD}" \
  -e COSIGN_KEY_CONTENT="${COSIGN_KEY_CONTENT}" \
  --entrypoint sh \
  cosign -c "
    mkdir -p /root/.docker &&
    printf '{\"auths\":{\"https://index.docker.io/v1/\":{\"auth\":\"%s\"}}}' '${DOCKER_AUTH}' > /root/.docker/config.json &&
    printf '%s' \"\${COSIGN_KEY_CONTENT}\" > /tmp/cosign.key &&
    chmod 600 /tmp/cosign.key &&
    cosign sign --key /tmp/cosign.key ${SIGN_TARGET}
  "

echo "✅ Image signed successfully."