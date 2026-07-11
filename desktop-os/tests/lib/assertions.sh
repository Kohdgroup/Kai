#!/bin/zsh

setopt NO_NOMATCH

TESTS=0
PASSED=0
FAILED=0
CRITICAL_FAILURES=0
POINTS_EARNED=0
POINTS_AVAILABLE=0

CURRENT_TEST=""
CURRENT_OUTPUT=""

begin_test() {
  CURRENT_TEST="$1"
  CURRENT_OUTPUT="$2"
  TESTS=$((TESTS + 1))
  printf "\nTEST  %s\n" "$CURRENT_TEST"
}

pass_assertion() {
  local message="$1"
  local weight="$2"

  PASSED=$((PASSED + 1))
  POINTS_EARNED=$((POINTS_EARNED + weight))
  POINTS_AVAILABLE=$((POINTS_AVAILABLE + weight))

  printf "PASS  %s (+%s)\n" "$message" "$weight"
}

fail_assertion() {
  local message="$1"
  local weight="$2"
  local critical="${3:-false}"

  FAILED=$((FAILED + 1))
  POINTS_AVAILABLE=$((POINTS_AVAILABLE + weight))

  if [[ "$critical" == "true" ]]; then
    CRITICAL_FAILURES=$((CRITICAL_FAILURES + 1))
    printf "FAIL  %s (CRITICAL, 0/%s)\n" "$message" "$weight"
  else
    printf "FAIL  %s (0/%s)\n" "$message" "$weight"
  fi
}

assert_contains() {
  local file="$1"
  local pattern="$2"
  local label="$3"
  local weight="$4"
  local critical="${5:-false}"

  if grep -Eiq "$pattern" "$file"; then
    pass_assertion "$label" "$weight"
  else
    fail_assertion "$label" "$weight" "$critical"
  fi
}

assert_not_contains() {
  local file="$1"
  local pattern="$2"
  local label="$3"
  local weight="$4"
  local critical="${5:-false}"

  if grep -Eiq "$pattern" "$file"; then
    fail_assertion "$label" "$weight" "$critical"
  else
    pass_assertion "$label" "$weight"
  fi
}

assert_command_success() {
  local exit_code="$1"
  local label="$2"
  local weight="$3"
  local critical="${4:-false}"

  if [[ "$exit_code" -eq 0 ]]; then
    pass_assertion "$label" "$weight"
  else
    fail_assertion "$label" "$weight" "$critical"
  fi
}

assert_file_exists() {
  local file="$1"
  local label="$2"
  local weight="$3"
  local critical="${4:-false}"

  if [[ -s "$file" ]]; then
    pass_assertion "$label" "$weight"
  else
    fail_assertion "$label" "$weight" "$critical"
  fi
}

finish_suite() {
  local suite_name="$1"
  local minimum_score="$2"
  local report_file="$3"

  local score=0

  if [[ "$POINTS_AVAILABLE" -gt 0 ]]; then
    score=$((POINTS_EARNED * 100 / POINTS_AVAILABLE))
  fi

  {
    echo "Suite: $suite_name"
    echo "Tests: $TESTS"
    echo "Assertions passed: $PASSED"
    echo "Assertions failed: $FAILED"
    echo "Critical failures: $CRITICAL_FAILURES"
    echo "Points: $POINTS_EARNED/$POINTS_AVAILABLE"
    echo "Score: $score"
    echo "Minimum score: $minimum_score"
  } > "$report_file"

  printf "\n------------------------------\n"
  printf "%s\n" "$suite_name"
  printf "Score: %s%%\n" "$score"
  printf "Critical failures: %s\n" "$CRITICAL_FAILURES"
  printf "------------------------------\n"

  if [[ "$CRITICAL_FAILURES" -gt 0 || "$score" -lt "$minimum_score" ]]; then
    echo "RESULT: FAIL"
    return 1
  fi

  echo "RESULT: PASS"
  return 0
}
