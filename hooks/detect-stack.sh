#!/usr/bin/env bash
# Detects the programming language and framework in a project directory.
# Usage: detect-stack.sh [target-dir]
#
# Writes .claude/stack.env in the target directory:
#   LANG=typescript   (typescript|javascript|python|go|rust|java|php|ruby|unknown)
#   FRAMEWORK=nextjs  (framework slug or "none")
#
# Also copies active rule files into docs/:
#   docs/language-rules.md
#   docs/framework-rules.md
#
# The rules/ directory must exist in the same location as this script
# (installed by install.sh as TARGET/rules/).

set -euo pipefail

TARGET="${1:-$(pwd)}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RULES_DIR="$TARGET/rules"
STACK_FILE="$TARGET/.claude/stack.env"

# ── Language detection ────────────────────────────────────────────────────────

detect_language() {
  local dir="$1"
  # Backend-specific files take priority over package.json (which many backend
  # projects include for frontend tooling like Vite or Mix)
  if [[ -f "$dir/pubspec.yaml" ]]; then
    echo "dart"
  elif [[ -f "$dir/composer.json" ]]; then
    echo "php"
  elif [[ -f "$dir/Gemfile" ]]; then
    echo "ruby"
  elif [[ -f "$dir/go.mod" ]]; then
    echo "go"
  elif [[ -f "$dir/Cargo.toml" ]]; then
    echo "rust"
  elif [[ -f "$dir/pom.xml" || -f "$dir/build.gradle" || -f "$dir/build.gradle.kts" ]]; then
    echo "java"
  elif [[ -f "$dir/requirements.txt" || -f "$dir/pyproject.toml" || -f "$dir/setup.py" || -f "$dir/setup.cfg" ]]; then
    echo "python"
  elif [[ -f "$dir/tsconfig.json" ]]; then
    echo "typescript"
  elif [[ -f "$dir/package.json" ]]; then
    echo "javascript"
  else
    echo "unknown"
  fi
}

# ── Framework detection ───────────────────────────────────────────────────────

detect_framework() {
  local dir="$1"
  local lang="$2"

  case "$lang" in
    dart)
      if [[ -f "$dir/pubspec.yaml" ]]; then
        grep -q "flutter:" "$dir/pubspec.yaml" 2>/dev/null && echo "flutter" && return
      fi
      ;;
    typescript|javascript)
      if [[ -f "$dir/package.json" ]]; then
        local pkg
        pkg=$(cat "$dir/package.json" 2>/dev/null || echo '{}')
        # Next.js first — superset of React
        echo "$pkg" | grep -q '"next"'     && echo "nextjs"   && return
        echo "$pkg" | grep -q '"react"'    && echo "react"    && return
        echo "$pkg" | grep -q '"vue"'      && echo "vue"      && return
        echo "$pkg" | grep -q '"express"'  && echo "express"  && return
        echo "$pkg" | grep -q '"fastify"'  && echo "fastify"  && return
      fi
      ;;
    python)
      local deps=""
      for f in "$dir/requirements.txt" "$dir/pyproject.toml" "$dir/setup.py" "$dir/setup.cfg"; do
        [[ -f "$f" ]] && deps+=$(cat "$f" 2>/dev/null || true)
      done
      echo "$deps" | grep -qi "fastapi" && echo "fastapi" && return
      echo "$deps" | grep -qi "django"  && echo "django"  && return
      echo "$deps" | grep -qi "flask"   && echo "flask"   && return
      ;;
    go)
      if [[ -f "$dir/go.mod" ]]; then
        grep -q "gin-gonic/gin"  "$dir/go.mod" 2>/dev/null && echo "gin"  && return
        grep -q "labstack/echo"  "$dir/go.mod" 2>/dev/null && echo "echo" && return
        grep -q "go-chi/chi"     "$dir/go.mod" 2>/dev/null && echo "chi"  && return
      fi
      ;;
    ruby)
      if [[ -f "$dir/Gemfile" ]]; then
        grep -q "rails"   "$dir/Gemfile" 2>/dev/null && echo "rails"   && return
        grep -q "sinatra" "$dir/Gemfile" 2>/dev/null && echo "sinatra" && return
      fi
      ;;
    php)
      if [[ -f "$dir/composer.json" ]]; then
        grep -qi "laravel"  "$dir/composer.json" 2>/dev/null && echo "laravel"  && return
        grep -qi "symfony"  "$dir/composer.json" 2>/dev/null && echo "symfony"  && return
      fi
      ;;
    java)
      for f in "$dir/pom.xml" "$dir/build.gradle" "$dir/build.gradle.kts"; do
        [[ -f "$f" ]] && grep -q "spring" "$f" 2>/dev/null && echo "spring" && return
      done
      ;;
    rust)
      if [[ -f "$dir/Cargo.toml" ]]; then
        grep -q "actix-web" "$dir/Cargo.toml" 2>/dev/null && echo "actix" && return
        grep -q '"axum"'    "$dir/Cargo.toml" 2>/dev/null && echo "axum"  && return
      fi
      ;;
  esac

  echo "none"
}

# ── Apply rules to docs/ ─────────────────────────────────────────────────────

apply_rules() {
  local lang="$1"
  local framework="$2"

  mkdir -p "$TARGET/docs"

  # Language rules
  local lang_src="$RULES_DIR/languages/$lang.md"
  if [[ -f "$lang_src" ]]; then
    cp "$lang_src" "$TARGET/docs/language-rules.md"
  elif [[ -f "$TARGET/docs/language-rules.md" ]]; then
    rm -f "$TARGET/docs/language-rules.md"
  fi

  # Framework rules
  local fw_src="$RULES_DIR/frameworks/$framework.md"
  if [[ "$framework" != "none" && -f "$fw_src" ]]; then
    cp "$fw_src" "$TARGET/docs/framework-rules.md"
  elif [[ -f "$TARGET/docs/framework-rules.md" ]]; then
    rm -f "$TARGET/docs/framework-rules.md"
  fi
}

# ── Main ─────────────────────────────────────────────────────────────────────

LANG=$(detect_language "$TARGET")
FRAMEWORK=$(detect_framework "$TARGET" "$LANG")

# Persist stack for hooks to read
mkdir -p "$TARGET/.claude"
printf 'LANG=%s\nFRAMEWORK=%s\n' "$LANG" "$FRAMEWORK" > "$STACK_FILE"

# Copy active rule files into docs/ only if rules/ is present
if [[ -d "$RULES_DIR" ]]; then
  apply_rules "$LANG" "$FRAMEWORK"
fi

# Echo result for callers (install.sh, session-start.sh)
echo "LANG=$LANG"
echo "FRAMEWORK=$FRAMEWORK"
