#!/bin/zsh

set -u

PASS=0
FAIL=0
WARN=0

pass() {
  printf "PASS  %s\n" "$1"
  PASS=$((PASS + 1))
}

fail() {
  printf "FAIL  %s\n" "$1"
  FAIL=$((FAIL + 1))
}

warn() {
  printf "WARN  %s\n" "$1"
  WARN=$((WARN + 1))
}

section() {
  printf "\n== %s ==\n" "$1"
}

profile_exists() {
  local profile="$1"

  if hermes profile show "$profile" >/dev/null 2>&1; then
    pass "Profile exists: $profile"
  else
    fail "Profile missing: $profile"
  fi
}

check_model() {
  local profile="$1"
  local expected_model="$2"
  local expected_provider="$3"
  local config="$HOME/.hermes/profiles/$profile/config.yaml"

  if [[ ! -f "$config" ]]; then
    fail "Config missing: $profile"
    return
  fi

  if grep -q "default: $expected_model" "$config"; then
    pass "$profile primary model: $expected_model"
  else
    fail "$profile primary model is not $expected_model"
  fi

  if grep -q "provider: $expected_provider" "$config"; then
    pass "$profile provider: $expected_provider"
  else
    fail "$profile provider is not $expected_provider"
  fi
}

check_fallback() {
  local profile="$1"
  local expected="$2"
  local output

  output="$(hermes -p "$profile" fallback list 2>&1)"

  if echo "$output" | grep -q "$expected"; then
    pass "$profile fallback contains $expected"
  else
    fail "$profile fallback missing $expected"
  fi
}

check_profile_files() {
  local profile="$1"
  local root="$HOME/.hermes/profiles/$profile"

  [[ -s "$root/SOUL.md" ]] \
    && pass "$profile SOUL.md present" \
    || fail "$profile SOUL.md missing or empty"

  [[ -s "$root/PROFILE.md" ]] \
    && pass "$profile PROFILE.md present" \
    || fail "$profile PROFILE.md missing or empty"
}

section "Hermes"

if command -v hermes >/dev/null 2>&1; then
  pass "Hermes CLI available"
else
  fail "Hermes CLI unavailable"
fi

section "Required Profiles"

profile_exists "natalie-brooks"
profile_exists "sarah-collins"
profile_exists "emma-carter"
profile_exists "mai-architect"
profile_exists "neil-digital-twin"
profile_exists "local-qwen"

section "Primary Models"

check_model "natalie-brooks" "qwen3:4b" "custom"
check_model "sarah-collins" "qwen3:4b" "custom"
check_model "emma-carter" "claude-haiku-4-5-20251001" "anthropic"
check_model "mai-architect" "claude-haiku-4-5-20251001" "anthropic"
check_model "neil-digital-twin" "gpt-5.4-mini" "openai-api"

section "Fallback Models"

check_fallback "natalie-brooks" "gpt-5.4-mini"
check_fallback "sarah-collins" "gpt-5.4-mini"
check_fallback "emma-carter" "gpt-5.4-mini"
check_fallback "mai-architect" "gpt-5.4-mini"
check_fallback "neil-digital-twin" "claude-haiku-4-5-20251001"

section "Profile Definition Files"

check_profile_files "natalie-brooks"
check_profile_files "sarah-collins"
check_profile_files "emma-carter"
check_profile_files "mai-architect"
check_profile_files "neil-digital-twin"

section "Ollama"

if command -v ollama >/dev/null 2>&1; then
  pass "Ollama CLI available"

  if ollama list 2>/dev/null | grep -q "qwen3:4b"; then
    pass "Local model available: qwen3:4b"
  else
    fail "Local model missing: qwen3:4b"
  fi
else
  fail "Ollama CLI unavailable"
fi

section "Agent Reach"

if command -v agent-reach >/dev/null 2>&1; then
  pass "Agent Reach available"
else
  fail "Agent Reach unavailable"
fi

section "Desktop OS Repository"

if [[ -d "$HOME/kohd/.git" ]]; then
  pass "KOHD Git repository exists"

  if [[ -z "$(git -C "$HOME/kohd" status --porcelain)" ]]; then
    pass "KOHD Git working tree clean"
  else
    warn "KOHD Git working tree has uncommitted changes"
  fi
else
  fail "KOHD Git repository missing"
fi

section "Canonical Desktop OS Files"

required_files=(
  "$HOME/kohd/desktop-os/README.md"
  "$HOME/kohd/desktop-os/ARCHITECTURE.md"
  "$HOME/kohd/desktop-os/01-governance/model-policy.md"
  "$HOME/kohd/desktop-os/01-governance/tool-policy.md"
  "$HOME/kohd/desktop-os/01-governance/routing-policy.md"
  "$HOME/kohd/desktop-os/01-governance/profile-standard.md"
  "$HOME/kohd/desktop-os/01-governance/information-acquisition-policy.md"
  "$HOME/kohd/desktop-os/01-governance/profile-certification.md"
  "$HOME/kohd/desktop-os/01-governance/profile-matrix.md"
  "$HOME/kohd/desktop-os/04-routing/laptop-routing.md"
)

for file in "${required_files[@]}"; do
  if [[ -f "$file" ]]; then
    pass "Canonical file present: ${file#$HOME/kohd/}"
  else
    fail "Canonical file missing: ${file#$HOME/kohd/}"
  fi
done

printf "\n==============================\n"
printf "Desktop OS Health Summary\n"
printf "PASS: %s\n" "$PASS"
printf "WARN: %s\n" "$WARN"
printf "FAIL: %s\n" "$FAIL"
printf "==============================\n"

if [[ "$FAIL" -eq 0 ]]; then
  printf "DESKTOP OS: HEALTHY\n"
  exit 0
else
  printf "DESKTOP OS: ATTENTION REQUIRED\n"
  exit 1
fi
