#!/bin/zsh
set -euo pipefail

ROOT="$HOME/kohd/desktop-os/02-profiles"

sync_profile() {
  local runtime_name="$1"
  local canonical_name="$2"
  local source="$HOME/.hermes/profiles/$runtime_name"
  local target="$ROOT/$canonical_name"

  mkdir -p "$target"

  cp "$source/PROFILE.md" "$target/PROFILE.md"
  cp "$source/SOUL.md" "$target/SOUL.md"

  hermes profile show "$runtime_name" > "$target/runtime-summary.txt"
  hermes -p "$runtime_name" tools list > "$target/tools.txt"
  hermes -p "$runtime_name" fallback list > "$target/fallbacks.txt"

  echo "Synced $runtime_name → $canonical_name"
}

sync_profile "natalie-brooks" "natalie-brooks"
sync_profile "sarah-collins" "sarah-collins"
sync_profile "emma-carter" "emma-carter"
sync_profile "mai-architect" "mai-matsuda"
sync_profile "neil-digital-twin" "neil-digital-twin"

echo "Desktop OS profile records refreshed."
