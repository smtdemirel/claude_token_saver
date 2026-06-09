#!/usr/bin/env bash
# Updates claude-token-saver rules in a target project.
# Works for both standalone (Option A) and git submodule (Option B) setups.
#
# Usage:
#   Option A — standalone clone:
#     bash ~/claude-token-saver/update.sh /path/to/your-project
#
#   Option B — as a submodule inside your project:
#     git submodule update --remote .claude-token-saver
#     bash .claude-token-saver/update.sh .

set -euo pipefail

RULES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-$(pwd)}"

if [[ "$TARGET" == "$RULES_DIR" ]]; then
  echo "Error: target cannot be the claude-token-saver directory itself." >&2
  exit 1
fi

if [[ ! -d "$TARGET" ]]; then
  echo "Error: target directory does not exist: $TARGET" >&2
  exit 1
fi

LOCAL_VERSION="$(cat "$RULES_DIR/VERSION" 2>/dev/null || echo "unknown")"
echo "Updating claude-token-saver → $TARGET"
echo "  Current version: $LOCAL_VERSION"
echo ""

# Step 1: Pull latest rules (only if this is a standalone clone, not a submodule).
# When used as a submodule, the caller runs `git submodule update --remote` first.
if [[ -d "$RULES_DIR/.git" ]]; then
  echo "Pulling latest rules from remote..."
  git -C "$RULES_DIR" pull --ff-only 2>&1 | sed 's/^/  /'
  NEW_VERSION="$(cat "$RULES_DIR/VERSION" 2>/dev/null || echo "unknown")"
  if [[ "$NEW_VERSION" != "$LOCAL_VERSION" ]]; then
    echo "  Upgraded: $LOCAL_VERSION → $NEW_VERSION"
  else
    echo "  Already at latest version ($LOCAL_VERSION)"
  fi
  echo ""
fi

# Step 2: Copy updated files (PROJECT_RULES.md is always preserved).
echo "Copying updated files..."

cp "$RULES_DIR/CLAUDE.md" "$TARGET/CLAUDE.md"
echo "  [✓] CLAUDE.md"

# PROJECT_RULES.md: never overwrite — user's customizations live here
if [[ ! -f "$TARGET/PROJECT_RULES.md" ]]; then
  cp "$RULES_DIR/templates/PROJECT_RULES.template.md" "$TARGET/PROJECT_RULES.md"
  echo "  [✓] PROJECT_RULES.md (created from template)"
else
  echo "  [~] PROJECT_RULES.md preserved (your customizations kept)"
fi

mkdir -p "$TARGET/docs"
cp "$RULES_DIR/docs/"*.md "$TARGET/docs/" 2>/dev/null || true
echo "  [✓] docs/ updated"

mkdir -p "$TARGET/db"
cp "$RULES_DIR/db/schema.sql"       "$TARGET/db/schema.sql"
cp "$RULES_DIR/db/build-index.sh"   "$TARGET/db/build-index.sh"
cp "$RULES_DIR/db/query-rules.sh"   "$TARGET/db/query-rules.sh"
cp "$RULES_DIR/update.sh"           "$TARGET/update.sh"
cp "$RULES_DIR/VERSION"             "$TARGET/VERSION" 2>/dev/null || true
chmod +x "$TARGET/db/build-index.sh" "$TARGET/db/query-rules.sh" "$TARGET/update.sh"
echo "  [✓] db/ scripts updated"

# Step 3: Rebuild FTS5 index with updated content.
echo ""
if command -v sqlite3 &>/dev/null; then
  echo "Rebuilding FTS5 rule index..."
  bash "$TARGET/db/build-index.sh" "$TARGET"
else
  echo "Warning: sqlite3 not found — skipping index rebuild."
  echo "  Run: $TARGET/db/build-index.sh"
fi

echo ""
echo "Update complete. Version: $(cat "$RULES_DIR/VERSION" 2>/dev/null || echo "unknown")"
