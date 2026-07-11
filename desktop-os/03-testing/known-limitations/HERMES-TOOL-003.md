# HERMES-TOOL-003 — Compound terminal command timeout

## Status

Open — blocks compound repository inspection through native Hermes terminal execution.

## First observed

11 July 2026.

## Active runtime profile

`neil-riley`

## Model

`gpt-5.4-mini`

## Proven behaviour

Hermes successfully executes a single simple terminal command:

`git -C "/Users/neilriley/kohd" rev-parse HEAD`

and returns the exact observed commit hash.

Hermes times out when instructed to execute one compound read-only command that gathers:

- branch;
- HEAD;
- working-tree status;
- file existence.

The same compound command succeeds immediately when executed directly in zsh.

## Isolation results

The timeout persists with:

- explicit `terminal,file` toolsets;
- `--yolo`;
- `--max-turns 2`;
- a 120-second timeout;
- a simplified shell-only command.

## Safety result

No repository or filesystem mutations were observed during timed-out tests.

## Impact

Native Hermes terminal orchestration is not certified for compound inspection commands.

## Required operating pattern

Until remediated:

1. use one simple terminal command per Hermes invocation;
2. independently validate each result;
3. aggregate results in the KOHD certification adapter;
4. do not ask Hermes to compose multi-command repository state reports.
