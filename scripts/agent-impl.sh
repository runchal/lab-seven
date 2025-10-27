#!/usr/bin/env bash

set -euo pipefail

CLAUDE_BIN="${CLAUDE_BIN:-claude}"
CODEX_BIN="${CODEX_BIN:-codex}"

if command -v "$CLAUDE_BIN" >/dev/null 2>&1; then
  exec "$CLAUDE_BIN" "$@"
elif command -v "$CODEX_BIN" >/dev/null 2>&1; then
  exec "$CODEX_BIN" "$@"
else
  echo "Error: neither CLAUDE_BIN ($CLAUDE_BIN) nor CODEX_BIN ($CODEX_BIN) is available on PATH." >&2
  exit 1
fi
