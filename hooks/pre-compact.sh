#!/usr/bin/env bash
# Claude Code — PreCompact hook
# Fires before context compaction (manual /compact or automatic at 70% threshold).
# Refreshes the project snapshot so the post-compaction context is accurate
# without Claude needing to re-read any files.

set -euo pipefail

command -v python3 &>/dev/null || exit 0

INPUT=$(cat)

CWD=$(python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('cwd', ''))
except Exception:
    print('')
" <<< "$INPUT")

[[ -n "$CWD" ]] || CWD="$(pwd)"

SNAPSHOT_SCRIPT="$CWD/scripts/snapshot.sh"
[[ -f "$SNAPSHOT_SCRIPT" ]] || exit 0

bash "$SNAPSHOT_SCRIPT" "$CWD" >/dev/null 2>&1 || true
