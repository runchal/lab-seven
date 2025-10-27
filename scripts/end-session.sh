#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXCHANGE_FILE="${ROOT_DIR}/AGENT-EXCHANGE.md"
SCREENS_DIR="${ROOT_DIR}/docs/screens"
NEXT_TITLE="${1:-Next Request}"  # optional title

if [[ ! -f "$EXCHANGE_FILE" ]]; then
  echo "Error: AGENT-EXCHANGE.md not found. Run from repo root." >&2
  exit 1
fi

# 1. Ensure screenshots exist
if [[ ! -d "$SCREENS_DIR" || -z "$(ls -A "$SCREENS_DIR" 2>/dev/null)" ]]; then
  echo "docs/screens empty or missing; capturing default screenshots..."
  (cd "$ROOT_DIR" && ./scripts/capture-doc-screens.sh) || echo "Screenshot capture failed; please run manually."
else
  echo "docs/screens already contains screenshots; skipping capture."
fi

# 2. Prepared next exchange entry skeleton if not already added
python3 - "$EXCHANGE_FILE" "$NEXT_TITLE" <<'PY'
import sys
from pathlib import Path

log = Path(sys.argv[1]).read_text()
title = sys.argv[2]

def has_placeholder(log):
    marker = "> Insert newest entries directly below this callout."
    tail = log.split(marker, 1)[-1]
    return title in tail

if not has_placeholder(log):
    print(f"Creating new entry '{title}'...")
    import subprocess
    subprocess.run(["./scripts/new-agent-entry.sh", title], check=True)
else:
    print(f"Entry titled '{title}' already present; skipping skeleton.")
PY

# 3. Summaries
(cd "$ROOT_DIR" && git status -sb)

cat <<EOF_SUMMARY

Next steps:
- Fill in the newly created AGENT-EXCHANGE entry for '${NEXT_TITLE}'.
- Review docs/screens/ for captured assets and commit or prune.
- Note any TODO items in TODO.md or the new log entry before the next session.
EOF_SUMMARY

