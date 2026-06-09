#!/usr/bin/env bash
# Registers all claude-token-saver hooks in .claude/settings.json
# Safe to run multiple times — skips entries that already exist.
# Usage: hooks/setup-hooks.sh [target-dir]

set -euo pipefail

TARGET="${1:-$(pwd)}"
SETTINGS_DIR="$TARGET/.claude"
SETTINGS="$SETTINGS_DIR/settings.json"

mkdir -p "$SETTINGS_DIR"

if ! command -v python3 &>/dev/null; then
  echo "Error: python3 is required to register hooks." >&2
  echo "  Install python3 and re-run: hooks/setup-hooks.sh" >&2
  exit 1
fi

python3 - "$SETTINGS" <<'PYEOF'
import sys, json, os

settings_path = sys.argv[1]

HOOKS_TO_REGISTER = [
    {
        "event": "SessionStart",
        "marker": "session-start",
        "entry": {
            "hooks": [{"type": "command", "command": "bash hooks/session-start.sh"}]
        }
    },
    {
        "event": "UserPromptSubmit",
        "marker": "inject-rules",
        "entry": {
            "hooks": [{"type": "command", "command": "bash hooks/inject-rules.sh"}]
        }
    },
    {
        "event": "PreToolUse",
        "marker": "pre-tool-guard",
        "entry": {
            "hooks": [{"type": "command", "command": "bash hooks/pre-tool-guard.sh"}]
        }
    },
    {
        "event": "PostToolUse",
        "marker": "post-tool-trim",
        "entry": {
            "hooks": [{"type": "command", "command": "bash hooks/post-tool-trim.sh"}]
        }
    },
    {
        "event": "Stop",
        "marker": "context-guard",
        "entry": {
            "hooks": [{"type": "command", "command": "bash hooks/context-guard.sh"}]
        }
    },
]

# Load existing settings or start fresh
if os.path.exists(settings_path):
    with open(settings_path) as f:
        try:
            settings = json.load(f)
        except json.JSONDecodeError:
            settings = {}
else:
    settings = {}

settings.setdefault("hooks", {})

for hook_def in HOOKS_TO_REGISTER:
    event   = hook_def["event"]
    marker  = hook_def["marker"]
    entry   = hook_def["entry"]

    settings["hooks"].setdefault(event, [])

    # Idempotency check
    already = any(
        marker in h.get("command", "")
        for e in settings["hooks"][event]
        for h in e.get("hooks", [])
    )

    if already:
        print(f"  [~] {event}/{marker} already registered")
    else:
        settings["hooks"][event].append(entry)
        print(f"  [✓] {event}/{marker} registered")

with open(settings_path, "w") as f:
    json.dump(settings, f, indent=2)
PYEOF
