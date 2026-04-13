#!/bin/bash

set -e

PROJECT_DIR=${PROJECT_DIR:-$(pwd)}
REPORTS_DIR=${REPORTS_DIR:-"$PROJECT_DIR/security-reports/build"}
DOCKER_IMAGE=${DOCKER_IMAGE:-""}

mkdir -p "$REPORTS_DIR"

echo "🔐 Running BUILD security scans..."
echo "Project: $PROJECT_DIR"
echo "Reports: $REPORTS_DIR"
echo ""

# ─────────────────────────────────────────
# 1. Trivy (filesystem + optional image)
# ─────────────────────────────────────────
if command -v trivy >/dev/null; then
  echo "▶ Trivy filesystem scan..."
  trivy fs "$PROJECT_DIR" \
    -f json -o "$REPORTS_DIR/trivy-fs.json" || true

  if [ -n "$DOCKER_IMAGE" ]; then
    echo "▶ Trivy image scan..."
    trivy image "$DOCKER_IMAGE" \
      -f json -o "$REPORTS_DIR/trivy-image.json" || true
  fi
else
  echo "⚠ Trivy not installed"
fi

# ─────────────────────────────────────────
# 2. OWASP Dependency-Check (SCA)
# ─────────────────────────────────────────
if command -v dependency-check >/dev/null; then
  echo "▶ OWASP Dependency-Check..."
  dependency-check \
    --scan "$PROJECT_DIR" \
    --format JSON \
    --out "$REPORTS_DIR" \
    || true
elif command -v docker >/dev/null; then
  echo "▶ OWASP via Docker..."
  docker run --rm \
    -v "$PROJECT_DIR:/src" \
    -v "$REPORTS_DIR:/report" \
    owasp/dependency-check \
    --scan /src --format JSON --out /report || true
else
  echo "⚠ OWASP Dependency-Check not available"
fi

echo ""
echo "✅ Build scans completed. Reports: $REPORTS_DIR"