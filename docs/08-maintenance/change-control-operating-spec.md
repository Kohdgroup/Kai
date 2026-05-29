# Change Control Operating Spec

Source of truth: Linear issue RELGOV-10

## Guardrails
- No production-impacting change lands without a change request.
- No high-risk change lands without Slack approval.
- No request is complete without dependencies, validation, rollback, and comms recipients.
- Weekly batching is the default.
- Emergency/break-glass changes must be explicitly marked.

## Operating Flow
1. Open a Linear change request.
2. Attach dependencies, blast radius, rollback, validation, and recipients.
3. Batch into the weekly window if possible.
4. Request Slack approval from Neil for high-risk changes.
5. Notify affected people before execution.
6. Execute, validate, and record the outcome in Linear.

## Current Workstreams
- Slack approval request format and approval handling
- Weekly change-window cadence and batching rules
- Change request template fields and guardrails
- Automated comms to affected people and notification routing
