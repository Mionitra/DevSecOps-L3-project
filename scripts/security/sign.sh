#!/bin/bash
set -e

PROJECT_DIR=$(pwd)
COMPOSE_FILE="${PROJECT_DIR}/DevSecOps-tools/docker-compose.yml"

echo "🔏 Signing image: ${IMAGE_NAME}:${IMAGE_TAG}"

docker compose -f "$COMPOSE_FILE" run --rm \
  -e COSIGN_PASSWORD="${COSIGN_PASSWORD}" \
  cosign sign \
  --key /app/cosign.key \
  "${IMAGE_NAME}:${IMAGE_TAG}"

echo "✅ Image signed."