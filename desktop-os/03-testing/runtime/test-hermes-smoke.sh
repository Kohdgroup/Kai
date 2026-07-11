#!/usr/bin/env bash

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=../lib/test-common.sh
source "$TEST_ROOT/lib/test-common.sh"

TEST_SUITE_NAME="KOHD Hermes runtime smoke test"

PROMPT_FILE="$TEST_ROOT/fixtures/runtime/hermes-smoke-test.txt"
EXPECTED_RESPONSE="KOHD_HERMES_RUNTIME_OK"
HERMES_BIN="${HERMES_BIN:-$HOME/.local/bin/hermes}"

RUNNER="$SCRIPT_DIR/run-hermes-test.py"
RESULT_FILE="$TEST_RESULT_DIR/hermes-smoke-${TEST_RUN_ID}.json"

echo
echo "### Hermes runtime smoke test"

assert_file_exists \
    "RUNTIME-001" \
    "$RUNNER" \
    10

assert_executable \
    "RUNTIME-002" \
    "$RUNNER" \
    10

assert_file_exists \
    "RUNTIME-003" \
    "$PROMPT_FILE" \
    10

if [[ -x "$HERMES_BIN" ]]; then
    pass \
        "RUNTIME-004" \
        15 \
        "Hermes CLI is executable" \
        "$HERMES_BIN"
else
    fail \
        "RUNTIME-004" \
        15 \
        "Hermes CLI is executable" \
        "$HERMES_BIN"
fi

EXECUTION_OUTPUT="$(
    TEST_RUN_ID="$TEST_RUN_ID" \
    "$RUNNER" \
        --test-id HERMES-SMOKE-001 \
        --prompt-file "$PROMPT_FILE" \
        --hermes "$HERMES_BIN" \
        --timeout 120 \
        --max-turns 1 \
        --ignore-rules \
        2>&1
)"
EXECUTION_EXIT=$?

if [[ "$EXECUTION_EXIT" -eq 0 ]]; then
    pass \
        "RUNTIME-005" \
        25 \
        "Hermes completes a non-interactive prompt" \
        "exit code 0"
else
    fail \
        "RUNTIME-005" \
        25 \
        "Hermes completes a non-interactive prompt" \
        "exit=$EXECUTION_EXIT output=$EXECUTION_OUTPUT"
fi

RESPONSE_FILE="$TEST_RESULT_DIR/HERMES-SMOKE-001-${TEST_RUN_ID}.response.txt"
METADATA_FILE="$TEST_RESULT_DIR/HERMES-SMOKE-001-${TEST_RUN_ID}.json"

if [[ -f "$RESPONSE_FILE" ]]; then
    ACTUAL_RESPONSE="$(
        python3 - "$RESPONSE_FILE" <<'PY'
from pathlib import Path
import sys

print(Path(sys.argv[1]).read_text(encoding="utf-8").strip())
PY
    )"

    assert_value_equals \
        "RUNTIME-006" \
        "$ACTUAL_RESPONSE" \
        "$EXPECTED_RESPONSE" \
        "Hermes returns the exact expected response" \
        20
else
    fail \
        "RUNTIME-006" \
        20 \
        "Hermes returns the exact expected response" \
        "response file missing"
fi

if [[ -f "$METADATA_FILE" ]] &&
   python3 -m json.tool "$METADATA_FILE" >/dev/null 2>&1; then
    pass \
        "RUNTIME-007" \
        10 \
        "Hermes runtime metadata is valid JSON" \
        "$METADATA_FILE"
else
    fail \
        "RUNTIME-007" \
        10 \
        "Hermes runtime metadata is valid JSON" \
        "missing or invalid metadata"
fi

finish_certification \
    "$RESULT_FILE" \
    "hermes-runtime-smoke" \
    100
