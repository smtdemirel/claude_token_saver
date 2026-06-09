#!/usr/bin/env bash
# Registers the inject-rules.sh hook in the target project's .claude/settings.json
# Safe to run multiple times — skips if already registered.
# Usage: hooks/setup-hooks.sh [target-dir]

set -euo pipefail

TARGET="${1:-$(pwd)}"
SETTINGS_DIR="$TARGET/.claude"
SETTINGS="$SETTINGS_DIR/settings.json"
HOOK_CMD="bash hooks/inject-rules.sh"

mkdir -p "$SETTINGS_DIR"

python3 - "$SETTINGS" "$HOOK_CMD" <<'PYEOF'
import sys, json, os

settings_path = sys.argv[1]
hook_cmd      = sys.argv[2]

# Load existing settings or start fresh
if os.path.exists(settings_path):
    with open(settings_path) as f:
        try:
            settings = json.load(f)
        except json.JSONDecodeError:
            settings = {}
else:
    settings = {}

# Ensure hooks structure exists
settings.setdefault("hooks", {})
settings["hooks"].setdefault("UserPromptSubmit", [])

# Idempotency: skip if already registered
for entry in settings["hooks"]["UserPromptSubmit"]:
    for h in entry.get("hooks", []):
        if "inject-rules" in h.get("command", ""):
            print(f"  [~] Hook already registered in {settings_path}")
            sys.exit(0)

# Add hook entry
settings["hooks"]["UserPromptSubmit"].append({
    "hooks": [
        {
            "type": "command",
            "command": hook_cmd
        }
    ]
})

with open(settings_path, "w") as f:
    json.dump(settings, f, indent=2)

print(f"  [✓] Hook registered in {settings_path}")
PYEOF
