#!/bin/bash
set -e

PROJECT_DIR=$(pwd)

echo "🔏 Signing image: ${IMAGE_NAME}:${IMAGE_TAG}"

docker compose -f "DevSecOps tools/docker-compose.yml" run --rm \
  -v "${PROJECT_DIR}:/app" \
  -e COSIGN_PASSWORD="${COSIGN_PASSWORD}" \
  cosign sign --key /app/cosign.key "${IMAGE_NAME}:${IMAGE_TAG}"

echo "✅ Image signed successfully."
