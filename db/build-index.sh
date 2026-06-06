#!/usr/bin/env bash
# Builds (or rebuilds) the SQLite FTS5 rule index from all Markdown files.
# Usage: db/build-index.sh [project-root]
# Requires: sqlite3 (pre-installed on macOS; `apt install sqlite3` on Ubuntu)

set -euo pipefail

ROOT="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
DB="$ROOT/db/rules.db"
SCHEMA="$ROOT/db/schema.sql"
TMPFILE="$(mktemp /tmp/rules_import.XXXXXX.sql)"
trap 'rm -f "$TMPFILE"' EXIT

if ! command -v sqlite3 &>/dev/null; then
  echo "Error: sqlite3 not found." >&2
  echo "  macOS: already included" >&2
  echo "  Ubuntu/Debian: sudo apt install sqlite3" >&2
  exit 1
fi

if [[ ! -f "$SCHEMA" ]]; then
  echo "Error: schema not found at $SCHEMA" >&2
  exit 1
fi

# Initialize (or reset) the database
sqlite3 "$DB" < "$SCHEMA"

# Start building the SQL import file
echo "BEGIN TRANSACTION;" > "$TMPFILE"

# Parse one markdown file into SQL INSERT statements.
# Each ## heading becomes a separate row.
index_file() {
  local file="$1"
  local relative="${file#"$ROOT"/}"
  local section=""
  local content=""

  write_row() {
    if [[ -n "$section" && -n "$content" ]]; then
      # Use python3 for reliable SQL escaping (avoids bash quoting edge cases)
      python3 - "$relative" "$section" "$content" >> "$TMPFILE" <<'PYEOF'
import sys, re

source  = sys.argv[1]
section = sys.argv[2]
content = sys.argv[3]

def esc(s):
    return s.replace("'", "''")

print(f"INSERT INTO rules(source,section,content,tags) VALUES('{esc(source)}','{esc(section)}','{esc(content)}','');")
PYEOF
    fi
  }

  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" =~ ^##[[:space:]] ]]; then
      write_row
      section="$line"
      content=""
    else
      content+="$line"$'\n'
    fi
  done < "$file"

  write_row
}

# Index all relevant markdown files
indexed=0
for md in \
  "$ROOT/CLAUDE.md" \
  "$ROOT/PROJECT_RULES.md" \
  "$ROOT/docs/"*.md; do
  if [[ -f "$md" ]]; then
    index_file "$md"
    ((indexed++))
  fi
done

echo "COMMIT;" >> "$TMPFILE"

# Execute all inserts in one transaction
sqlite3 "$DB" < "$TMPFILE"

total=$(sqlite3 "$DB" 'SELECT COUNT(*) FROM rules;')
echo "Index built: $DB ($indexed files → $total sections)"
