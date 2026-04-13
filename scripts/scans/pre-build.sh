#!/bin/bash

set -e

PROJECT_DIR=${PROJECT_DIR:-$(pwd)}
REPORTS_DIR=${REPORTS_DIR:-"$PROJECT_DIR/security-reports/pre-build"}

mkdir -p "$REPORTS_DIR"

echo "🔐 Running PRE-BUILD security scans..."
echo "Project: $PROJECT_DIR"
echo "Reports: $REPORTS_DIR"
echo ""

# ─────────────────────────────────────────
# 1. Bandit (Python SAST)
# ─────────────────────────────────────────
if command -v bandit >/dev/null; then
  echo "▶ Bandit scan..."
  bandit -r "$PROJECT_DIR" -f json -o "$REPORTS_DIR/bandit.json" || true
else
  echo "⚠ Bandit not installed"
fi

# ─────────────────────────────────────────
# 2. Semgrep (Multi-language SAST)
# ─────────────────────────────────────────
if command -v semgrep >/dev/null; then
  echo "▶ Semgrep scan..."
  semgrep scan --config auto \
    --json --output "$REPORTS_DIR/semgrep.json" \
    "$PROJECT_DIR" || true
else
  echo "⚠ Semgrep not installed"
fi

# ─────────────────────────────────────────
# 3. Gitleaks (Secrets detection)
# ─────────────────────────────────────────
if command -v gitleaks >/dev/null; then
  echo "▶ Gitleaks scan..."
  gitleaks detect \
    --source "$PROJECT_DIR" \
    --report-format json \
    --report-path "$REPORTS_DIR/gitleaks.json" \
    || true
else
  echo "⚠ Gitleaks not installed"
fi

echo ""
echo "✅ Pre-build scans completed. Reports: $REPORTS_DIR"