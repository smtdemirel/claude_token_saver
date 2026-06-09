#!/usr/bin/env bash
# Claude Code — PostToolUse hook
# After a Bash or Read tool call, injects a brevity reminder when the output
# is likely long. This nudges Claude to extract only what's needed rather than
# echoing large outputs back into the conversation.

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

# Target: Bash and Read tools (most likely to produce large outputs)
[[ "$TOOL_NAME" == "Bash" || "$TOOL_NAME" == "Read" ]] || exit 0

# Check output size — only inject reminder if output is substantial
OUTPUT_LEN=$(python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    output = d.get('tool_response', '') or d.get('tool_result', '') or ''
    print(len(str(output)))
except Exception:
    print(0)
" <<< "$INPUT" 2>/dev/null || echo "0")

# Skip if output is short (< 1500 chars ≈ ~375 tokens)
[[ "$OUTPUT_LEN" -gt 1500 ]] || exit 0

python3 <<'PYEOF'
import json

result = {
    "hookSpecificOutput": {
        "hookEventName": "PostToolUse",
        "additionalContext": (
            "[Token Trim] Output above is long. "
            "Extract only what's needed for the task. "
            "Do not echo or restate the full output."
        )
    }
}
print(json.dumps(result))
PYEOF
