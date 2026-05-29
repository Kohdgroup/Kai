# Documentation Metadata Template

Use this frontmatter pattern for docs that can go stale or change meaning over time.

```yaml
---
title: <doc title>
status: draft|active|deprecated|archived
owner: <name or team>
source_issue: RELGOV-9
source_project: <Linear project name or id>
source_milestone: <milestone name or id>
last_verified: YYYY-MM-DD
review_due: YYYY-MM-DD
expiry_date: YYYY-MM-DD # optional
canonical_path: <path to canonical doc> # optional
mirror_of: <path to canonical doc> # optional
intentional_duplicate: true|false
risk_level: low|medium|high
---
```

## Required Guidance
- `owner` is mandatory for governed docs.
- `source_issue` should point to the Linear issue or governance thread that owns the content.
- `last_verified` must be updated when the content is checked against Linear.
- `review_due` should be set even when the doc is stable.
- `canonical_path` should be used when another doc is the single source of truth.
- `mirror_of` should be used only for deliberate mirrors.
- `intentional_duplicate` should be false by default.

## Example
```yaml
---
title: Slack token exhaustion alert policy
status: active
owner: Release & Governance
source_issue: RELGOV-8
source_project: CD_Client Delivery
source_milestone: Governance
last_verified: 2026-05-29
review_due: 2026-06-12
canonical_path: docs/02-governance/scrum_master_linear_autonomous.md
intentional_duplicate: false
risk_level: high
---
```
