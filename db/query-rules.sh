#!/usr/bin/env bash
# Queries the FTS5 rule index and returns relevant rule sections.
# Usage: db/query-rules.sh <keyword> [limit=5]
# Output: matching section headings and their content.
# Requires: sqlite3

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: query-rules.sh <keyword> [limit=5]" >&2
  echo "Examples:" >&2
  echo "  query-rules.sh security" >&2
  echo "  query-rules.sh \"test mock\" 3" >&2
  exit 1
fi

KEYWORD="$1"
LIMIT="${2:-5}"
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
DB="$ROOT/db/rules.db"

if [[ ! -f "$DB" ]]; then
  echo "Error: $DB not found. Run db/build-index.sh first." >&2
  exit 1
fi

# Sanitize keyword: remove quotes/special chars that break FTS5 syntax
SAFE_KEYWORD="${KEYWORD//[\'\";]/}"

result=$(sqlite3 "$DB" \
  "SELECT '[' || source || '] ' || section || char(10) || content
   FROM rules
   WHERE rules MATCH '$(echo "$SAFE_KEYWORD" | sed "s/'/''/g")'
   ORDER BY rank
   LIMIT $LIMIT;" 2>/dev/null || true)

if [[ -z "$result" ]]; then
  echo "No rules found for: $KEYWORD"
  echo "Try broader terms or run: db/build-index.sh to refresh the index."
  exit 0
fi

echo "$result"
