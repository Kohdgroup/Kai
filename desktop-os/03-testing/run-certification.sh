#!/usr/bin/env bash

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

TEST_RUN_ID="${TEST_RUN_ID:-$(date -u +%Y%m%dT%H%M%SZ)}"
TEST_RESULT_DIR="${TEST_RESULT_DIR:-$SCRIPT_DIR/results}"

PROFILE_ROOT="${1:-$REPO_ROOT/desktop-os/02-profiles}"

mkdir -p "$TEST_RESULT_DIR"

ENVIRONMENT_STATUS="SKIPPED"
PLATFORM_STATUS="SKIPPED"
RUNTIME_STATUS="SKIPPED"
PROFILES_STATUS="SKIPPED"

OVERALL_FAILED=0

echo
echo "KOHD Desktop OS certification"
echo "Repository:   $REPO_ROOT"
echo "Profile root: $PROFILE_ROOT"
echo "Run ID:       $TEST_RUN_ID"

echo
echo "### Environment"

if TEST_RUN_ID="$TEST_RUN_ID" \
   TEST_RESULT_DIR="$TEST_RESULT_DIR" \
   "$SCRIPT_DIR/environment/test-environment.sh" "$REPO_ROOT"; then
    ENVIRONMENT_STATUS="PASSED"
else
    ENVIRONMENT_STATUS="FAILED"
    OVERALL_FAILED=1
fi

echo "Environment: $ENVIRONMENT_STATUS"

echo
echo "### Platform"

if TEST_RUN_ID="$TEST_RUN_ID" \
   TEST_RESULT_DIR="$TEST_RESULT_DIR" \
   "$SCRIPT_DIR/platform/test-platform.sh" "$REPO_ROOT"; then
    PLATFORM_STATUS="PASSED"
else
    PLATFORM_STATUS="FAILED"
    OVERALL_FAILED=1
fi

echo "Platform: $PLATFORM_STATUS"

echo
echo "### Runtime"

if TEST_RUN_ID="$TEST_RUN_ID" \
   TEST_RESULT_DIR="$TEST_RESULT_DIR" \
   "$SCRIPT_DIR/runtime/test-hermes-smoke.sh"; then
    RUNTIME_STATUS="PASSED"
else
    RUNTIME_STATUS="FAILED"
    OVERALL_FAILED=1
fi

echo "Runtime: $RUNTIME_STATUS"

echo
echo "### Profiles"

if [[ ! -d "$PROFILE_ROOT" ]]; then
    PROFILES_STATUS="FAILED"
    OVERALL_FAILED=1
    echo "Profiles: FAILED — directory not found: $PROFILE_ROOT"
else
    if TEST_RUN_ID="$TEST_RUN_ID" \
       TEST_RESULT_DIR="$TEST_RESULT_DIR" \
       "$SCRIPT_DIR/profiles/test-all-profiles.sh" "$PROFILE_ROOT"; then
        PROFILES_STATUS="PASSED"
    else
        PROFILES_STATUS="FAILED"
        OVERALL_FAILED=1
    fi

    echo "Profiles: $PROFILES_STATUS"
fi

SUMMARY_FILE="$TEST_RESULT_DIR/certification-summary-${TEST_RUN_ID}.json"

cat > "$SUMMARY_FILE" <<JSON
{
  "schema_version": "1.0",
  "suite": "KOHD Desktop OS certification",
  "run_id": "$TEST_RUN_ID",
  "repository_root": "$REPO_ROOT",
  "profile_root": "$PROFILE_ROOT",
  "environment": "$ENVIRONMENT_STATUS",
  "platform": "$PLATFORM_STATUS",
  "runtime": "$RUNTIME_STATUS",
  "profiles": "$PROFILES_STATUS",
  "outcome": "$([[ "$OVERALL_FAILED" -eq 0 ]] && echo PASSED || echo FAILED)"
}
JSON

echo
echo "Certification summary"
echo "Environment: $ENVIRONMENT_STATUS"
echo "Platform:    $PLATFORM_STATUS"
echo "Runtime:     $RUNTIME_STATUS"
echo "Profiles:    $PROFILES_STATUS"
echo "Outcome:     $([[ "$OVERALL_FAILED" -eq 0 ]] && echo PASSED || echo FAILED)"
echo "Summary:     $SUMMARY_FILE"

exit "$OVERALL_FAILED"
