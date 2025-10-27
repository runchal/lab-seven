#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 1 ]]; then
  cat <<'EOF'
Usage: scripts/validate-write-scope.sh <entry-id> [base-branch]

Checks the current branch diff against the files_write_scope declared in AGENT-EXCHANGE.md.
EOF
  exit 1
fi

ENTRY_ID="$1"
BASE_BRANCH="${2:-main}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

python3 - "$ENTRY_ID" "$BASE_BRANCH" <<'PY'
import fnmatch
import re
import subprocess
import sys
from pathlib import Path

entry_id = sys.argv[1]
base_branch = sys.argv[2]
log_path = Path("AGENT-EXCHANGE.md")

if not log_path.exists():
    sys.exit("AGENT-EXCHANGE.md not found at repository root.")

text = log_path.read_text()

front_matters = list(re.finditer(r"^---\n(.*?)\n---\n", text, re.MULTILINE | re.DOTALL))

chosen = None
for match in front_matters:
    front = match.group(1)
    if re.search(rf"^id:\s*{re.escape(entry_id)}\b", front, re.MULTILINE):
        chosen = front
        break

if chosen is None:
    sys.exit(f"No entry with id {entry_id} found.")

patterns: list[str] = []
collect = False
for line in chosen.splitlines():
    if collect:
        if line.startswith("  - "):
            value = line[4:].strip()
            if value and "path/or/glob" not in value and value.upper() != "TBD":
                patterns.append(value)
        elif line.startswith(" ") and not line.strip():
            continue
        else:
            collect = False
    if line.startswith("files_write_scope:"):
        collect = True

if not patterns:
    print(f"Warning: entry {entry_id} has an empty files_write_scope.", file=sys.stderr)
    sys.exit(0)

merge_base = subprocess.check_output(["git", "merge-base", base_branch, "HEAD"], text=True).strip()
diff_output = subprocess.check_output(["git", "diff", "--name-only", merge_base, "HEAD"], text=True)
changed_files = [line.strip() for line in diff_output.splitlines() if line.strip()]

if not changed_files:
    print(f"No changes detected between {merge_base[:7]} and HEAD. Scope validation passed.")
    sys.exit(0)

violations = []

for path in changed_files:
    if any(fnmatch.fnmatch(path, pattern) for pattern in patterns):
        continue
    violations.append(path)

if violations:
    print("Write scope violations detected:")
    for path in violations:
        print(f"  - {path}")
    print("\nDeclared files_write_scope patterns:")
    for pattern in patterns:
        print(f"  - {pattern}")
    sys.exit(1)

print(f"All changed files comply with files_write_scope for {entry_id}.")
PY
