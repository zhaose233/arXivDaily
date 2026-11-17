#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <arxiv_id> <out_dir>" >&2
    exit 1
fi

ARXIV_ID="$1"
OUT_DIR="$2"
mkdir -p "$OUT_DIR"

TMP_FILE="$(mktemp)"
trap 'rm -f "$TMP_FILE"' EXIT

sleep 1
curl -fsSL -A "hep-arxiv-digest/1.0" \
    "https://arxiv.org/e-print/${ARXIV_ID}" -o "$TMP_FILE"

if tar -tzf "$TMP_FILE" >/dev/null 2>&1; then
    # .tar.gz
    tar -xzf "$TMP_FILE" -C "$OUT_DIR"
    echo "STATUS: EXTRACTED_TAR"
elif gzip -t "$TMP_FILE" >/dev/null 2>&1; then
    # gzip .tex
    gzip -dc "$TMP_FILE" > "${OUT_DIR}/main.tex"
    echo "STATUS: EXTRACTED_SINGLE_TEX"
elif [ "$(head -c 4 "$TMP_FILE" 2>/dev/null || true)" = "%PDF" ]; then
    # pdf only
    echo "STATUS: PDF_ONLY"
    exit 0
else
    # .tex
    cp "$TMP_FILE" "${OUT_DIR}/main.tex"
    echo "STATUS: COPIED_PLAIN_TEX"
fi

echo "TEX_FILES:"
find "$OUT_DIR" -type f \( -name "*.tex" -o -name "*.TEX" \) -exec ls -lh {} + | awk '{print $5, $NF}'