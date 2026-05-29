# Slack Approval Request Template

Source of truth: Linear change request (RELGOV-10 and children)

## Message format
**Change request:** <title>

**Window:** <week/date/time>
**Risk:** <low/medium/high>
**Systems affected:** <list>
**Why:** <short business reason>
**Dependencies:** <list>
**Rollback:** <short rollback summary>
**Validation:** <how we know it worked>
**Affected people notified:** <yes/no + list>
**Linear link:** <issue URL>

## Approval action
Reply with one of:
- APPROVE
- REJECT
- NEEDS INFO

## Rules
- High-risk changes require Neil's explicit approval.
- No approval = no execution.
- Slack approval is a gate, not a discussion thread.
