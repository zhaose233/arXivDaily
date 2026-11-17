#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <arxiv_id>" >&2
    exit 1
fi

ARXIV_ID="${1%v[0-9]*}"
URL="https://inspirehep.net/api/arxiv/${ARXIV_ID}"

TMP_RESP="$(mktemp)"
trap 'rm -f "$TMP_RESP"' EXIT

HTTP_CODE="$(curl -sS -w "%{http_code}" -o "$TMP_RESP" "$URL")"

if [ "$HTTP_CODE" = "404" ]; then
    echo "INSPIRE_STATUS: NOT_INDEXED_YET (Check TeX preamble for affiliations/report numbers)"
    exit 0
elif [ "$HTTP_CODE" != "200" ]; then
    echo "INSPIRE_STATUS: HTTP_${HTTP_CODE}"
    exit 0
fi

if command -v jq >/dev/null 2>&1; then
    jq '{
        inspire_id: .id,
        title: (.metadata.titles[0].title // ""),
        document_type: (.metadata.document_type // []),
        collaborations: [(.metadata.collaborations // [])[].value],
        report_numbers: [(.metadata.report_numbers // [])[].value],
        citation_count: (.metadata.citation_count // 0),
        total_authors: ((.metadata.authors // []) | length),
        first_authors: [(.metadata.authors // [])[:10][].full_name],
        affiliations: ([(.metadata.authors // [])[:20][].affiliations[]?.value] | unique)
    }' "$TMP_RESP"
else
    echo "NOTE: jq not installed; showing truncated raw JSON"
    head -c 4000 "$TMP_RESP"
fi