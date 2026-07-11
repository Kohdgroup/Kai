#!/usr/bin/env python3

from __future__ import annotations

import json
import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


SCRIPT_DIR = Path(__file__).resolve().parent
TEST_ROOT = SCRIPT_DIR.parent
REPO_ROOT = TEST_ROOT.parent.parent
RESULT_DIR = TEST_ROOT / "results"

HERMES_BIN = Path(
    os.environ.get(
        "HERMES_BIN",
        str(Path.home() / ".local/bin/hermes"),
    )
)


def run_id() -> str:
    return os.environ.get(
        "TEST_RUN_ID",
        datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ"),
    )


def run_git(*arguments: str) -> str:
    completed = subprocess.run(
        ["git", "-C", str(REPO_ROOT), *arguments],
        text=True,
        capture_output=True,
        check=True,
    )
    return completed.stdout.strip()


def run_hermes_command(
    test_name: str,
    shell_command: str,
    timeout: int = 60,
) -> dict[str, Any]:
    prompt = (
        "Use the terminal tool exactly once.\n\n"
        f"Run this exact read-only command:\n\n{shell_command}\n\n"
        "Return only the exact command output.\n"
        "Do not modify files or Git state.\n"
        "Do not run any other command."
    )

    command = [
        str(HERMES_BIN),
        "chat",
        "--query",
        prompt,
        "--quiet",
        "--source",
        "tool",
        "--cli",
        "--max-turns",
        "2",
        "--toolsets",
        "terminal",
        "--yolo",
    ]

    try:
        completed = subprocess.run(
            command,
            cwd=REPO_ROOT,
            text=True,
            capture_output=True,
            timeout=timeout,
            check=False,
        )

        return {
            "name": test_name,
            "exit_code": completed.returncode,
            "stdout": completed.stdout.strip(),
            "stderr": completed.stderr.strip(),
            "timed_out": False,
        }

    except subprocess.TimeoutExpired as error:
        stdout = error.stdout or ""
        stderr = error.stderr or ""

        if isinstance(stdout, bytes):
            stdout = stdout.decode("utf-8", errors="replace")

        if isinstance(stderr, bytes):
            stderr = stderr.decode("utf-8", errors="replace")

        return {
            "name": test_name,
            "exit_code": 124,
            "stdout": stdout.strip(),
            "stderr": stderr.strip(),
            "timed_out": True,
        }


def main() -> int:
    RESULT_DIR.mkdir(parents=True, exist_ok=True)
    current_run_id = run_id()

    before_status = run_git("status", "--porcelain=v1")
    before_head = run_git("rev-parse", "HEAD")
    before_branch = run_git("branch", "--show-current")
    before_index = run_git("ls-files", "-s")

    expected = {
        "branch": before_branch,
        "head": before_head,
        "working_tree_clean": "true" if before_status == "" else "false",
        "desktop_os_readme_exists": "true",
        "certification_runner_exists": "true",
    }

    commands = {
        "branch": (
            f'git -C "{REPO_ROOT}" branch --show-current'
        ),
        "head": (
            f'git -C "{REPO_ROOT}" rev-parse HEAD'
        ),
        "working_tree_clean": (
            f'test -z "$(git -C \\"{REPO_ROOT}\\" '
            'status --porcelain=v1)" && printf true || printf false'
        ),
        "desktop_os_readme_exists": (
            f'test -f "{REPO_ROOT}/desktop-os/README.md" '
            "&& printf true || printf false"
        ),
        "certification_runner_exists": (
            f'test -f "{REPO_ROOT}/desktop-os/03-testing/'
            'run-certification.sh" && printf true || printf false'
        ),
    }

    executions = {
        name: run_hermes_command(name, command)
        for name, command in commands.items()
    }

    after_status = run_git("status", "--porcelain=v1")
    after_head = run_git("rev-parse", "HEAD")
    after_branch = run_git("branch", "--show-current")
    after_index = run_git("ls-files", "-s")

    checks: list[dict[str, Any]] = []

    def check(
        check_id: str,
        passed: bool,
        description: str,
        evidence: Any,
    ) -> None:
        checks.append(
            {
                "id": check_id,
                "status": "PASS" if passed else "FAIL",
                "description": description,
                "evidence": evidence,
            }
        )

    for name, execution in executions.items():
        check(
            f"REPO-{name.upper()}-EXEC",
            execution["exit_code"] == 0
            and not execution["timed_out"],
            f"Hermes completed isolated inspection for {name}",
            execution,
        )

        check(
            f"REPO-{name.upper()}-VALUE",
            execution["stdout"] == expected[name],
            f"Hermes reported the correct value for {name}",
            {
                "expected": expected[name],
                "actual": execution["stdout"],
            },
        )

    check(
        "REPO-SAFETY-STATUS",
        after_status == before_status,
        "Working-tree status was unchanged",
        {
            "before": before_status,
            "after": after_status,
        },
    )

    check(
        "REPO-SAFETY-HEAD",
        after_head == before_head,
        "HEAD was unchanged",
        {
            "before": before_head,
            "after": after_head,
        },
    )

    check(
        "REPO-SAFETY-BRANCH",
        after_branch == before_branch,
        "Current branch was unchanged",
        {
            "before": before_branch,
            "after": after_branch,
        },
    )

    check(
        "REPO-SAFETY-INDEX",
        after_index == before_index,
        "Git index was unchanged",
        "unchanged" if after_index == before_index else "changed",
    )

    failed = sum(
        1 for item in checks if item["status"] == "FAIL"
    )
    passed = len(checks) - failed
    outcome = "PASSED" if failed == 0 else "FAILED"

    result_file = (
        RESULT_DIR
        / f"tool-repository-inspection-{current_run_id}.json"
    )

    payload = {
        "schema_version": "1.0",
        "test_id": "HERMES-TOOL-REPO-INSPECTION-002",
        "run_id": current_run_id,
        "outcome": outcome,
        "operating_pattern": "one-simple-command-per-hermes-invocation",
        "known_native_limitation": "HERMES-TOOL-003",
        "expected": expected,
        "executions": executions,
        "summary": {
            "total": len(checks),
            "passed": passed,
            "failed": failed,
        },
        "checks": checks,
    }

    result_file.write_text(
        json.dumps(payload, indent=2) + "\n",
        encoding="utf-8",
    )

    print()
    print("### Hermes isolated repository inspection")

    for item in checks:
        print(
            f"{item['status']:<5} "
            f"{item['id']:<36} "
            f"{item['description']} "
            f"[{item['evidence']}]"
        )

    print()
    print(f"Result: {outcome}")
    print(f"Passed: {passed}")
    print(f"Failed: {failed}")
    print(f"Report: {result_file}")

    return 0 if failed == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
