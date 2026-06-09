#!/usr/bin/env bash
# Claude Code — UserPromptSubmit hook
# Automatically injects relevant rules into Claude's context on every prompt.
# This runs OUTSIDE Claude's decision loop — guaranteed execution, not instruction-based.
#
# How it works:
#   1. Receives the user's prompt from Claude Code via stdin (JSON)
#   2. Extracts meaningful keywords from the prompt
#   3. Queries the FTS5 rule index for matching sections
#   4. Returns matching rules as additionalContext → Claude Code injects them automatically

set -euo pipefail

command -v python3 &>/dev/null || exit 0

INPUT=$(cat)

# Extract prompt and working directory from Claude Code's hook input
PROMPT=$(python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('prompt', ''))
except Exception:
    print('')
" <<< "$INPUT")

CWD=$(python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('cwd', '.'))
except Exception:
    print('.')
" <<< "$INPUT")

DB="$CWD/db/rules.db"

# No database → skip silently (don't break Claude Code)
[[ -f "$DB" ]] || exit 0
command -v sqlite3 &>/dev/null || exit 0

# Extract meaningful keywords from the prompt.
# Skip stopwords and short words; take top 6 terms for the FTS5 query.
STOPWORDS="^(the|and|for|are|but|not|you|all|any|can|had|was|one|our|out|day|get|has|him|his|how|its|new|now|old|see|two|who|did|let|put|say|she|too|use|with|this|that|have|from|they|will|been|when|were|what|your|more|also|into|some|than|then|them|make|like|time|just|know|take|each|does|both|here|well|even|back|such|most|over|before|after|first|where|these|those|much|find|need|want|work|help|code|file|run|add|set|via|using|want|should|would|could|please|there|their|about|which|write|create|update|change|show|tell|make|sure|check)$"

KEYWORDS=$(echo "$PROMPT" \
  | tr '[:upper:]' '[:lower:]' \
  | tr -cs 'a-z0-9' '\n' \
  | grep -Ev "$STOPWORDS" \
  | awk 'length > 3' \
  | sort -u \
  | head -6 \
  | tr '\n' ' ' \
  | sed 's/[[:space:]]*$//')

# No usable keywords → skip
[[ -n "$KEYWORDS" ]] || exit 0

# Build FTS5 OR query (each keyword is an independent term)
FTS5_QUERY=$(echo "$KEYWORDS" \
  | tr ' ' '\n' \
  | sed "s/'/''/g" \
  | awk '{printf "%s OR ", $0}' \
  | sed 's/ OR $//')

# Query the FTS5 index — return top 3 most relevant rule sections
RULES=$(sqlite3 "$DB" \
  "SELECT '[' || source || '] ' || section || char(10) || content
   FROM rules
   WHERE rules MATCH '$FTS5_QUERY'
   ORDER BY rank
   LIMIT 3;" 2>/dev/null || true)

# No matches → exit cleanly
[[ -n "$RULES" ]] || exit 0

# Return additionalContext — Claude Code injects this before Claude sees the prompt
python3 - "$RULES" <<'PYEOF'
import sys, json

rules = sys.argv[1].strip()
result = {
    "hookSpecificOutput": {
        "hookEventName": "UserPromptSubmit",
        "additionalContext": (
            "=== Relevant rules for this task (auto-injected) ===\n"
            + rules
            + "\n=== End of auto-injected rules ==="
        )
    }
}
print(json.dumps(result))
PYEOF
