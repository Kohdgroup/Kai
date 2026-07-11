#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
from pathlib import Path


EXPECTED_CONTENT = "KOHD_HERMES_FILE_WRITE_OK"


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Canonicalise a controlled Hermes file-write result."
    )
    parser.add_argument("--target-file", required=True, type=Path)
    parser.add_argument("--status-diff", required=True, type=Path)
    parser.add_argument("--tracked-before", required=True, type=Path)
    parser.add_argument("--tracked-after", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()

    checks = {
        "target_exists": args.target_file.is_file(),
        "exact_content": False,
        "no_external_git_changes": (
            args.status_diff.is_file()
            and args.status_diff.stat().st_size == 0
        ),
        "tracked_inventory_unchanged": False,
    }

    if checks["target_exists"]:
        checks["exact_content"] = (
            args.target_file.read_text(encoding="utf-8").strip()
            == EXPECTED_CONTENT
        )

    if args.tracked_before.is_file() and args.tracked_after.is_file():
        checks["tracked_inventory_unchanged"] = (
            args.tracked_before.read_bytes()
            == args.tracked_after.read_bytes()
        )

    passed = all(checks.values())

    payload = {
        "schema_version": "1.0",
        "operation": "controlled-file-write",
        "outcome": "PASSED" if passed else "FAILED",
        "canonical_completion": (
            "KOHD_HERMES_FILE_WRITE_COMPLETE" if passed else None
        ),
        "checks": checks,
        "native_response_certified": False,
        "known_limitation": "HERMES-TOOL-001",
    }

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(
        json.dumps(payload, indent=2) + "\n",
        encoding="utf-8",
    )

    print(json.dumps(payload, indent=2))
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
