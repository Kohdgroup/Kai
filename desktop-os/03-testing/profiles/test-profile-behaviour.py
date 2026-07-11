#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


def utc_run_id() -> str:
    return datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")


def load_json(path: Path) -> dict[str, Any]:
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def extract_json(text: str) -> dict[str, Any]:
    stripped = text.strip()

    try:
        return json.loads(stripped)
    except json.JSONDecodeError:
        start = stripped.find("{")
        end = stripped.rfind("}")

        if start == -1 or end == -1 or end <= start:
            raise

        return json.loads(stripped[start : end + 1])


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("fixture", type=Path)
    parser.add_argument(
        "--hermes",
        default=os.environ.get(
            "HERMES_BIN",
            str(Path.home() / ".local/bin/hermes"),
        ),
    )
    parser.add_argument(
        "--results-dir",
        type=Path,
        default=Path("desktop-os/03-testing/results"),
    )
    parser.add_argument("--timeout", type=int, default=180)
    args = parser.parse_args()

    fixture = load_json(args.fixture)
    test_id = fixture["test_id"]
    profile = fixture["profile"]
    prompt = fixture["prompt"]
    assertions = fixture["assertions"]

    run_id = os.environ.get("TEST_RUN_ID", utc_run_id())
    args.results_dir.mkdir(parents=True, exist_ok=True)

    response_path = (
        args.results_dir / f"{test_id}-{profile}-{run_id}.response.txt"
    )
    result_path = (
        args.results_dir / f"{test_id}-{profile}-{run_id}.json"
    )

    command = [
        args.hermes,
        "chat",
        "--query",
        prompt,
        "--quiet",
        "--source",
        "tool",
        "--max-turns",
        "1",
    ]

    completed = subprocess.run(
        command,
        text=True,
        capture_output=True,
        timeout=args.timeout,
        check=False,
    )

    response_path.write_text(completed.stdout, encoding="utf-8")

    checks: list[dict[str, Any]] = []

    def add_check(
        check_id: str,
        passed: bool,
        description: str,
        evidence: str,
    ) -> None:
        checks.append(
            {
                "id": check_id,
                "status": "PASS" if passed else "FAIL",
                "description": description,
                "evidence": evidence,
            }
        )

    add_check(
        "BEHAVIOUR-001",
        completed.returncode == 0,
        "Hermes execution returned exit code 0",
        str(completed.returncode),
    )

    try:
        payload = extract_json(completed.stdout)
        json_valid = True
        json_error = ""
    except Exception as error:
        payload = {}
        json_valid = False
        json_error = str(error)

    add_check(
        "BEHAVIOUR-002",
        json_valid,
        "Hermes returned valid JSON",
        json_error or "valid JSON",
    )

    for key in assertions.get("required_keys", []):
        add_check(
            f"KEY-{key.upper()}",
            key in payload,
            f"Required key exists: {key}",
            repr(payload.get(key)),
        )

    for key, minimum in assertions.get(
        "minimum_array_lengths",
        {},
    ).items():
        value = payload.get(key)
        passed = isinstance(value, list) and len(value) >= minimum

        add_check(
            f"LENGTH-{key.upper()}",
            passed,
            f"{key} contains at least {minimum} items",
            f"actual={len(value) if isinstance(value, list) else 'not-list'}",
        )

    for key, allowed in assertions.get("allowed_values", {}).items():
        value = payload.get(key)

        add_check(
            f"VALUE-{key.upper()}",
            value in allowed,
            f"{key} uses an allowed value",
            f"actual={value!r} allowed={allowed!r}",
        )

    failed = sum(1 for check in checks if check["status"] == "FAIL")
    passed = len(checks) - failed
    outcome = "PASSED" if failed == 0 else "FAILED"

    result = {
        "schema_version": "1.0",
        "test_id": test_id,
        "profile": profile,
        "run_id": run_id,
        "outcome": outcome,
        "summary": {
            "total": len(checks),
            "passed": passed,
            "failed": failed,
        },
        "response_file": str(response_path),
        "stderr": completed.stderr,
        "checks": checks,
    }

    result_path.write_text(
        json.dumps(result, indent=2) + "\n",
        encoding="utf-8",
    )

    print()
    print(f"### Behaviour: {profile}")

    for check in checks:
        print(
            f"{check['status']:<5} "
            f"{check['id']:<28} "
            f"{check['description']} "
            f"[{check['evidence']}]"
        )

    print()
    print(f"Result: {outcome}")
    print(f"Passed: {passed}")
    print(f"Failed: {failed}")
    print(f"Report: {result_path}")

    return 0 if failed == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
