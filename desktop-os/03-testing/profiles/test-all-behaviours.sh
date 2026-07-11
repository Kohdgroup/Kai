#!/usr/bin/env bash

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

FIXTURE_ROOT="${1:-$TEST_ROOT/fixtures/behaviour}"
RESULT_DIR="${TEST_RESULT_DIR:-$TEST_ROOT/results}"
RUN_ID="${TEST_RUN_ID:-$(date -u +%Y%m%dT%H%M%SZ)}"

mkdir -p "$RESULT_DIR"

FIXTURES=()
FAILED_FIXTURES=()

while IFS= read -r fixture; do
    [[ -n "$fixture" ]] && FIXTURES+=("$fixture")
done < <(
    find "$FIXTURE_ROOT" \
        -maxdepth 1 \
        -type f \
        -name '*.json' \
        | sort
)

if [[ "${#FIXTURES[@]}" -eq 0 ]]; then
    echo "No behavioural fixtures found: $FIXTURE_ROOT" >&2
    exit 2
fi

TOTAL=0
PASSED=0
FAILED=0

echo
echo "### Governed profile behaviours"
echo "Discovered ${#FIXTURES[@]} behavioural fixtures."

for fixture in "${FIXTURES[@]}"; do
    TOTAL=$((TOTAL + 1))

    if TEST_RUN_ID="$RUN_ID" \
       "$SCRIPT_DIR/test-profile-behaviour.py" \
       "$fixture" \
       --results-dir "$RESULT_DIR"; then
        PASSED=$((PASSED + 1))
    else
        FAILED=$((FAILED + 1))
        FAILED_FIXTURES+=("$(basename "$fixture")")
    fi
done

if [[ "$FAILED" -eq 0 ]]; then
    OUTCOME="PASSED"
else
    OUTCOME="FAILED"
fi

SUMMARY_FILE="$RESULT_DIR/behaviours-summary-${RUN_ID}.json"
FAILED_FIXTURES_FILE="$RESULT_DIR/.failed-fixtures-${RUN_ID}.txt"

: > "$FAILED_FIXTURES_FILE"

if [[ "$FAILED" -gt 0 ]]; then
    for failed_fixture in "${FAILED_FIXTURES[@]}"; do
        printf '%s\n' "$failed_fixture" >> "$FAILED_FIXTURES_FILE"
    done
fi

python3 - \
    "$SUMMARY_FILE" \
    "$FAILED_FIXTURES_FILE" \
    "$RUN_ID" \
    "$TOTAL" \
    "$PASSED" \
    "$FAILED" \
    "$OUTCOME" <<'PY'
import json
import sys
from pathlib import Path

summary_file = Path(sys.argv[1])
failed_fixtures_file = Path(sys.argv[2])
run_id = sys.argv[3]
total = int(sys.argv[4])
passed = int(sys.argv[5])
failed = int(sys.argv[6])
outcome = sys.argv[7]

failed_fixtures = []

if failed_fixtures_file.exists():
    failed_fixtures = [
        line.strip()
        for line in failed_fixtures_file.read_text(
            encoding="utf-8"
        ).splitlines()
        if line.strip()
    ]

payload = {
    "schema_version": "1.0",
    "suite": "KOHD governed profile behavioural certification",
    "run_id": run_id,
    "outcome": outcome,
    "total": total,
    "passed": passed,
    "failed": failed,
    "failed_fixtures": failed_fixtures,
}

summary_file.write_text(
    json.dumps(payload, indent=2) + "\n",
    encoding="utf-8",
)
PY

rm -f "$FAILED_FIXTURES_FILE"

echo
echo "Behavioural certification summary"
echo "Total:   $TOTAL"
echo "Passed:  $PASSED"
echo "Failed:  $FAILED"
echo "Outcome: $OUTCOME"
echo "Report:  $SUMMARY_FILE"

if [[ "$FAILED" -gt 0 ]]; then
    echo "Failed fixtures:"

    for failed_fixture in "${FAILED_FIXTURES[@]}"; do
        printf '  %s\n' "$failed_fixture"
    done
fi

if [[ "$FAILED" -eq 0 ]]; then
    exit 0
fi

exit 1
