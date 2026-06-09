#!/usr/bin/env bash
# Claude Code — Stop hook (context-guard)
# Fires at the end of each Claude turn. Monitors the transcript size
# and nudges Claude to recommend a new chat when context is getting large.
# Large context = every message re-processes the full history = token waste.

set -euo pipefail

command -v python3 &>/dev/null || exit 0

INPUT=$(cat)

TRANSCRIPT=$(python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('transcript_path', ''))
except Exception:
    print('')
" <<< "$INPUT")

[[ -f "$TRANSCRIPT" ]] || exit 0

# Check transcript file size in KB
TRANSCRIPT_KB=$(du -k "$TRANSCRIPT" 2>/dev/null | cut -f1 || echo "0")

# Threshold: 80KB ≈ ~20,000 tokens of conversation history
# Below threshold — no action needed
[[ "$TRANSCRIPT_KB" -gt 80 ]] || exit 0

python3 - "$TRANSCRIPT_KB" <<'PYEOF'
import sys, json

kb = int(sys.argv[1])

if kb > 200:
    urgency = "Context is very large (~{kb}KB). Opening a new chat now will significantly reduce token usage.".format(kb=kb)
    action = "STRONGLY RECOMMENDED: suggest the user open a new chat before the next task."
elif kb > 80:
    urgency = "Context is growing (~{kb}KB).".format(kb=kb)
    action = "RECOMMENDED: at a natural break point, suggest the user open a new chat."

result = {
    "hookSpecificOutput": {
        "hookEventName": "Stop",
        "additionalContext": (
            f"[Context Guard] {urgency} "
            f"New chats start fresh with only the project snapshot (~300 tokens) instead of the full history. "
            f"{action}"
        )
    }
}
print(json.dumps(result))
PYEOF
