#!/usr/bin/env bash

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=../lib/test-common.sh
source "$TEST_ROOT/lib/test-common.sh"

TEST_SUITE_NAME="KOHD Hermes runtime discovery"

RESULT_FILE="$TEST_RESULT_DIR/hermes-runtime-discovery-${TEST_RUN_ID}.json"

echo
echo "### Hermes runtime discovery"

HERMES_APP="/Applications/Hermes.app"
HERMES_SUPPORT="$HOME/Library/Application Support/Hermes"

assert_directory_exists \
    "HERMES-001" \
    "$HERMES_APP" \
    15

assert_directory_exists \
    "HERMES-002" \
    "$HERMES_SUPPORT" \
    10

assert_file_exists \
    "HERMES-003" \
    "$HERMES_SUPPORT/connection.json" \
    10

if [[ -f "$HERMES_SUPPORT/connection.json" ]] &&
   python3 -m json.tool "$HERMES_SUPPORT/connection.json" >/dev/null 2>&1; then
    pass \
        "HERMES-004" \
        10 \
        "Hermes connection configuration is valid JSON" \
        "$HERMES_SUPPORT/connection.json"
else
    fail \
        "HERMES-004" \
        10 \
        "Hermes connection configuration is valid JSON" \
        "missing or invalid JSON"
fi

CLI_CANDIDATES=()

while IFS= read -r candidate; do
    [[ -n "$candidate" ]] && CLI_CANDIDATES+=("$candidate")
done < <(
    {
        command -v hermes 2>/dev/null || true
        command -v hermes-cli 2>/dev/null || true

        find "$HERMES_APP/Contents/MacOS" \
            -maxdepth 2 \
            -type f \
            -perm -111 \
            2>/dev/null || true

        find /opt/homebrew/bin /usr/local/bin "$HOME/.local/bin" \
            -maxdepth 1 \
            -type f \
            \( -iname '*hermes*' -o -iname '*nous*' \) \
            -perm -111 \
            2>/dev/null || true
    } | awk '!seen[$0]++'
)

if [[ "${#CLI_CANDIDATES[@]}" -gt 0 ]]; then
    pass \
        "HERMES-005" \
        20 \
        "At least one Hermes executable was discovered" \
        "$(printf '%s; ' "${CLI_CANDIDATES[@]}")"
else
    fail \
        "HERMES-005" \
        20 \
        "At least one Hermes executable was discovered" \
        "no executable found"
fi

DISCOVERY_FILE="$TEST_RESULT_DIR/hermes-executables-${TEST_RUN_ID}.txt"
: > "$DISCOVERY_FILE"

for candidate in "${CLI_CANDIDATES[@]}"; do
    {
        echo "============================================================"
        echo "EXECUTABLE: $candidate"
        echo
        echo "--- file ---"
        file "$candidate" 2>&1 || true
        echo
        echo "--- --help ---"
        "$candidate" --help 2>&1 || true
        echo
        echo "--- --version ---"
        "$candidate" --version 2>&1 || true
        echo
    } >> "$DISCOVERY_FILE"
done

if [[ -s "$DISCOVERY_FILE" ]]; then
    pass \
        "HERMES-006" \
        15 \
        "Hermes executable evidence was captured" \
        "$DISCOVERY_FILE"
else
    fail \
        "HERMES-006" \
        15 \
        "Hermes executable evidence was captured" \
        "no evidence produced"
fi

if pgrep -if 'Hermes' >/dev/null 2>&1; then
    pass \
        "HERMES-007" \
        10 \
        "Hermes application process is running" \
        "$(pgrep -ifl 'Hermes' | tr '\n' '; ')"
else
    warn \
        "HERMES-007" \
        10 \
        "Hermes application process is running" \
        "Hermes is not currently running"
fi

if [[ -f "$HERMES_SUPPORT/connection.json" ]]; then
    CONNECTION_MODE="$(
        python3 - "$HERMES_SUPPORT/connection.json" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    data = json.load(handle)

print(data.get("mode", "undefined"))
PY
    )"

    if [[ "$CONNECTION_MODE" == "local" || "$CONNECTION_MODE" == "remote" ]]; then
        pass \
            "HERMES-008" \
            10 \
            "Hermes connection mode is declared" \
            "$CONNECTION_MODE"
    else
        fail \
            "HERMES-008" \
            10 \
            "Hermes connection mode is declared" \
            "$CONNECTION_MODE"
    fi
else
    fail \
        "HERMES-008" \
        10 \
        "Hermes connection mode is declared" \
        "connection.json missing"
fi

finish_certification \
    "$RESULT_FILE" \
    "hermes-runtime" \
    80
