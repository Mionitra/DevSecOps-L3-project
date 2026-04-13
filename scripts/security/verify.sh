#!/bin/bash

set -e

IMAGE_NAME=${IMAGE_NAME:-"my-app"}
IMAGE_TAG=${IMAGE_TAG:-"latest"}
FULL_IMAGE="$IMAGE_NAME:$IMAGE_TAG"

echo "🔍 Verifying Docker image: $FULL_IMAGE"

# Check cosign
if ! command -v cosign >/dev/null; then
  echo "❌ Cosign not installed"
  exit 1
fi

# Verify signature
if [ -f cosign.pub ]; then
  echo "🔑 Using public key verification..."
  cosign verify --key cosign.pub "$FULL_IMAGE"
else
  echo "⚠ No public key found, trying keyless verification..."
  cosign verify "$FULL_IMAGE"
fi

echo "✅ Verification completed"