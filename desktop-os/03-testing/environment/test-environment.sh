#!/usr/bin/env bash
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
source "$ROOT/desktop-os/03-testing/lib/test-common.sh"
TEST_SUITE_NAME="KOHD environment certification"
RESULT="$ROOT/desktop-os/03-testing/results/environment-$(hostname)-${TEST_RUN_ID}.json"

assert_command_exists ENV-001 bash 5
assert_command_exists ENV-002 git 8
assert_command_exists ENV-003 python3 8
assert_directory_exists ENV-004 "$ROOT/.git" 10
assert_command_succeeds ENV-005 "Git working tree can be inspected" 8 git -C "$ROOT" status --short
assert_command_succeeds ENV-006 "Repository HEAD resolves" 8 git -C "$ROOT" rev-parse HEAD

if command -v jq >/dev/null 2>&1; then pass ENV-007 4 "jq available" "$(command -v jq)"; else warn ENV-007 0 "jq unavailable" "optional"; fi
if command -v docker >/dev/null 2>&1; then
    if docker info >/dev/null 2>&1; then
        pass \
            "ENV-008" \
            1 \
            "Docker daemon available" \
            "$(docker version --format '{{.Client.Version}}' 2>/dev/null || true)"
    else
        warn \
            "ENV-008" \
            1 \
            "Docker client installed; daemon not running" \
            "Docker is optional for the Desktop OS laptop baseline"
    fi
else
    skip \
        "ENV-008" \
        1 \
        "Docker is not installed" \
        "Docker is optional for the Desktop OS laptop baseline"
fi

[[ -w "$ROOT/desktop-os/03-testing/results" || ! -e "$ROOT/desktop-os/03-testing/results" ]] && pass ENV-009 8 "Results directory writable" "$ROOT/desktop-os/03-testing/results" || fail ENV-009 8 "Results directory writable" "$ROOT/desktop-os/03-testing/results"

OS="$(uname -s)"; ARCH="$(uname -m)"
case "$OS" in Darwin|Linux) pass ENV-010 8 "Supported operating system" "$OS/$ARCH";; *) fail ENV-010 8 "Supported operating system" "$OS/$ARCH";; esac

FREE_KB="$(df -Pk "$ROOT" | awk 'NR==2 {print $4}')"
if [[ "${FREE_KB:-0}" -ge 1048576 ]]; then pass ENV-011 5 "At least 1 GiB free disk" "${FREE_KB} KiB"; else fail ENV-011 5 "At least 1 GiB free disk" "${FREE_KB:-unknown} KiB"; fi

finish_certification "$RESULT" "$(hostname)" "${ENVIRONMENT_THRESHOLD:-85}"
