#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_FILE="$ROOT_DIR/AGENT-EXCHANGE.md"

if [[ ! -f "$LOG_FILE" ]]; then
  echo "Error: AGENT-EXCHANGE.md not found at repository root." >&2
  exit 1
fi

if [[ $# -lt 1 ]]; then
  echo "Usage: scripts/new-agent-entry.sh \"Request Title\" [status]" >&2
  exit 1
fi

TITLE="$1"
STATUS="${2:-drafting}"
DATE="$(date +%Y-%m-%d)"

read -r ID SLUG <<EOF
$(python3 - "$LOG_FILE" "$TITLE" <<'PY'
import re
import sys
import unicodedata
from pathlib import Path

log_path = Path(sys.argv[1])
title = sys.argv[2]

def slugify(value: str) -> str:
    value = unicodedata.normalize("NFKD", value).encode("ascii", "ignore").decode("ascii")
    value = value.lower()
    value = re.sub(r"[^a-z0-9]+", "-", value).strip("-")
    return value or "request"

text = log_path.read_text()
ids = [int(match.group(1)) for match in re.finditer(r"^id:\s*AEX-(\d+)", text, re.MULTILINE)]
next_id = (max(ids) + 1) if ids else 1
identifier = f"AEX-{next_id:03d}"
slug = slugify(title)
print(identifier, slug)
PY
)
EOF

ENTRY_FILE="$(mktemp)"
cat >"$ENTRY_FILE" <<EOF
---
id: ${ID}
date: ${DATE}
requester: @${USER:-requester}
dri: @primary
primary: TBD
secondary: TBD
branch: agent/TBD/${SLUG}
files_write_scope:
  - path/or/glob/**
status: ${STATUS}
priority: medium
scope: component
code_location: main
migrates_from: null
ci_backfill_deadline: null
consensus_cycles:
  - timestamp: 
    outcome: 
model_ctx:
  primary: {model: , endpoint: , temperature: , top_p: }
  secondary: {model: , endpoint: , temperature: , top_p: }
environment:
  image: 
  tools:
    - 
assumptions:
  - 
timebox_hours: 2
allowlist:
  - 
acceptance_criteria:
  - 
tests:
  - path/to/test.spec.ts (initial: failing)
ci_gates:
  - lint
  - unit
  - e2e
  - secret-scan
  - sbom
  - license
  - diff-size
risk: medium
impact: 
rollback: 

data_bounds:
  content_length: {min: , max: }
  numeric_range: {min: , max: }
  asset_size: {max_kb: }
  notes: 
---

## Request
- Summary: ${TITLE}
- Constraints: …
- Assets / Links: …

## Secondary Proposal
- Approach: …
- Assumptions: …
- Test Plan: …
- Open Questions: …

## Primary Response
- Assessment: ✅ Good | ⚠️ Concerns | 🛑 Objection
- Feedback: …
- Alternative (if any): …
- Test Execution: …

## Consensus
- Agreement Level: ✅ Agreed | ⚠️ Acceptable with caveats | ❌ Blocked
- Dynamic Range Checklist: content variants reviewed ✅ / needs follow-up ⚠️
- Guardrail Checklist: security, accessibility, performance, localization reviewed ✅ / needs follow-up ⚠️
- Trade-offs & Risks: …
- Recommended Path: …
- Guardrail Checklist: security, accessibility, performance, localization reviewed ✅ / needs follow-up ⚠️

## Implementation & Evidence
- Branch: agent/TBD/${SLUG}
- Diff Review: …
- Diff Size: …
- Files Affected: …
- Tests Added/Updated: …
- CI Status: lint ▢ | unit ▢ | e2e ▢ | secret-scan ▢ | sbom ▢ | license ▢ | diff-size ▢
- SBOM / Reports: …

## User Decision
- Decision: Pending
- Notes: …
- Follow-ups: …

## Notes
- Related Docs: …
- Supersedes: …
- Conflicts: …
- Prompt Archive: prompts/${ID}/

## Rollback Plan
- Summary: …
- Owners: …
- Verification After Rollback: …
EOF

python3 - "$LOG_FILE" "$ENTRY_FILE" <<'PY'
import sys
from pathlib import Path

log_path = Path(sys.argv[1])
entry_path = Path(sys.argv[2])

entry = entry_path.read_text().strip()
text = log_path.read_text()
marker = "## Entries"

if marker not in text:
    raise SystemExit("Marker '## Entries' not found in AGENT-EXCHANGE.md.")

before, after = text.split(marker, 1)
after = after.lstrip("\n")

updated = before + marker + "\n\n" + entry + "\n\n" + after
log_path.write_text(updated)
PY

rm -f "$ENTRY_FILE"

echo "Prepended entry ${ID} for '${TITLE}' to AGENT-EXCHANGE.md."
