#!/usr/bin/env bash
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
source "$ROOT/desktop-os/03-testing/lib/test-common.sh"
TEST_SUITE_NAME="KOHD platform certification"
RESULT="$ROOT/desktop-os/03-testing/results/platform-${TEST_RUN_ID}.json"

assert_directory_exists PLATFORM-001 "$ROOT/desktop-os" 8
assert_directory_exists PLATFORM-002 "$ROOT/desktop-os/01-governance" 8
assert_file_exists PLATFORM-003 "$ROOT/desktop-os/01-governance/profile-certification.md" 10
assert_file_exists PLATFORM-004 "$ROOT/desktop-os/01-governance/profile-matrix.md" 10
assert_directory_exists PLATFORM-005 "$ROOT/desktop-os/03-testing" 8
assert_executable PLATFORM-006 "$ROOT/desktop-os/03-testing/profiles/test-profile.sh" 8
assert_executable PLATFORM-007 "$ROOT/desktop-os/03-testing/profiles/test-all-profiles.sh" 8
assert_executable PLATFORM-008 "$ROOT/desktop-os/03-testing/environment/test-environment.sh" 8
assert_executable PLATFORM-009 "$ROOT/desktop-os/03-testing/run-certification.sh" 8

assert_command_succeeds PLATFORM-010 "All shell scripts pass syntax validation" 12 bash -c 'find "$1/desktop-os/03-testing" -type f -name "*.sh" -print0 | xargs -0 -n1 bash -n' _ "$ROOT"

if git -C "$ROOT" diff --quiet -- desktop-os/01-governance desktop-os/03-testing; then
  pass PLATFORM-011 5 "Governance and tests have no unstaged changes" "clean"
else
  warn PLATFORM-011 0 "Governance or tests contain unstaged changes" "commit before formal certification"
fi

finish_certification "$RESULT" "desktop-os" "${PLATFORM_THRESHOLD:-90}"
