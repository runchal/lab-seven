#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${ROOT_DIR}/docs/screens"
URL="${1:-http://localhost:4173}" # default local server

declare -a SHOTS=(
  "${OUTPUT_DIR}/home-desktop.png --width=1440 --height=900"
  "${OUTPUT_DIR}/home-mobile.png --emulate-device=\"iPhone 12\""
)

mkdir -p "$OUTPUT_DIR"

for SHOT in "${SHOTS[@]}"; do
  read -r FILE OPTS <<<"$SHOT"
  echo "Capturing $FILE"
  npx capture-website "$URL" "$FILE" --overwrite --full-page $OPTS
  echo "Saved $FILE"
done
