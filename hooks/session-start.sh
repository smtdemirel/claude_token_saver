#!/usr/bin/env bash
# Claude Code — SessionStart hook
# Fires when a new chat opens. Injects:
#   1. Project snapshot — instant project state without reading files
#   2. Language rules  — active language best practices (auto-detected)
#   3. Framework rules — active framework best practices (auto-detected)

set -euo pipefail

command -v python3 &>/dev/null || exit 0

INPUT=$(cat)

CWD=$(python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('cwd', '.'))
except Exception:
    print('.')
" <<< "$INPUT")

# ── Project snapshot ──────────────────────────────────────────────────────────

SNAPSHOT="$CWD/.claude/project-snapshot.md"
SNAPSHOT_SCRIPT="$CWD/scripts/snapshot.sh"

NEEDS_REFRESH=false
if [[ ! -f "$SNAPSHOT" ]]; then
  NEEDS_REFRESH=true
elif [[ $(find "$SNAPSHOT" -mmin +10 2>/dev/null | wc -l) -gt 0 ]]; then
  NEEDS_REFRESH=true
fi

if [[ "$NEEDS_REFRESH" == "true" && -f "$SNAPSHOT_SCRIPT" ]]; then
  bash "$SNAPSHOT_SCRIPT" "$CWD" >/dev/null 2>&1 || true
fi

# ── Stack detection (re-runs on every session to pick up new dependencies) ────

DETECT_SCRIPT="$CWD/hooks/detect-stack.sh"
if [[ -f "$DETECT_SCRIPT" ]]; then
  bash "$DETECT_SCRIPT" "$CWD" >/dev/null 2>&1 || true
fi

# Read detected stack for context labels
STACK_ENV="$CWD/.claude/stack.env"
DETECTED_LANG="unknown"
DETECTED_FW="none"
if [[ -f "$STACK_ENV" ]]; then
  DETECTED_LANG=$(grep "^LANG="      "$STACK_ENV" | cut -d= -f2 || echo "unknown")
  DETECTED_FW=$(grep   "^FRAMEWORK=" "$STACK_ENV" | cut -d= -f2 || echo "none")
fi

# ── Build combined additionalContext ──────────────────────────────────────────

SNAPSHOT_CONTENT=""
LANG_CONTENT=""
FW_CONTENT=""

[[ -f "$SNAPSHOT" ]] && SNAPSHOT_CONTENT=$(cat "$SNAPSHOT") || true

LANG_RULES="$CWD/docs/language-rules.md"
[[ -f "$LANG_RULES" ]] && LANG_CONTENT=$(cat "$LANG_RULES") || true

FW_RULES="$CWD/docs/framework-rules.md"
[[ -f "$FW_RULES" ]] && FW_CONTENT=$(cat "$FW_RULES") || true

# At least one section must exist
if [[ -z "$SNAPSHOT_CONTENT" && -z "$LANG_CONTENT" && -z "$FW_CONTENT" ]]; then
  exit 0
fi

python3 - "$SNAPSHOT_CONTENT" "$LANG_CONTENT" "$FW_CONTENT" "$DETECTED_LANG" "$DETECTED_FW" <<'PYEOF'
import sys, json

snapshot  = sys.argv[1].strip()
lang_rules = sys.argv[2].strip()
fw_rules   = sys.argv[3].strip()
lang       = sys.argv[4]
fw         = sys.argv[5]

parts = []

if snapshot:
    parts.append(
        "=== Project Snapshot (auto-injected at session start) ===\n"
        + snapshot +
        "\n=== Use this context — do not re-read these files to orient yourself ==="
    )

if lang_rules:
    parts.append(
        f"=== Language Rules: {lang} (auto-injected) ===\n"
        + lang_rules +
        "\n=== End Language Rules ==="
    )

if fw_rules:
    parts.append(
        f"=== Framework Rules: {fw} (auto-injected) ===\n"
        + fw_rules +
        "\n=== End Framework Rules ==="
    )

result = {
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": "\n\n".join(parts)
    }
}
print(json.dumps(result))
PYEOF
