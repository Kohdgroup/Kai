# KOHD AI Workspace

Canonical Hermes-managed NAS-backed workspace for KOHD operations.

Root: `/app/data/hermes`

## Structure

### skills/
Reusable Hermes skills and agent procedures.
- `shared/` — approved, stable skills (class-level)
- `personal/` — worker-specific skill variants
- `experimental/` — new skills under development
- `archived/` — deprecated or retired skills

### agents/
Worker role definitions, instructions, and state.
- `nas-manager/` — orchestrates volume management
- `skill-curator/` — manages skill lifecycle
- `ingest/` — classifies and routes incoming files
- `research/` — knowledge discovery and synthesis

### prompts/
Reusable prompt templates and conversation frameworks.

### templates/
Document, email, and report templates.

### knowledge/
Organizational knowledge, reference docs, decision logs.

### volumes/
Multi-customer and multi-project data storage.

**ecopuk/** — EcoPUK customer operations
**kohd/** — KOHD platform and club data
**shared/** — Cross-project assets and common materials

Each volume follows: `inbox/ → active/ → archive/` + `tmp/`, `manifests/`, `reports/`.

### logs/, runs/, cache/
Operational, execution, and caching layers.

## Access & Permissions

All paths are readable/writable by Hermes workers with appropriate role permissions.

MailPlus integration: worker@kohd.io mailboxes route to worker inboxes for Linear notifications.

## Volumes Policy

See `volumes/{volume}/volume.yaml` for:
- Purpose and owner
- Retention policies
- Allowed writers
- Manifests and reporting structure

## Notes

- This workspace is the system of record for KOHD AI operations.
- Skills and worker state are synchronized with Linear issues.
- All changes should be logged as worker commits or task updates in Linear.
- Knowledge and decision logs should be maintained in `knowledge/` subdirectories.

Created: 2026-05-29
Last updated: 2026-05-29
