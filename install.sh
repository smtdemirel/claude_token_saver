#!/usr/bin/env bash
# Installs claude-token-saver into a target project.
# Usage: install.sh [target-dir]
# Copies CLAUDE.md, docs/, db/ and creates PROJECT_RULES.md from template.

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

echo "Installing claude-token-saver → $TARGET"
echo ""

# 1. Core agent rules
cp "$RULES_DIR/CLAUDE.md" "$TARGET/CLAUDE.md"
echo "  [✓] CLAUDE.md"

# 2. PROJECT_RULES.md — only if not already customized
if [[ -f "$TARGET/PROJECT_RULES.md" ]]; then
  echo "  [~] PROJECT_RULES.md already exists — skipping (your customizations are preserved)"
else
  cp "$RULES_DIR/templates/PROJECT_RULES.template.md" "$TARGET/PROJECT_RULES.md"
  echo "  [✓] PROJECT_RULES.md (from template — fill in your stack and overrides)"
fi

# 3. docs/ — extended rule reference
mkdir -p "$TARGET/docs"
cp "$RULES_DIR/docs/"*.md "$TARGET/docs/" 2>/dev/null || true
echo "  [✓] docs/ (code-style, architecture, testing, security, token-budget)"

# 4. db/ — FTS5 index tooling
mkdir -p "$TARGET/db"
cp "$RULES_DIR/db/schema.sql"       "$TARGET/db/schema.sql"
cp "$RULES_DIR/db/build-index.sh"   "$TARGET/db/build-index.sh"
cp "$RULES_DIR/db/query-rules.sh"   "$TARGET/db/query-rules.sh"
chmod +x "$TARGET/db/build-index.sh" "$TARGET/db/query-rules.sh"
echo "  [✓] db/ (FTS5 schema + scripts)"

# 5. hooks/ — Claude Code UserPromptSubmit hook (guaranteed rule injection)
mkdir -p "$TARGET/hooks"
cp "$RULES_DIR/hooks/inject-rules.sh"  "$TARGET/hooks/inject-rules.sh"
cp "$RULES_DIR/hooks/setup-hooks.sh"   "$TARGET/hooks/setup-hooks.sh"
chmod +x "$TARGET/hooks/inject-rules.sh" "$TARGET/hooks/setup-hooks.sh"
echo "  [✓] hooks/ (UserPromptSubmit rule injector)"

# 6. Build initial FTS5 index
echo ""
if command -v sqlite3 &>/dev/null; then
  echo "Building FTS5 rule index..."
  bash "$TARGET/db/build-index.sh" "$TARGET"
else
  echo "Warning: sqlite3 not found — skipping index build."
  echo "  Install sqlite3 and run: $TARGET/db/build-index.sh"
fi

# 7. Register Claude Code hook
echo "Registering UserPromptSubmit hook..."
bash "$TARGET/hooks/setup-hooks.sh" "$TARGET"

echo ""
echo "Done. Next steps:"
echo ""
echo "  1. Edit PROJECT_RULES.md with your stack, team conventions, and overrides"
echo "  2. Run: db/build-index.sh   (after updating PROJECT_RULES.md)"
echo "  3. Open the project in Claude Code — it will read CLAUDE.md automatically"
echo ""
echo "Query rules by topic:"
echo "  db/query-rules.sh \"security\""
echo "  db/query-rules.sh \"test mock\""
echo "  db/query-rules.sh \"naming\""
echo ""
echo "To update rules later:"
echo "  Option A: git -C ~/claude-token-saver pull && bash ~/claude-token-saver/install.sh ."
echo "  Option B: git submodule update --remote .claude-token-saver && bash .claude-token-saver/install.sh ."
echo ""
echo "  (After first update, use update.sh instead of install.sh)"
