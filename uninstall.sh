#!/usr/bin/env bash
# Removes claude-token-saver from a target project.
# Usage: uninstall.sh [target-dir]
#
# What gets removed:
#   - Hook registrations + env vars from .claude/settings.json
#   - docs/, db/, hooks/, scripts/ directories
#   - .claudeignore, update.sh, VERSION (if installed by claude-token-saver)
#   - CLAUDE.md and PROJECT_RULES.md (with confirmation — you may have customized these)

set -euo pipefail

TARGET="${1:-$(pwd)}"

if [[ ! -d "$TARGET" ]]; then
  echo "Error: directory does not exist: $TARGET" >&2
  exit 1
fi

echo "Uninstalling claude-token-saver from: $TARGET"
echo ""

# ── Step 1: Remove hooks + env vars from .claude/settings.json ────────────────

SETTINGS="$TARGET/.claude/settings.json"

if [[ -f "$SETTINGS" ]] && command -v python3 &>/dev/null; then
  python3 - "$SETTINGS" <<'PYEOF'
import sys, json, os

settings_path = sys.argv[1]

OUR_MARKERS = [
    "session-start", "inject-rules", "pre-tool-guard",
    "post-tool-trim", "pre-compact", "context-guard",
]

OUR_ENV_KEYS = [
    "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE",
    "BASH_MAX_OUTPUT_LENGTH",
    "MAX_MCP_OUTPUT_TOKENS",
]

with open(settings_path) as f:
    try:
        settings = json.load(f)
    except json.JSONDecodeError:
        print("  [!] settings.json is invalid JSON — skipping")
        sys.exit(0)

removed_hooks = 0
removed_env   = 0

# Remove our hook entries
if "hooks" in settings:
    for event, entries in list(settings["hooks"].items()):
        cleaned = [
            e for e in entries
            if not any(
                marker in h.get("command", "")
                for h in e.get("hooks", [])
                for marker in OUR_MARKERS
            )
        ]
        removed_hooks += len(entries) - len(cleaned)
        if cleaned:
            settings["hooks"][event] = cleaned
        else:
            del settings["hooks"][event]

# Remove our env vars (only the ones we set)
if "env" in settings:
    for key in OUR_ENV_KEYS:
        if key in settings["env"]:
            del settings["env"][key]
            removed_env += 1
    if not settings["env"]:
        del settings["env"]

with open(settings_path, "w") as f:
    json.dump(settings, f, indent=2)

print(f"  [✓] settings.json: removed {removed_hooks} hook(s), {removed_env} env var(s)")
PYEOF
else
  echo "  [~] .claude/settings.json not found — skipping hook cleanup"
fi

# ── Step 2: Remove installed directories ──────────────────────────────────────

for dir in docs db hooks scripts; do
  if [[ -d "$TARGET/$dir" ]]; then
    rm -rf "$TARGET/$dir"
    echo "  [✓] $dir/ removed"
  fi
done

# ── Step 3: Remove standalone files ──────────────────────────────────────────

for file in .claudeignore update.sh VERSION; do
  if [[ -f "$TARGET/$file" ]]; then
    rm -f "$TARGET/$file"
    echo "  [✓] $file removed"
  fi
done

# ── Step 4: Ask before removing CLAUDE.md (user may have customized it) ──────

if [[ -f "$TARGET/CLAUDE.md" ]]; then
  echo ""
  read -r -p "Remove CLAUDE.md? You may have customized it. [y/N] " answer
  if [[ "${answer,,}" == "y" ]]; then
    rm -f "$TARGET/CLAUDE.md"
    echo "  [✓] CLAUDE.md removed"
  else
    echo "  [~] CLAUDE.md kept"
  fi
fi

# ── Step 5: Ask before removing PROJECT_RULES.md ─────────────────────────────

if [[ -f "$TARGET/PROJECT_RULES.md" ]]; then
  echo ""
  read -r -p "Remove PROJECT_RULES.md? This contains your project overrides. [y/N] " answer
  if [[ "${answer,,}" == "y" ]]; then
    rm -f "$TARGET/PROJECT_RULES.md"
    echo "  [✓] PROJECT_RULES.md removed"
  else
    echo "  [~] PROJECT_RULES.md kept"
  fi
fi

# ── Step 6: Clean up .claude/ if now empty ────────────────────────────────────

if [[ -d "$TARGET/.claude" ]]; then
  # Remove auto-generated snapshot; leave user files
  rm -f "$TARGET/.claude/project-snapshot.md"
  # Remove .claude/ dir only if empty
  if [[ -z "$(ls -A "$TARGET/.claude" 2>/dev/null)" ]]; then
    rmdir "$TARGET/.claude"
    echo "  [✓] .claude/ removed (was empty)"
  else
    echo "  [~] .claude/ kept (contains other files)"
  fi
fi

echo ""
echo "Uninstall complete."
