#!/bin/bash

set -e

IMAGE_NAME=${IMAGE_NAME:-"my-app"}
IMAGE_TAG=${IMAGE_TAG:-"latest"}
FULL_IMAGE="$IMAGE_NAME:$IMAGE_TAG"

echo "🔐 Signing Docker image: $FULL_IMAGE"

# Check cosign
if ! command -v cosign >/dev/null; then
  echo "❌ Cosign not installed"
  exit 1
fi

# Check docker image exists
if ! docker image inspect "$FULL_IMAGE" >/dev/null 2>&1; then
  echo "❌ Image not found: $FULL_IMAGE"
  exit 1
fi

# Generate key pair if not exists
if [ ! -f cosign.key ]; then
  echo "🔑 Generating Cosign key pair..."
  cosign generate-key-pair
fi

# Sign the image
echo "✍ Signing image..."
cosign sign --key cosign.key "$FULL_IMAGE"

echo "✅ Image signed successfully"