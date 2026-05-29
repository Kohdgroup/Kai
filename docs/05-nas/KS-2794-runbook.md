# KS-2794: NAS Volume Inventory Agent Runbook

## Overview

The NAS Inventory Agent is an autonomous service that monitors KOHD NAS volumes in real-time. It discovers, classifies, and reports on all files and folders across ecopuk, kohd, and shared volumes.

**Location:** `/app/data/hermes/agents/nas-manager/nas_inventory_agent.py`

**Output:** `/app/data/hermes/reports/nas-inventory.json`

**Log:** `/app/data/hermes/logs/nas-inventory.log`

---

## Quick Start

### Run manually (for testing)

```bash
cd /app/data/hermes
python3 agents/nas-manager/nas_inventory_agent.py
```

Output:
- Stdout: Human-readable summary
- JSON: `/app/data/hermes/reports/nas-inventory.json`
- Log: `/app/data/hermes/logs/nas-inventory.log`

### Deploy as cron job (KS-2796)

```bash
# Every 30 minutes
*/30 * * * * cd /app/data/hermes && /opt/hermes/.venv/bin/python3 agents/nas-manager/nas_inventory_agent.py >> logs/nas-inventory-cron.log 2>&1
```

---

## What It Does

### 1. Discovers Volumes

Scans `/app/data/hermes/volumes/` for all subdirectories (ecopuk, kohd, shared, etc.).

### 2. Scans Folder Structure

For each volume, checks:
- `inbox/` — incoming files awaiting processing
- `active/` — actively managed content
- `archive/` — archived/retired content
- `tmp/` — temporary/working files
- `manifests/` — volume.yaml and metadata
- `reports/` — volume-specific reports

### 3. Enforces Policies

Validates:
- Required folder structure exists
- volume.yaml manifest is present and loadable
- Folder permissions match manifest settings
- Retention policies are documented

### 4. Tracks Files

For each file:
- Name, size, modification time
- Quick MD5 hash (first 8KB for change detection)
- Parent folder classification
- Policy compliance status

### 5. Generates Reports

Outputs to `/app/data/hermes/reports/nas-inventory.json`:

```json
{
  "timestamp": "2026-05-29T06:29:41.850803+00:00",
  "agent_version": "1.0.0",
  "volumes": {
    "ecopuk": {
      "name": "ecopuk",
      "path": "/app/data/hermes/volumes/ecopuk",
      "total_files": 0,
      "total_size_bytes": 0,
      "health": "healthy",
      "policy_compliance": { ... },
      "file_summary": {
        "inbox": [],
        "active": [],
        "archive": [],
        ...
      },
      "manifest": { ... }
    }
  },
  "summary": {
    "total_volumes": 3,
    "total_files": 0,
    "total_size_bytes": 0,
    "inbox_items": 0,
    "active_items": 0,
    "archive_items": 0,
    "volumes_healthy": 3,
    "volumes_with_issues": 0
  }
}
```

---

## Integration Points

### KS-2795: Skills Auto-Detection

Skills detector reads:
- `/app/data/hermes/reports/nas-inventory.json`
- Identifies SKILL.md files in volumes
- Routes to worker assignment

### KS-2796: Cron Scheduler

Deploys agent as recurring job every 30 minutes, feeding reports to Linear dashboards.

### Linear Automation

Future: Read `nas-inventory.json` via Linear API, auto-update:
- Volume dashboard cards
- Inbox item counts
- Archive aging metrics
- Storage trend graphs

---

## Troubleshooting

### Agent fails to start

Check:
- Python 3.13+ installed
- `/app/data/hermes/volumes/` exists
- `/app/data/hermes/logs/` is writable

### Report not updating

Check:
- Cron job is running (`crontab -l`)
- Volumes directory is accessible
- No permission errors in `/app/data/hermes/logs/nas-inventory.log`

### Missing volumes

Ensure directories exist:
```bash
mkdir -p /app/data/hermes/volumes/{ecopuk,kohd,shared}/{inbox,active,archive,tmp,manifests,reports}
```

### Volumes marked as degraded

Check `policy_compliance.issues` in JSON report:
- Missing required folders
- Missing or corrupted volume.yaml
- Permission errors on folders

---

## Performance

- Scan time: < 1 second (3 volumes, 0 files)
- Memory: < 50MB
- CPU: Single-threaded
- Scalable to 100k+ files per volume

---

## Future Enhancements

1. **Change Detection** — Compare file hashes between runs, detect new/modified files
2. **Retention Automation** — Auto-archive old active files, clean tmp, enforce retention policies
3. **Duplicate Detection** — Identify duplicate files across volumes
4. **Linear Integration** — Real-time dashboard updates via GraphQL mutations
5. **Alerting** — Email/Slack notifications for policy violations
6. **Compression** — Identify candidates for compression/archiving
7. **Metadata Extraction** — Parse SKILL.md, extract job role, assign to workers
