#!/bin/bash
set -e

PROJECT_DIR=$(pwd)
COMPOSE_FILE="${PROJECT_DIR}/DevSecOps-tools/docker-compose.yml"

echo "🔎 Verifying: ${IMAGE_NAME}:${IMAGE_TAG}"

docker compose -f "$COMPOSE_FILE" run --rm \
  cosign verify \
  --key /app/cosign.pub \
  "${IMAGE_NAME}:${IMAGE_TAG}"

echo "✅ Signature verified."