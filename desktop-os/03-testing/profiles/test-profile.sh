#!/usr/bin/env bash

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=../lib/test-common.sh
source "$TEST_ROOT/lib/test-common.sh"

TEST_SUITE_NAME="KOHD Desktop OS profile certification"

PROFILE_DIR="${1:-}"
CERTIFICATION_THRESHOLD="${CERTIFICATION_THRESHOLD:-100}"

if [[ -z "$PROFILE_DIR" ]]; then
    echo "Usage: $0 <profile-directory>" >&2
    exit 2
fi

PROFILE_DIR="$(cd "$PROFILE_DIR" 2>/dev/null && pwd)" || {
    echo "Profile directory not found: $PROFILE_DIR" >&2
    exit 2
}

PROFILE_ID="$(basename "$PROFILE_DIR")"
RESULT_FILE="$TEST_RESULT_DIR/profile-${PROFILE_ID}-${TEST_RUN_ID}.json"

echo
echo "### Profile: $PROFILE_ID"

assert_directory_exists \
    "PROFILE-001" \
    "$PROFILE_DIR" \
    5

assert_file_exists \
    "PROFILE-002" \
    "$PROFILE_DIR/PROFILE.md" \
    15

assert_file_exists \
    "PROFILE-003" \
    "$PROFILE_DIR/SOUL.md" \
    15

assert_file_exists \
    "PROFILE-004" \
    "$PROFILE_DIR/tools.txt" \
    15

assert_file_exists \
    "PROFILE-005" \
    "$PROFILE_DIR/fallbacks.txt" \
    15

assert_file_exists \
    "PROFILE-006" \
    "$PROFILE_DIR/runtime-summary.txt" \
    15

if [[ -s "$PROFILE_DIR/PROFILE.md" ]]; then
    pass \
        "PROFILE-007" \
        5 \
        "PROFILE.md is not empty" \
        "$PROFILE_DIR/PROFILE.md"
else
    fail \
        "PROFILE-007" \
        5 \
        "PROFILE.md is not empty" \
        "missing or empty"
fi

if [[ -s "$PROFILE_DIR/SOUL.md" ]]; then
    pass \
        "PROFILE-008" \
        5 \
        "SOUL.md is not empty" \
        "$PROFILE_DIR/SOUL.md"
else
    fail \
        "PROFILE-008" \
        5 \
        "SOUL.md is not empty" \
        "missing or empty"
fi

if [[ -s "$PROFILE_DIR/tools.txt" ]]; then
    pass \
        "PROFILE-009" \
        3 \
        "tools.txt declares at least one tool or capability" \
        "$(wc -l < "$PROFILE_DIR/tools.txt" | tr -d ' ') lines"
else
    fail \
        "PROFILE-009" \
        3 \
        "tools.txt declares at least one tool or capability" \
        "missing or empty"
fi

if [[ -s "$PROFILE_DIR/fallbacks.txt" ]]; then
    pass \
        "PROFILE-010" \
        3 \
        "fallbacks.txt declares fallback behaviour" \
        "$(wc -l < "$PROFILE_DIR/fallbacks.txt" | tr -d ' ') lines"
else
    fail \
        "PROFILE-010" \
        3 \
        "fallbacks.txt declares fallback behaviour" \
        "missing or empty"
fi

if [[ -s "$PROFILE_DIR/runtime-summary.txt" ]]; then
    pass \
        "PROFILE-011" \
        3 \
        "runtime-summary.txt declares runtime configuration" \
        "$(wc -l < "$PROFILE_DIR/runtime-summary.txt" | tr -d ' ') lines"
else
    fail \
        "PROFILE-011" \
        3 \
        "runtime-summary.txt declares runtime configuration" \
        "missing or empty"
fi

if find "$PROFILE_DIR" -maxdepth 1 -type f \
    \( -name '*.yaml' -o -name '*.yml' -o -name 'config.yaml' \) \
    | grep -q .; then
    warn \
        "PROFILE-012" \
        1 \
        "Profile contains legacy runtime configuration" \
        "repository profiles should use governed package files"
else
    pass \
        "PROFILE-012" \
        1 \
        "Profile contains no legacy config.yaml dependency" \
        "$PROFILE_DIR"
fi

if grep -RIl \
    --exclude='runtime-summary.txt' \
    --exclude='fallbacks.txt' \
    -E '\$\{HERMES_MODEL_DEFAULT\}' \
    "$PROFILE_DIR" >/dev/null 2>&1; then
    fail \
        "PROFILE-013" \
        5 \
        "Profile does not inherit HERMES_MODEL_DEFAULT" \
        "prohibited variable found"
else
    pass \
        "PROFILE-013" \
        5 \
        "Profile does not inherit HERMES_MODEL_DEFAULT" \
        "no prohibited inheritance"
fi

finish_certification \
    "$RESULT_FILE" \
    "$PROFILE_ID" \
    "$CERTIFICATION_THRESHOLD"
