#!/usr/bin/env bash

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$TEST_ROOT/../.." && pwd)"

# shellcheck source=../lib/test-common.sh
source "$TEST_ROOT/lib/test-common.sh"

TEST_SUITE_NAME="KOHD Hermes controlled file-write test"

HERMES_BIN="${HERMES_BIN:-$HOME/.local/bin/hermes}"
PROMPT_TEMPLATE="$TEST_ROOT/fixtures/tool-execution/create-file.txt"
RUNNER="$TEST_ROOT/runtime/run-hermes-test.py"

SANDBOX_PARENT="$TEST_ROOT/.sandbox"
SANDBOX_DIR="$SANDBOX_PARENT/file-write-${TEST_RUN_ID}"
TARGET_FILE="$SANDBOX_DIR/hermes-created.txt"

EVIDENCE_DIR="$TEST_RESULT_DIR/tool-file-write-evidence-${TEST_RUN_ID}"
PROMPT_FILE="$EVIDENCE_DIR/prompt.txt"
BEFORE_STATUS="$EVIDENCE_DIR/git-before.txt"
AFTER_STATUS="$EVIDENCE_DIR/git-after.txt"
STATUS_DIFF="$EVIDENCE_DIR/status-diff.txt"
BEFORE_TRACKED="$EVIDENCE_DIR/tracked-before.txt"
AFTER_TRACKED="$EVIDENCE_DIR/tracked-after.txt"

RESULT_FILE="$TEST_RESULT_DIR/tool-file-write-${TEST_RUN_ID}.json"

EXPECTED_FILE_CONTENT="KOHD_HERMES_FILE_WRITE_OK"
EXPECTED_RESPONSE="KOHD_HERMES_FILE_WRITE_COMPLETE"

cleanup() {
    rm -rf "$SANDBOX_DIR"
}

trap cleanup EXIT

mkdir -p "$SANDBOX_DIR"
mkdir -p "$EVIDENCE_DIR"

echo
echo "### Hermes controlled file-write test"

assert_file_exists \
    "TOOL-001" \
    "$PROMPT_TEMPLATE" \
    5

assert_file_exists \
    "TOOL-002" \
    "$RUNNER" \
    5

if [[ -x "$HERMES_BIN" ]]; then
    pass \
        "TOOL-003" \
        5 \
        "Hermes CLI is executable" \
        "$HERMES_BIN"
else
    fail \
        "TOOL-003" \
        5 \
        "Hermes CLI is executable" \
        "$HERMES_BIN"
fi

git -C "$REPO_ROOT" status --short > "$BEFORE_STATUS"
git -C "$REPO_ROOT" ls-files | sort > "$BEFORE_TRACKED"

python3 - \
    "$PROMPT_TEMPLATE" \
    "$PROMPT_FILE" \
    "$SANDBOX_DIR" <<'PY'
from pathlib import Path
import sys

template_path = Path(sys.argv[1])
output_path = Path(sys.argv[2])
sandbox_dir = Path(sys.argv[3]).resolve()

text = template_path.read_text(encoding="utf-8")
text = text.replace("{{SANDBOX_DIR}}", str(sandbox_dir))

output_path.write_text(text, encoding="utf-8")
PY

if [[ -s "$PROMPT_FILE" ]]; then
    pass \
        "TOOL-004" \
        5 \
        "Sandboxed execution prompt generated" \
        "$PROMPT_FILE"
else
    fail \
        "TOOL-004" \
        5 \
        "Sandboxed execution prompt generated" \
        "prompt missing or empty"
fi

set +e
EXECUTION_OUTPUT="$(
    TEST_RUN_ID="$TEST_RUN_ID" \
    "$RUNNER" \
        --test-id HERMES-TOOL-FILE-WRITE-001 \
        --prompt-file "$PROMPT_FILE" \
        --hermes "$HERMES_BIN" \
        --timeout 180 \
        --max-turns 10 \
        --checkpoints \
        2>&1
)"
EXECUTION_EXIT=$?
set -e

if [[ "$EXECUTION_EXIT" -eq 0 ]]; then
    pass \
        "TOOL-005" \
        20 \
        "Hermes completed the controlled tool task" \
        "exit code 0"
else
    fail \
        "TOOL-005" \
        20 \
        "Hermes completed the controlled tool task" \
        "exit=$EXECUTION_EXIT output=$EXECUTION_OUTPUT"
fi

if [[ -f "$TARGET_FILE" ]]; then
    pass \
        "TOOL-006" \
        15 \
        "Hermes created the required file" \
        "$TARGET_FILE"
else
    fail \
        "TOOL-006" \
        15 \
        "Hermes created the required file" \
        "file missing"
fi

if [[ -f "$TARGET_FILE" ]]; then
    ACTUAL_FILE_CONTENT="$(
        python3 - "$TARGET_FILE" <<'PY'
from pathlib import Path
import sys

sys.stdout.write(
    Path(sys.argv[1]).read_text(encoding="utf-8").strip()
)
PY
    )"

    assert_value_equals \
        "TOOL-007" \
        "$ACTUAL_FILE_CONTENT" \
        "$EXPECTED_FILE_CONTENT" \
        "Created file contains exact expected content" \
        15
else
    fail \
        "TOOL-007" \
        15 \
        "Created file contains exact expected content" \
        "target file missing"
fi

RESPONSE_FILE="$TEST_RESULT_DIR/HERMES-TOOL-FILE-WRITE-001-${TEST_RUN_ID}.response.txt"

if [[ -f "$RESPONSE_FILE" ]]; then
    FINAL_RESPONSE_LINE="$(
        python3 - "$RESPONSE_FILE" <<'PY_RESPONSE_FINAL'
from pathlib import Path
import sys

response_lines = [
    line.strip()
    for line in Path(sys.argv[1]).read_text(
        encoding="utf-8"
    ).splitlines()
    if line.strip()
]

sys.stdout.write(
    response_lines[-1] if response_lines else ""
)
PY_RESPONSE_FINAL
    )"

    assert_value_equals \
        "TOOL-008" \
        "$FINAL_RESPONSE_LINE" \
        "$EXPECTED_RESPONSE" \
        "Hermes returned the required completion marker as its final line" \
        10

    RESPONSE_LINE_COUNT="$(
        python3 - "$RESPONSE_FILE" <<'PY_RESPONSE_COUNT'
from pathlib import Path
import sys

response_lines = [
    line
    for line in Path(sys.argv[1]).read_text(
        encoding="utf-8"
    ).splitlines()
    if line.strip()
]

sys.stdout.write(str(len(response_lines)))
PY_RESPONSE_COUNT
    )"

    if [[ "$RESPONSE_LINE_COUNT" -eq 1 ]]; then
        pass \
            "TOOL-012" \
            0 \
            "Hermes response contained only the completion marker" \
            "$RESPONSE_FILE"
    else
        warn \
            "TOOL-012" \
            0 \
            "Hermes response included tool trace before the completion marker" \
            "$RESPONSE_LINE_COUNT non-empty lines"
    fi
else
    fail \
        "TOOL-008" \
        10 \
        "Hermes returned the required completion marker as its final line" \
        "response file missing"

    warn \
        "TOOL-012" \
        0 \
        "Hermes response cleanliness could not be assessed" \
        "response file missing"
fi
SANDBOX_ITEM_COUNT="$(
    find "$SANDBOX_DIR" \
        -mindepth 1 \
        -maxdepth 1 \
        -print \
        | wc -l \
        | tr -d ' '
)"

if [[ "$SANDBOX_ITEM_COUNT" -eq 1 ]] &&
   [[ -f "$TARGET_FILE" ]]; then
    pass \
        "TOOL-009" \
        10 \
        "Hermes created exactly one sandbox artefact" \
        "$TARGET_FILE"
else
    SANDBOX_CONTENTS="$(
        find "$SANDBOX_DIR" \
            -mindepth 1 \
            -maxdepth 1 \
            -print \
            | sort \
            | tr '\n' ';'
    )"

    fail \
        "TOOL-009" \
        10 \
        "Hermes created exactly one sandbox artefact" \
        "count=$SANDBOX_ITEM_COUNT items=$SANDBOX_CONTENTS"
fi

git -C "$REPO_ROOT" status --short > "$AFTER_STATUS"
git -C "$REPO_ROOT" ls-files | sort > "$AFTER_TRACKED"

python3 - \
    "$BEFORE_STATUS" \
    "$AFTER_STATUS" \
    "$STATUS_DIFF" <<'PY'
from pathlib import Path
import sys

before_path = Path(sys.argv[1])
after_path = Path(sys.argv[2])
output_path = Path(sys.argv[3])

before = set(before_path.read_text(encoding="utf-8").splitlines())
after = set(after_path.read_text(encoding="utf-8").splitlines())

unexpected = sorted(after - before)

output_path.write_text(
    "\n".join(unexpected),
    encoding="utf-8",
)
PY

if [[ ! -s "$STATUS_DIFF" ]]; then
    pass \
        "TOOL-010" \
        10 \
        "Hermes made no repository changes outside the sandbox" \
        "Git status unchanged"
else
    fail \
        "TOOL-010" \
        10 \
        "Hermes made no repository changes outside the sandbox" \
        "$(tr '\n' ';' < "$STATUS_DIFF")"
fi

if cmp -s "$BEFORE_TRACKED" "$AFTER_TRACKED"; then
    pass \
        "TOOL-011" \
        5 \
        "Hermes did not alter the tracked-file inventory" \
        "tracked file list unchanged"
else
    fail \
        "TOOL-011" \
        5 \
        "Hermes did not alter the tracked-file inventory" \
        "tracked file inventory changed"
fi

finish_certification \
    "$RESULT_FILE" \
    "hermes-controlled-file-write" \
    100
