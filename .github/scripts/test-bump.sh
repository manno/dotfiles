#!/usr/bin/env bash
# test-bump.sh — local end-to-end test for the plugin-bump workflow.
#
# Usage (from repo root):
#   GITHUB_TOKEN=... bash .github/scripts/test-bump.sh [slug]
#
# Optional argument: a plugin slug to analyze (e.g. folke/snacks.nvim).
# Without it the script picks the first entry from the matrix.
#
# The Lua files are restored from git after the run so you can test
# repeatedly without committing anything.

set -euo pipefail

if [ -z "${GITHUB_TOKEN:-}" ]; then
  echo "error: GITHUB_TOKEN is not set."
  echo "  source .envrc, or run: export GITHUB_TOKEN=\$(gh auth token)"
  exit 1
fi

TARGET_SLUG="${1:-}"

# ── Step 1: detect ────────────────────────────────────────────────────────────

echo "═══════════════════════════════════════════════════════"
echo " Step 1: bump-nvim-plugins.go"
echo "═══════════════════════════════════════════════════════"
echo ""

go run .github/scripts/bump-nvim-plugins.go

MATRIX_FILE=".github/bump/matrix.json"
if [ ! -f "$MATRIX_FILE" ]; then
  echo "No matrix.json written — nothing to update."
  exit 0
fi

MATRIX=$(cat "$MATRIX_FILE")
COUNT=$(echo "$MATRIX" | jq 'length')
echo ""
echo "Matrix: $COUNT plugin(s) to update."
echo ""

# ── Step 2: analyze one plugin ────────────────────────────────────────────────

if [ "$COUNT" -eq 0 ]; then
  echo "All plugins up to date."
  exit 0
fi

if [ -n "$TARGET_SLUG" ]; then
  ENTRY=$(echo "$MATRIX" | jq --arg s "$TARGET_SLUG" '.[] | select(.slug == $s)')
  if [ -z "$ENTRY" ]; then
    echo "error: slug '$TARGET_SLUG' not found in matrix."
    echo "Available slugs:"
    echo "$MATRIX" | jq -r '.[].slug'
    exit 1
  fi
else
  ENTRY=$(echo "$MATRIX" | jq '.[0]')
fi

SLUG=$(echo "$ENTRY"      | jq -r '.slug')
SLUG_SAFE=$(echo "$ENTRY" | jq -r '.slug_safe')
OWNER=$(echo "$ENTRY"     | jq -r '.owner')
REPO=$(echo "$ENTRY"      | jq -r '.repo')
OLD_SHA=$(echo "$ENTRY"   | jq -r '.old_sha')
NEW_SHA=$(echo "$ENTRY"   | jq -r '.new_sha')
TAG=$(echo "$ENTRY"       | jq -r '.tag')

echo "═══════════════════════════════════════════════════════"
echo " Step 2: analyze-plugin.mjs — $SLUG"
echo "═══════════════════════════════════════════════════════"
echo ""

PLUGIN_SLUG="$SLUG" \
PLUGIN_SLUG_SAFE="$SLUG_SAFE" \
PLUGIN_OWNER="$OWNER" \
PLUGIN_REPO="$REPO" \
PLUGIN_OLD_SHA="$OLD_SHA" \
PLUGIN_NEW_SHA="$NEW_SHA" \
PLUGIN_TAG="$TAG" \
  node .github/scripts/analyze-plugin.mjs

echo ""
echo "Analysis report:"
echo "────────────────"
cat "${SLUG_SAFE}-analysis.md"
rm -f "${SLUG_SAFE}-analysis.md"

# ── Restore Lua files ─────────────────────────────────────────────────────────

echo ""
echo "Restoring Lua files..."
git checkout -- dot_config/nvim/lua/
rm -rf .github/bump/
echo "Done. No files were permanently modified."
