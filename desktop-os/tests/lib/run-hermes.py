#!/opt/homebrew/bin/python3.12

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--profile", required=True)
    parser.add_argument("--prompt-file", required=True)
    parser.add_argument("--output-file", required=True)
    parser.add_argument("--timeout", type=int, default=180)
    args = parser.parse_args()

    prompt = Path(args.prompt_file).read_text(encoding="utf-8").strip()
    output_path = Path(args.output_file)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    command = [
        "hermes",
        "-p",
        args.profile,
        "-z",
        prompt,
    ]

    try:
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            timeout=args.timeout,
            check=False,
        )
    except subprocess.TimeoutExpired as exc:
        output_path.write_text(
            f"TIMEOUT after {args.timeout} seconds\n"
            f"STDOUT:\n{exc.stdout or ''}\n"
            f"STDERR:\n{exc.stderr or ''}\n",
            encoding="utf-8",
        )
        return 124

    combined = result.stdout.strip()

    if result.stderr.strip():
        combined += "\n\nSTDERR:\n" + result.stderr.strip()

    output_path.write_text(combined + "\n", encoding="utf-8")
    return result.returncode


if __name__ == "__main__":
    sys.exit(main())
