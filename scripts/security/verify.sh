#!/bin/bash
set -euo pipefail

echo "🔎 Starting image verification..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

COMPOSE_FILE="${PROJECT_ROOT}/DevSecOps-tools/docker-compose.yml"

VERIFY_TARGET="${SIGN_TARGET:-${IMAGE_NAME}:${IMAGE_TAG}}"

echo "🔍 Verifying: ${VERIFY_TARGET}"

# Login to Docker Hub
echo "${DOCKERHUB_PSW}" | docker login -u "${DOCKERHUB_USR}" --password-stdin

# Extract auth token
DOCKER_AUTH=$(python3 -c "
import sys, json
cfg = json.load(open('/root/.docker/config.json'))
print(cfg['auths']['https://index.docker.io/v1/']['auth'])
")

# Read the public key content directly from the repo
COSIGN_PUB_CONTENT=$(cat "${PROJECT_ROOT}/DevSecOps-tools/cosign/cosign.pub")

docker compose -f "${COMPOSE_FILE}" run --rm \
  -e COSIGN_PUB_CONTENT="${COSIGN_PUB_CONTENT}" \
  --entrypoint sh \
  cosign -c "
    mkdir -p /root/.docker &&
    printf '{\"auths\":{\"https://index.docker.io/v1/\":{\"auth\":\"%s\"}}}' '${DOCKER_AUTH}' > /root/.docker/config.json &&
    printf '%s' \"\${COSIGN_PUB_CONTENT}\" > /tmp/cosign.pub &&
    chmod 600 /tmp/cosign.pub &&
    cosign verify --key /tmp/cosign.pub ${VERIFY_TARGET}
  "

echo "✅ Image verified successfully."