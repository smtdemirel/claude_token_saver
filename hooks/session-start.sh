#!/usr/bin/env bash
# Claude Code — SessionStart hook
# Fires when a new chat opens. Injects the project snapshot so Claude
# instantly knows the project state without reading any files.
# This makes every new chat feel like a seamless continuation.

set -euo pipefail

INPUT=$(cat)

CWD=$(python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('cwd', '.'))
" <<< "$INPUT")

SNAPSHOT="$CWD/.claude/project-snapshot.md"
SNAPSHOT_SCRIPT="$CWD/scripts/snapshot.sh"

# If snapshot is missing or older than 10 minutes, regenerate
NEEDS_REFRESH=false
if [[ ! -f "$SNAPSHOT" ]]; then
  NEEDS_REFRESH=true
elif [[ $(find "$SNAPSHOT" -mmin +10 2>/dev/null | wc -l) -gt 0 ]]; then
  NEEDS_REFRESH=true
fi

if [[ "$NEEDS_REFRESH" == "true" && -f "$SNAPSHOT_SCRIPT" ]]; then
  bash "$SNAPSHOT_SCRIPT" "$CWD" >/dev/null 2>&1 || true
fi

[[ -f "$SNAPSHOT" ]] || exit 0

CONTENT=$(cat "$SNAPSHOT")
[[ -n "$CONTENT" ]] || exit 0

python3 - "$CONTENT" <<'PYEOF'
import sys, json

content = sys.argv[1]
result = {
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": (
            "=== Project Snapshot (auto-injected at session start) ===\n"
            + content +
            "\n=== Use this context — do not re-read these files to orient yourself ==="
        )
    }
}
print(json.dumps(result))
PYEOF
