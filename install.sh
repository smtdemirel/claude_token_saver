#!/usr/bin/env bash
# Installs claude-token-saver into a target project.
# Usage: install.sh [target-dir]
# Copies CLAUDE.md, docs/, db/, rules/ and creates PROJECT_RULES.md from template.
# Auto-detects language + framework and installs matching rule sets.

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
echo "  [✓] docs/ (code-style, architecture, testing, security, token-budget, error-handling, git-workflow)"

# 3b. rules/ — language + framework rule sets (all installed; active ones copied to docs/ by detect-stack)
mkdir -p "$TARGET/rules/languages" "$TARGET/rules/frameworks"
cp "$RULES_DIR/rules/languages/"*.md "$TARGET/rules/languages/" 2>/dev/null || true
cp "$RULES_DIR/rules/frameworks/"*.md "$TARGET/rules/frameworks/" 2>/dev/null || true
echo "  [✓] rules/ (languages: ts js dart py go rust java php ruby | frameworks: react nextjs vue flutter express fastapi django flask gin spring rails laravel actix)"

# 4. db/ — FTS5 index tooling
mkdir -p "$TARGET/db"
cp "$RULES_DIR/db/schema.sql"       "$TARGET/db/schema.sql"
cp "$RULES_DIR/db/build-index.sh"   "$TARGET/db/build-index.sh"
cp "$RULES_DIR/db/query-rules.sh"   "$TARGET/db/query-rules.sh"
chmod +x "$TARGET/db/build-index.sh" "$TARGET/db/query-rules.sh"
echo "  [✓] db/ (FTS5 schema + scripts)"

# 5. hooks/ — guaranteed rule injection + context management
mkdir -p "$TARGET/hooks"
cp "$RULES_DIR/hooks/"*.sh "$TARGET/hooks/"
chmod +x "$TARGET/hooks/"*.sh
echo "  [✓] hooks/ (session-start, inject-rules, detect-stack, pre-tool-guard, post-tool-trim, pre-compact, context-guard)"

# 5b. .claudeignore — de-prioritize noisy directories for proactive scanning
if [[ ! -f "$TARGET/.claudeignore" ]]; then
  cp "$RULES_DIR/templates/.claudeignore" "$TARGET/.claudeignore"
  echo "  [✓] .claudeignore (from template — edit to match your project)"
else
  echo "  [~] .claudeignore already exists — skipping"
fi

# 6. scripts/ — project snapshot generator
mkdir -p "$TARGET/scripts"
cp "$RULES_DIR/scripts/snapshot.sh" "$TARGET/scripts/snapshot.sh"
chmod +x "$TARGET/scripts/snapshot.sh"
echo "  [✓] scripts/snapshot.sh"

# 7. update.sh + uninstall.sh + VERSION
cp "$RULES_DIR/update.sh"    "$TARGET/update.sh"
cp "$RULES_DIR/uninstall.sh" "$TARGET/uninstall.sh"
cp "$RULES_DIR/VERSION"      "$TARGET/VERSION"
chmod +x "$TARGET/update.sh" "$TARGET/uninstall.sh"
echo "  [✓] update.sh + uninstall.sh + VERSION"

# 8. Detect language + framework, copy active rules into docs/
echo ""
echo "Detecting project stack..."
STACK=$(bash "$TARGET/hooks/detect-stack.sh" "$TARGET" 2>/dev/null || true)
DETECTED_LANG=$(echo "$STACK" | grep "^LANG=" | cut -d= -f2 || echo "unknown")
DETECTED_FW=$(echo "$STACK"   | grep "^FRAMEWORK=" | cut -d= -f2 || echo "none")
if [[ "$DETECTED_LANG" != "unknown" ]]; then
  echo "  [✓] Language detected: $DETECTED_LANG"
  [[ "$DETECTED_FW" != "none" ]] && echo "  [✓] Framework detected: $DETECTED_FW" || echo "  [~] No framework detected (rules/frameworks/ available for manual use)"
else
  echo "  [~] Language not detected — add language/framework rules to docs/ manually or re-run detect-stack.sh after adding project files"
fi

# 10. Build initial FTS5 index (now includes language + framework rules in docs/)
echo ""
if command -v sqlite3 &>/dev/null; then
  echo "Building FTS5 rule index..."
  bash "$TARGET/db/build-index.sh" "$TARGET"
else
  echo "Warning: sqlite3 not found — skipping index build."
  echo "  Install sqlite3 and run: $TARGET/db/build-index.sh"
fi

# 11. Generate initial project snapshot
echo "Generating project snapshot..."
bash "$TARGET/scripts/snapshot.sh" "$TARGET"

# 12. Register all Claude Code hooks
echo "Registering hooks..."
bash "$TARGET/hooks/setup-hooks.sh" "$TARGET"

echo ""
echo "Done. Next steps:"
echo ""
echo "  1. Edit PROJECT_RULES.md with your team conventions and overrides"
echo "  2. Run: db/build-index.sh   (after editing PROJECT_RULES.md)"
echo "  3. Open the project in Claude Code — language + framework rules are injected automatically"
echo ""
echo "Stack detection:"
echo "  Language:  $DETECTED_LANG  (docs/language-rules.md)"
[[ "$DETECTED_FW" != "none" ]] && echo "  Framework: $DETECTED_FW  (docs/framework-rules.md)" || echo "  Framework: not detected — run hooks/detect-stack.sh after adding dependencies"
echo ""
echo "Override active rules:"
echo "  hooks/detect-stack.sh .          # re-detect after adding dependencies"
echo "  cp rules/frameworks/react.md docs/framework-rules.md  # manual override"
echo ""
echo "Query rules by topic:"
echo "  db/query-rules.sh \"security\""
echo "  db/query-rules.sh \"test mock\""
echo "  db/query-rules.sh \"naming\""
echo ""
echo "To update rules later: bash update.sh"
