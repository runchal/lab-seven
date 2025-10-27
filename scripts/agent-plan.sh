#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 1 ]]; then
  cat <<'EOF'
Usage: scripts/agent-plan.sh "Summarize the planning prompt here"

Wraps the available agent CLI in --print mode to request a planning response.
Set CLAUDE_BIN or CODEX_BIN to point to your preferred executable.
EOF
  exit 1
fi

PROMPT="$*"
CLAUDE_BIN="${CLAUDE_BIN:-claude}"
CODEX_BIN="${CODEX_BIN:-codex}"

FULL_PROMPT=$'You are generating a joint plan for Codex and Claude Code.\nRespond with proposed steps, risks, and open questions.\n\n'"$PROMPT"

if command -v "$CLAUDE_BIN" >/dev/null 2>&1; then
  VERSION=$("$CLAUDE_BIN" --version 2>/dev/null || echo "unknown")
  >&2 echo "Planning via ${CLAUDE_BIN##*/} (${VERSION})"
  "$CLAUDE_BIN" --print "$FULL_PROMPT"
elif command -v "$CODEX_BIN" >/dev/null 2>&1; then
  VERSION=$("$CODEX_BIN" --version 2>/dev/null || echo "unknown")
  >&2 echo "Planning via ${CODEX_BIN##*/} (${VERSION})"
  "$CODEX_BIN" --print "$FULL_PROMPT"
else
  echo "Error: neither CLAUDE_BIN ($CLAUDE_BIN) nor CODEX_BIN ($CODEX_BIN) is available on PATH." >&2
  exit 1
fi
