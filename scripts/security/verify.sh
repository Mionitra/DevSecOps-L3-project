#!/bin/bash
set -e

PROJECT_DIR=$(pwd)

echo "🔎 Verifying signature: ${IMAGE_NAME}:${IMAGE_TAG}"

docker compose -f docker-dependencies/docker-compose.yml run --rm \
  -v "${PROJECT_DIR}:/app" \
  cosign verify --key /app/cosign.pub "${IMAGE_NAME}:${IMAGE_TAG}"

echo "✅ Signature verified."
