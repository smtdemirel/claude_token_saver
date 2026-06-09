#!/usr/bin/env bash
# Generates a compact project snapshot for Claude's SessionStart context.
# Target output: < 400 tokens — enough for instant project awareness.
# Run: scripts/snapshot.sh [project-root]
# Output: .claude/project-snapshot.md

set -euo pipefail

ROOT="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
OUT="$ROOT/.claude/project-snapshot.md"
mkdir -p "$ROOT/.claude"

# ── Helpers ────────────────────────────────────────────────────────────────

git_safe() { git -C "$ROOT" "$@" 2>/dev/null || true; }

# Read a field from PROJECT_RULES.md (e.g. "Language:")
rules_field() {
  local field="$1"
  local val
  val=$(grep -i "^[-*]\s*$field" "$ROOT/PROJECT_RULES.md" 2>/dev/null \
    | head -1 | sed 's/.*:\s*//' | sed 's/#.*//' | xargs)
  echo "${val:-—}"
}

# ── Collect data ───────────────────────────────────────────────────────────

TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
PROJECT_NAME=$(basename "$ROOT")

# Stack (from PROJECT_RULES.md)
LANGUAGE=$(rules_field "Language")
FRAMEWORK=$(rules_field "Framework")
DATABASE=$(rules_field "Database")
TEST_RUNNER=$(rules_field "Test runner")

# Git state
BRANCH=$(git_safe rev-parse --abbrev-ref HEAD)
RECENT_COMMITS=$(git_safe log --oneline -5 | sed 's/^/  /')
MODIFIED_FILES=$(git_safe status --short | head -10 | sed 's/^/  /')

# Directory tree (depth 2, exclude noise)
TREE=$(find "$ROOT" -maxdepth 2 \
  -not -path '*/.git/*' \
  -not -path '*/node_modules/*' \
  -not -path '*/.claude/*' \
  -not -path '*/vendor/*' \
  -not -path '*/__pycache__/*' \
  -not -path '*/.dart_tool/*' \
  -not -name '*.db' \
  -not -name '*.lock' \
  | sed "s|$ROOT/||" \
  | sort \
  | head -40 \
  | sed 's/^/  /')

# Entry point detection
ENTRY_POINTS=""
for f in main.ts index.ts app.ts server.ts main.py app.py manage.py \
          index.js main.go main.dart lib/main.dart artisan; do
  [[ -f "$ROOT/$f" ]] && ENTRY_POINTS="$ENTRY_POINTS $f"
done

# ── Write snapshot ─────────────────────────────────────────────────────────

cat > "$OUT" <<SNAPSHOT
# Project Snapshot — $PROJECT_NAME
Generated: $TIMESTAMP (auto-updated by claude-token-saver)

## Stack
Language: $LANGUAGE | Framework: $FRAMEWORK | DB: $DATABASE | Tests: $TEST_RUNNER

## Git State
Branch: ${BRANCH:-"(not a git repo)"}

Recent commits:
${RECENT_COMMITS:-"  (none)"}

Modified files:
${MODIFIED_FILES:-"  (clean)"}

## Structure (depth 2)
$TREE

## Entry Points
${ENTRY_POINTS:-"(none detected)"}
SNAPSHOT

SIZE=$(wc -c < "$OUT")
echo "Snapshot written: $OUT ($SIZE bytes)"
