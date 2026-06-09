#!/usr/bin/env bash
# Claude Code — PreToolUse hook
# Intercepts expensive Bash commands before execution and warns Claude
# to use token-efficient alternatives. Does NOT hard-block — injects
# additionalContext so Claude can self-correct before running the command.

set -euo pipefail

command -v python3 &>/dev/null || exit 0

INPUT=$(cat)

TOOL_NAME=$(python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_name', ''))
except Exception:
    print('')
" <<< "$INPUT")

# Only intercept Bash tool calls
[[ "$TOOL_NAME" == "Bash" ]] || exit 0

COMMAND=$(python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', {}).get('command', ''))
except Exception:
    print('')
" <<< "$INPUT")

WARN=""

# --- Expensive pattern detection ---

# cat <file> with no pipe — reads entire file into context
if echo "$COMMAND" | grep -qE '^\s*cat\s+\S+\s*$'; then
  FILE=$(echo "$COMMAND" | awk '{print $2}')
  WARN="'cat $FILE' reads the entire file. Use the Read tool with offset+limit instead: Read $FILE --offset 1 --limit 80"
fi

# grep -r on project root — can scan thousands of files
if echo "$COMMAND" | grep -qE 'grep\s+(-[a-zA-Z]*r[a-zA-Z]*|--recursive)\s+.*\s+(\.|\./)?\s*$'; then
  WARN="'grep -r .' searches the full tree — can be very expensive. Narrow the path: grep -r pattern src/"
fi

# find without -maxdepth — unbounded directory walk
if echo "$COMMAND" | grep -qE '^\s*find\s+[\./]' && ! echo "$COMMAND" | grep -q 'maxdepth'; then
  WARN="'find' without -maxdepth can list thousands of entries. Add: -maxdepth 3"
fi

# head/tail with very large line count
if echo "$COMMAND" | grep -qE '(head|tail)\s+-n\s+[5-9][0-9]{2,}'; then
  WARN="Large head/tail reads. Use the Read tool with offset+limit for targeted line access."
fi

# No expensive pattern found — allow silently
[[ -n "$WARN" ]] || exit 0

# Inject warning as additionalContext — Claude sees this before deciding to run
python3 - "$WARN" <<'PYEOF'
import sys, json

warning = sys.argv[1]
result = {
    "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "additionalContext": f"[Token Guard] {warning}"
    }
}
print(json.dumps(result))
PYEOF
