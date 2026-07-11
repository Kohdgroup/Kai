# HERMES-TOOL-001 — Post-tool response contract violation

## Status

Open — blocks strict machine-response certification.

## First observed

11 July 2026.

## Affected test

`desktop-os/03-testing/tool-execution/test-file-write.sh`

## Expected behaviour

After completing the controlled file-write operation, Hermes must return exactly:

`KOHD_HERMES_FILE_WRITE_COMPLETE`

## Actual behaviour

Hermes:

1. creates the required file;
2. writes the exact required contents;
3. respects the permitted sandbox boundary;
4. makes no changes outside the sandbox;
5. returns exit code `0`;
6. emits tool diff output and a conversational completion message instead of the required marker.

In one run, Hermes also emitted an additional `skills_list` function payload.

## Isolation results

### Normal configuration

File operation succeeds, but the final response contract fails.

### `--ignore-rules`

File operation succeeds, but the final response contract still fails.

This indicates that repository rules, profile SOUL files, memory injection and preloaded skills are not the primary cause.

### `--ignore-user-config --ignore-rules`

Hermes returns:

`HTTP 401: Missing Authentication header`

This mode is not a valid operational comparison because user configuration currently supplies required provider authentication.

## Proven safe controls

The following controls pass consistently:

- exact target file creation;
- exact file contents;
- one permitted sandbox artefact only;
- no repository modifications outside the sandbox;
- unchanged tracked-file inventory.

## Impact

Hermes tool execution is suitable for controlled human-readable workflows but is not yet certified for downstream automation that depends directly on an exact final textual response.

## Required remediation

One of the following is required:

1. Hermes provides a strict machine-output or JSON mode after tool execution.
2. Hermes reliably honours an exact final-response marker.
3. A governed KOHD execution adapter independently verifies the action result and emits a canonical machine-readable completion result.

The native Hermes response violation must remain visible in evidence even where an adapter is used.
