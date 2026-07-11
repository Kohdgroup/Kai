#!/usr/bin/env bash
set -uo pipefail

TEST_TOTAL=0
TEST_PASSED=0
TEST_FAILED=0
TEST_WARNED=0
TEST_SKIPPED=0
TEST_SCORE_EARNED=0
TEST_SCORE_AVAILABLE=0
TEST_SUITE_NAME="${TEST_SUITE_NAME:-KOHD certification}"
TEST_RESULT_DIR="${TEST_RESULT_DIR:-desktop-os/03-testing/results}"
TEST_RUN_ID="${TEST_RUN_ID:-$(date -u +%Y%m%dT%H%M%SZ)-$$}"
TEST_STARTED_AT="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
declare -a TEST_RECORDS=()

json_escape() {
  local value="${1:-}"
  value=${value//\\/\\\\}; value=${value//\"/\\\"}; value=${value//$'\n'/\\n}; value=${value//$'\r'/\\r}; value=${value//$'\t'/\\t}
  printf '%s' "$value"
}

record_test() {
  local id="$1" status="$2" weight="$3" description="$4" evidence="${5:-}"
  TEST_TOTAL=$((TEST_TOTAL+1)); TEST_SCORE_AVAILABLE=$((TEST_SCORE_AVAILABLE+weight))
  case "$status" in
    PASS) TEST_PASSED=$((TEST_PASSED+1)); TEST_SCORE_EARNED=$((TEST_SCORE_EARNED+weight));;
    FAIL) TEST_FAILED=$((TEST_FAILED+1));;
    WARN) TEST_WARNED=$((TEST_WARNED+1));;
    SKIP) TEST_SKIPPED=$((TEST_SKIPPED+1));;
    *) echo "Invalid status: $status" >&2; return 2;;
  esac
  TEST_RECORDS+=("$(printf '{\"id\":\"%s\",\"status\":\"%s\",\"weight\":%d,\"description\":\"%s\",\"evidence\":\"%s\"}' \
    "$(json_escape "$id")" "$(json_escape "$status")" "$weight" "$(json_escape "$description")" "$(json_escape "$evidence")")")
  printf '%-5s %-30s %s' "$status" "$id" "$description"; [[ -n "$evidence" ]] && printf ' [%s]' "$evidence"; printf '\n'
}
pass(){ record_test "$1" PASS "$2" "$3" "${4:-}"; }
fail(){ record_test "$1" FAIL "$2" "$3" "${4:-}"; }
warn(){ record_test "$1" WARN "$2" "$3" "${4:-}"; }
skip(){ record_test "$1" SKIP "$2" "$3" "${4:-}"; }

assert_command_exists(){ command -v "$2" >/dev/null 2>&1 && pass "$1" "${3:-1}" "Command available: $2" "$(command -v "$2")" || fail "$1" "${3:-1}" "Command available: $2" "not found"; }
assert_file_exists(){ [[ -f "$2" ]] && pass "$1" "${3:-1}" "File exists: $2" "$2" || fail "$1" "${3:-1}" "File exists: $2" "missing"; }
assert_directory_exists(){ [[ -d "$2" ]] && pass "$1" "${3:-1}" "Directory exists: $2" "$2" || fail "$1" "${3:-1}" "Directory exists: $2" "missing"; }
assert_executable(){ [[ -x "$2" ]] && pass "$1" "${3:-1}" "Executable: $2" "$2" || fail "$1" "${3:-1}" "Executable: $2" "not executable or missing"; }
assert_contains(){ local id="$1" file="$2" pattern="$3" weight="${4:-1}"; [[ -f "$file" ]] || { fail "$id" "$weight" "Contains pattern: $pattern" "missing: $file"; return; }; grep -Eq -- "$pattern" "$file" && pass "$id" "$weight" "Contains pattern: $pattern" "$file" || fail "$id" "$weight" "Contains pattern: $pattern" "$file"; }
assert_not_contains(){ local id="$1" file="$2" pattern="$3" weight="${4:-1}"; [[ -f "$file" ]] || { fail "$id" "$weight" "Excludes pattern: $pattern" "missing: $file"; return; }; grep -Eq -- "$pattern" "$file" && fail "$id" "$weight" "Excludes pattern: $pattern" "$file" || pass "$id" "$weight" "Excludes pattern: $pattern" "$file"; }
assert_command_succeeds(){ local id="$1" description="$2" weight="$3"; shift 3; local output rc; set +e; output="$("$@" 2>&1)"; rc=$?; set -e; [[ $rc -eq 0 ]] && pass "$id" "$weight" "$description" "${output:-exit 0}" || fail "$id" "$weight" "$description" "exit=$rc ${output:-}"; }

calculate_score(){ [[ $TEST_SCORE_AVAILABLE -eq 0 ]] && printf 0 || printf '%d' "$((TEST_SCORE_EARNED*100/TEST_SCORE_AVAILABLE))"; }
write_json_result(){
  mkdir -p "$(dirname "$1")"; local target="$1" subject="${2:-unknown}" threshold="${3:-100}" score outcome completed sep=""
  score="$(calculate_score)"; completed="$(date -u +%Y-%m-%dT%H:%M:%SZ)"; [[ $TEST_FAILED -eq 0 && $score -ge $threshold ]] && outcome=PASSED || outcome=FAILED
  {
    printf '{\n  "schema_version":"1.0",\n  "run_id":"%s",\n  "suite":"%s",\n  "subject":"%s",\n' "$(json_escape "$TEST_RUN_ID")" "$(json_escape "$TEST_SUITE_NAME")" "$(json_escape "$subject")"
    printf '  "started_at":"%s",\n  "completed_at":"%s",\n  "outcome":"%s",\n  "score_percent":%d,\n  "certification_threshold":%d,\n' "$TEST_STARTED_AT" "$completed" "$outcome" "$score" "$threshold"
    printf '  "summary":{"total":%d,"passed":%d,"failed":%d,"warnings":%d,"skipped":%d,"points_earned":%d,"points_available":%d},\n  "tests":[\n' "$TEST_TOTAL" "$TEST_PASSED" "$TEST_FAILED" "$TEST_WARNED" "$TEST_SKIPPED" "$TEST_SCORE_EARNED" "$TEST_SCORE_AVAILABLE"
    local r; for r in "${TEST_RECORDS[@]}"; do printf '%s    %s' "$sep" "$r"; sep=$',\n'; done
    printf '\n  ]\n}\n'
  } > "$target"
  printf '\nResult: %s\nScore: %s%%\nReport: %s\n' "$outcome" "$score" "$target"
}
finish_certification(){ write_json_result "$1" "$2" "${3:-100}"; local score; score="$(calculate_score)"; [[ $TEST_FAILED -eq 0 && $score -ge ${3:-100} ]]; }

assert_value_equals() {
    local test_id="$1"
    local actual="$2"
    local expected="$3"
    local description="$4"
    local weight="${5:-1}"

    if [[ "$actual" == "$expected" ]]; then
        pass \
            "$test_id" \
            "$weight" \
            "$description" \
            "expected=$expected actual=$actual"
    else
        fail \
            "$test_id" \
            "$weight" \
            "$description" \
            "expected=$expected actual=$actual"
    fi
}
