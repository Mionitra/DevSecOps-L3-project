#!/bin/bash
set -euo pipefail

echo "🔎 Starting image verification..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

COMPOSE_FILE="${PROJECT_ROOT}/DevSecOps-tools/docker-compose.yml"
# Align PUB_KEY_PATH logic with sign.sh KEY_PATH
PUB_KEY_PATH="/jenkins_home/workspace/devsecops-project-pipeline/DevSecOps-tools/cosign/cosign.pub"

# Support SIGN_TARGET as used in the pipeline, fallback to IMAGE_NAME:IMAGE_TAG
VERIFY_TARGET="${SIGN_TARGET:-${IMAGE_NAME}:${IMAGE_TAG}}"

echo "📦 Verifying: ${VERIFY_TARGET}"

# Login to Docker Hub (updates /root/.docker/config.json inside Jenkins)
echo "${DOCKERHUB_PSW}" | docker login -u "${DOCKERHUB_USR}" --password-stdin

# Extract the auth token Jenkins just saved (same as sign.sh)
DOCKER_AUTH=$(cat /root/.docker/config.json | python3 -c "import sys,json; print(json.load(sys.stdin)['auths']['https://index.docker.io/v1/']['auth'])")

docker compose -f "${COMPOSE_FILE}" run --rm \
  -v jenkins_home_jenkins_home:/jenkins_home:ro \
  --entrypoint sh \
  cosign -c "
    mkdir -p /root/.docker &&
    printf '{\"auths\":{\"https://index.docker.io/v1/\":{\"auth\":\"%s\"}}}' '${DOCKER_AUTH}' > /root/.docker/config.json &&
    cosign verify --key ${PUB_KEY_PATH} ${VERIFY_TARGET}
  "

echo "✅ Image verified successfully."