#!/usr/bin/env bash
set -euo pipefail
python3 "$(dirname "$0")/sync_docs.py" --source /app/data/hermes --repo "$(git rev-parse --show-toplevel)" --commit --push
