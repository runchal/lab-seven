#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
  cat <<'EOF'
Usage: scripts/agent.sh <command> [args...]
Commands:
  print "<prompt>"   Send prompt to available agent CLI using --print
  plan  "<prompt>"   Invoke scripts/agent-plan.sh with prompt
  impl  [args...]    Invoke scripts/agent-impl.sh (interactive by default)
EOF
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

COMMAND="$1"
shift

CLAUDE_BIN="${CLAUDE_BIN:-claude}"
CODEX_BIN="${CODEX_BIN:-codex}"

case "$COMMAND" in
  print)
    if [[ $# -lt 1 ]]; then
      echo "Error: print command requires a prompt." >&2
      exit 1
    fi
    if command -v "$CLAUDE_BIN" >/dev/null 2>&1; then
      "$CLAUDE_BIN" --print "$@"
    elif command -v "$CODEX_BIN" >/dev/null 2>&1; then
      "$CODEX_BIN" --print "$@"
    else
      echo "Error: neither \$CLAUDE_BIN ($CLAUDE_BIN) nor \$CODEX_BIN ($CODEX_BIN) is available on PATH." >&2
      exit 1
    fi
    ;;
  plan)
    "$ROOT_DIR/scripts/agent-plan.sh" "$@"
    ;;
  impl)
    "$ROOT_DIR/scripts/agent-impl.sh" "$@"
    ;;
  *)
    usage
    exit 1
    ;;
esac
