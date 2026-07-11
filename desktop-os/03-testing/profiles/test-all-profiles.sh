#!/usr/bin/env bash

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$TEST_ROOT/../.." && pwd)"

PROFILE_ROOT="${1:-$REPO_ROOT/desktop-os/02-profiles}"
RUN_ID="${TEST_RUN_ID:-$(date -u +%Y%m%dT%H%M%SZ)-$$}"
RESULT_DIR="${TEST_RESULT_DIR:-$TEST_ROOT/results}"

mkdir -p "$RESULT_DIR"

if [[ ! -d "$PROFILE_ROOT" ]]; then
    echo "Profile root not found: $PROFILE_ROOT" >&2
    exit 2
fi

mapfile_compat() {
    while IFS= read -r line; do
        PROFILE_DIRECTORIES+=("$line")
    done
}

PROFILE_DIRECTORIES=()

mapfile_compat < <(
    find "$PROFILE_ROOT" \
        -mindepth 1 \
        -maxdepth 1 \
        -type d \
        -exec test -f '{}/PROFILE.md' ';' \
        -print \
        | sort
)

if [[ "${#PROFILE_DIRECTORIES[@]}" -eq 0 ]]; then
    echo "No governed profiles found under: $PROFILE_ROOT" >&2
    exit 1
fi

TOTAL=0
PASSED=0
FAILED=0

echo
echo "Discovered ${#PROFILE_DIRECTORIES[@]} governed profiles:"
printf '  %s\n' "${PROFILE_DIRECTORIES[@]##*/}"

for profile_directory in "${PROFILE_DIRECTORIES[@]}"; do
    TOTAL=$((TOTAL + 1))

    if TEST_RUN_ID="$RUN_ID" \
       TEST_RESULT_DIR="$RESULT_DIR" \
       "$SCRIPT_DIR/test-profile.sh" "$profile_directory"; then
        PASSED=$((PASSED + 1))
    else
        FAILED=$((FAILED + 1))
    fi
done

SUMMARY_FILE="$RESULT_DIR/profiles-summary-${RUN_ID}.json"

cat > "$SUMMARY_FILE" <<JSON
{
  "schema_version": "1.0",
  "suite": "KOHD Desktop OS governed profile certification",
  "run_id": "$RUN_ID",
  "profile_root": "$PROFILE_ROOT",
  "total": $TOTAL,
  "passed": $PASSED,
  "failed": $FAILED,
  "outcome": "$([[ "$FAILED" -eq 0 ]] && echo PASSED || echo FAILED)"
}
JSON

echo
echo "Profile certification summary"
echo "Total:   $TOTAL"
echo "Passed:  $PASSED"
echo "Failed:  $FAILED"
echo "Report:  $SUMMARY_FILE"

[[ "$FAILED" -eq 0 ]]
