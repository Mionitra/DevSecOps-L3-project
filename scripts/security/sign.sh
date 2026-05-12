#!/bin/bash
set -euo pipefail

echo "🔏 Starting image signing..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

COMPOSE_FILE="${PROJECT_ROOT}/DevSecOps-tools/docker-compose.yml"
# KEY_PATH is now provided via COSIGN_KEY_FILE environment variable from Jenkins
# and will be mounted into the container at /tmp/cosign.key

SIGN_TARGET="${SIGN_TARGET}"

echo "📦 Signing: ${SIGN_TARGET}"

# Login to Docker Hub (updates /root/.docker/config.json inside Jenkins)
echo "${DOCKERHUB_PSW}" | docker login -u "${DOCKERHUB_USR}" --password-stdin

# Extract the auth token Jenkins just saved
DOCKER_AUTH=$(cat /root/.docker/config.json | python3 -c "import sys,json; print(json.load(sys.stdin)['auths']['https://index.docker.io/v1/']['auth'])")

docker compose -f "${COMPOSE_FILE}" run --rm \
  -e COSIGN_PASSWORD="${COSIGN_PASSWORD}" \
  -v "${COSIGN_KEY_FILE}:/tmp/cosign.key:ro" \
  --entrypoint sh \
  cosign -c "
    mkdir -p /root/.docker &&
    printf '{\"auths\":{\"https://index.docker.io/v1/\":{\"auth\":\"%s\"}}}' '${DOCKER_AUTH}' > /root/.docker/config.json &&
    cosign sign --key /tmp/cosign.key ${SIGN_TARGET}
  "

echo "✅ Image signed successfully."