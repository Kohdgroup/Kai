# Weekly Change Window Schedule

Source of truth: RELGOV-10

## Default cadence
- One grouped change window per week
- Preferred execution day: midweek
- Cutoff for inclusion: 24 hours before the window
- Emergency changes use break-glass handling and post-review

## Workflow
1. Add change request to Linear.
2. If it meets the cutoff, batch it into the next window.
3. If it misses cutoff, defer to the following week unless urgent.
4. Send Slack approval request before execution.
5. Notify affected people before change lands.

## Guardrails
- Avoid ad hoc production changes unless urgent.
- Combine safe, related changes together where possible.
- Keep validation and rollback steps ready before window opens.
