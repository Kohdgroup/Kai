#!/usr/bin/env python3

"""Execute one non-interactive Hermes behavioural test.

The adapter:
- accepts a prompt directly or from a file;
- invokes the real Hermes CLI;
- captures stdout, stderr, duration and exit status;
- applies a hard timeout;
- writes raw response evidence and JSON metadata;
- returns a meaningful process exit code.
"""

from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


EXIT_PASS = 0
EXIT_HERMES_FAILURE = 1
EXIT_CONFIGURATION_ERROR = 2
EXIT_TIMEOUT = 124


def utc_now() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def safe_name(value: str) -> str:
    cleaned = "".join(
        character if character.isalnum() or character in "-_." else "-"
        for character in value
    )
    return cleaned.strip("-") or "hermes-test"


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Run a non-interactive Hermes behavioural test."
    )

    prompt_group = parser.add_mutually_exclusive_group(required=True)
    prompt_group.add_argument(
        "--prompt",
        help="Prompt text to submit directly.",
    )
    prompt_group.add_argument(
        "--prompt-file",
        type=Path,
        help="UTF-8 file containing the prompt.",
    )

    parser.add_argument(
        "--test-id",
        required=True,
        help="Stable test identifier used in evidence filenames.",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path("desktop-os/03-testing/results"),
        help="Directory for raw and JSON evidence.",
    )
    parser.add_argument(
        "--hermes",
        default=os.environ.get("HERMES_BIN", "hermes"),
        help="Hermes executable path or command name.",
    )
    parser.add_argument(
        "--timeout",
        type=int,
        default=300,
        help="Maximum execution time in seconds.",
    )
    parser.add_argument(
        "--max-turns",
        type=int,
        default=20,
        help="Maximum Hermes tool-calling iterations.",
    )
    parser.add_argument(
        "--model",
        help="Optional explicit Hermes model.",
    )
    parser.add_argument(
        "--provider",
        help="Optional explicit Hermes provider.",
    )
    parser.add_argument(
        "--toolsets",
        help="Optional comma-separated Hermes toolsets.",
    )
    parser.add_argument(
        "--skills",
        action="append",
        default=[],
        help="Optional skill to preload. Repeat or comma-separate.",
    )
    parser.add_argument(
        "--ignore-rules",
        action="store_true",
        help="Run without injected AGENTS.md, SOUL.md, memory or skills.",
    )
    parser.add_argument(
        "--ignore-user-config",
        action="store_true",
        help="Ignore ~/.hermes/config.yaml.",
    )
    parser.add_argument(
        "--safe-mode",
        action="store_true",
        help="Disable custom configuration, rules, plugins and MCP.",
    )
    parser.add_argument(
        "--worktree",
        action="store_true",
        help="Run Hermes in an isolated Git worktree.",
    )
    parser.add_argument(
        "--checkpoints",
        action="store_true",
        help="Enable Hermes filesystem checkpoints.",
    )
    parser.add_argument(
        "--yolo",
        action="store_true",
        help="Bypass dangerous-command approvals. Not recommended.",
    )

    return parser.parse_args()


def resolve_executable(command: str) -> str:
    candidate = Path(command).expanduser()

    if candidate.is_absolute() or "/" in command:
        if candidate.is_file() and os.access(candidate, os.X_OK):
            return str(candidate.resolve())
        raise FileNotFoundError(f"Hermes executable is unavailable: {candidate}")

    resolved = shutil.which(command)

    if not resolved:
        raise FileNotFoundError(
            f"Hermes executable was not found on PATH: {command}"
        )

    return resolved


def load_prompt(arguments: argparse.Namespace) -> str:
    if arguments.prompt is not None:
        prompt = arguments.prompt
    else:
        prompt_file = arguments.prompt_file.expanduser()

        if not prompt_file.is_file():
            raise FileNotFoundError(f"Prompt file not found: {prompt_file}")

        prompt = prompt_file.read_text(encoding="utf-8")

    if not prompt.strip():
        raise ValueError("Prompt must not be empty.")

    return prompt


def build_command(
    executable: str,
    prompt: str,
    arguments: argparse.Namespace,
) -> list[str]:
    command = [
        executable,
        "chat",
        "--query",
        prompt,
        "--quiet",
        "--source",
        "tool",
        "--max-turns",
        str(arguments.max_turns),
    ]

    if arguments.model:
        command.extend(["--model", arguments.model])

    if arguments.provider:
        command.extend(["--provider", arguments.provider])

    if arguments.toolsets:
        command.extend(["--toolsets", arguments.toolsets])

    for skill_group in arguments.skills:
        command.extend(["--skills", skill_group])

    if arguments.ignore_rules:
        command.append("--ignore-rules")

    if arguments.ignore_user_config:
        command.append("--ignore-user-config")

    if arguments.safe_mode:
        command.append("--safe-mode")

    if arguments.worktree:
        command.append("--worktree")

    if arguments.checkpoints:
        command.append("--checkpoints")

    if arguments.yolo:
        command.append("--yolo")

    return command


def write_json(path: Path, payload: dict[str, Any]) -> None:
    path.write_text(
        json.dumps(payload, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )


def main() -> int:
    arguments = parse_arguments()
    test_id = safe_name(arguments.test_id)
    run_id = os.environ.get(
        "TEST_RUN_ID",
        datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ"),
    )

    arguments.output_dir.mkdir(parents=True, exist_ok=True)

    response_path = arguments.output_dir / f"{test_id}-{run_id}.response.txt"
    stderr_path = arguments.output_dir / f"{test_id}-{run_id}.stderr.txt"
    metadata_path = arguments.output_dir / f"{test_id}-{run_id}.json"

    try:
        executable = resolve_executable(arguments.hermes)
        prompt = load_prompt(arguments)
    except (FileNotFoundError, OSError, UnicodeError, ValueError) as error:
        print(f"CONFIGURATION ERROR: {error}", file=sys.stderr)
        return EXIT_CONFIGURATION_ERROR

    command = build_command(executable, prompt, arguments)

    started_at = utc_now()
    started_clock = time.monotonic()
    timed_out = False

    try:
        completed = subprocess.run(
            command,
            cwd=Path.cwd(),
            text=True,
            capture_output=True,
            timeout=arguments.timeout,
            check=False,
            env=os.environ.copy(),
        )
        return_code = completed.returncode
        stdout = completed.stdout
        stderr = completed.stderr

    except subprocess.TimeoutExpired as error:
        timed_out = True
        return_code = EXIT_TIMEOUT

        stdout = (
            error.stdout.decode("utf-8", errors="replace")
            if isinstance(error.stdout, bytes)
            else error.stdout or ""
        )
        stderr = (
            error.stderr.decode("utf-8", errors="replace")
            if isinstance(error.stderr, bytes)
            else error.stderr or ""
        )

        stderr += (
            f"\nHermes execution exceeded the "
            f"{arguments.timeout}-second timeout.\n"
        )

    duration_seconds = round(time.monotonic() - started_clock, 3)
    completed_at = utc_now()

    response_path.write_text(stdout, encoding="utf-8")
    stderr_path.write_text(stderr, encoding="utf-8")

    response_present = bool(stdout.strip())
    passed = (
        not timed_out
        and return_code == 0
        and response_present
    )

    outcome = "PASSED" if passed else "FAILED"

    metadata = {
        "schema_version": "1.0",
        "test_id": arguments.test_id,
        "run_id": run_id,
        "outcome": outcome,
        "started_at": started_at,
        "completed_at": completed_at,
        "duration_seconds": duration_seconds,
        "timeout_seconds": arguments.timeout,
        "timed_out": timed_out,
        "hermes_executable": executable,
        "working_directory": str(Path.cwd()),
        "command": command,
        "exit_code": return_code,
        "response_present": response_present,
        "response_character_count": len(stdout),
        "stderr_character_count": len(stderr),
        "evidence": {
            "response": str(response_path),
            "stderr": str(stderr_path),
            "metadata": str(metadata_path),
        },
    }

    write_json(metadata_path, metadata)

    print(f"Hermes test: {arguments.test_id}")
    print(f"Outcome:     {outcome}")
    print(f"Exit code:   {return_code}")
    print(f"Duration:    {duration_seconds}s")
    print(f"Response:    {response_path}")
    print(f"Errors:      {stderr_path}")
    print(f"Metadata:    {metadata_path}")

    if passed:
        return EXIT_PASS

    if timed_out:
        return EXIT_TIMEOUT

    return EXIT_HERMES_FAILURE


if __name__ == "__main__":
    raise SystemExit(main())
