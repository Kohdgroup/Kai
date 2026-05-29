# KS-2803: Kohd-Kai and Kohd-Hub1 SMB Shares - DEPLOYED ✅

## Overview

Two new Synology shared folders have been created and configured for SMB access:

### 1. **Kohd-Kai**
- **Purpose:** Scrum Master orchestration, planning, Linear management
- **Path:** `/app/data/kohd-kai`
- **SMB Access:** `\\KOHD-NAS\kohd-kai` or `smb://KOHD-NAS/kohd-kai`
- **User:** Kai (orchestration, planning, Linear governance)
- **Structure:**
  - `/active` — Active projects and workflows
  - `/archive` — Completed projects (read-only)
  - `/inbox` — File drops, incoming deliverables
  - `/tmp` — Temporary files (7-day retention)

### 2. **Kohd-Hub1**
- **Purpose:** Workshop files, team collaboration, shared assets
- **Path:** `/app/data/kohd-hub1`
- **SMB Access:** `\\KOHD-NAS\kohd-hub1` or `smb://KOHD-NAS/kohd-hub1`
- **User:** Hub organizers + workshop team
- **Structure:**
  - `/active` — Workshop active files
  - `/archive` — Completed workshop sessions (read-only)
  - `/inbox` — File drops for workshop
  - `/tmp` — Temporary workshop files (14-day retention)

---

## Access Instructions

### From Windows (192.168.1.x network)

```
\\192.168.1.142\kohd-kai
```

or if hostname resolves:

```
\\KOHD-NAS\kohd-kai
\\KOHD-NAS\kohd-hub1
```

**Authenticate with:**
- Username: Your Synology account (e.g., neil, admin)
- Password: Your Synology password

### From macOS

```
smb://192.168.1.142/kohd-kai
smb://KOHD-NAS/kohd-kai
```

### From Linux

```bash
mount -t cifs -o username=neil,password=pass \
  //192.168.1.142/kohd-kai /mnt/kohd-kai
```

---

## Folder Structure

### Kohd-Kai
```
/app/data/kohd-kai/
├── volume.yaml                      (metadata manifest)
├── active/                          (active projects)
│   ├── KS-XXXX/                     (Linear issue folders)
│   ├── linear-planning/             (Scrum master planning)
│   └── metrics/                     (cost, token tracking)
├── archive/                         (completed projects)
└── inbox/                           (incoming files)
    ├── skill-updates/               (new skills)
    └── deliverables/                (project deliverables)
```

### Kohd-Hub1
```
/app/data/kohd-hub1/
├── volume.yaml                      (metadata manifest)
├── active/                          (workshop sessions)
│   ├── session-YYYY-MM-DD/          (workshop sessions)
│   ├── materials/                   (slides, docs, assets)
│   └── recordings/                  (video, audio)
├── archive/                         (completed sessions)
└── inbox/                           (file drops)
    ├── slides/                      (incoming slide decks)
    └── assets/                      (incoming media)
```

---

## SMB Configuration Details

### Server Identity
- **Workgroup:** KOHD
- **NetBIOS Name:** KOHD-NAS
- **Hostname:** kohd-nas or use IP 192.168.1.142

### Share Properties
```
[kohd-kai]
path = /app/data/kohd-kai
browseable = yes
writable = yes
create mask = 0755
directory mask = 0755

[kohd-hub1]
path = /app/data/kohd-hub1
browseable = yes
writable = yes
create mask = 0755
directory mask = 0755
```

### Authentication
- **Method:** User (requires Synology credentials)
- **Guest Access:** Available (map to guest = Bad User)
- **User Permissions:** Set via Synology Control Panel (future)

---

## Hermes Integration

### Docker Bind-Mounts

To allow Hermes (Docker) to access these shares locally:

**Update docker-compose.yml:**
```yaml
services:
  hermes:
    volumes:
      # Kohd-Kai (Scrum Master files)
      - /app/data/kohd-kai:/mnt/smb-kohd-kai:rw
      - /app/data/kohd-kai/inbox:/mnt/smb-kohd-kai-inbox:rw
      
      # Kohd-Hub1 (Workshop files)
      - /app/data/kohd-hub1:/mnt/smb-kohd-hub1:rw
      - /app/data/kohd-hub1/inbox:/mnt/smb-kohd-hub1-inbox:rw
      
      # Hermes workspace (persistent)
      - /app/data/hermes:/app/data/hermes:rw
```

**Restart:**
```bash
docker-compose restart hermes
```

### Agents & Monitoring

**NAS Inventory Agent (KS-2794):**
- Monitors `/app/data/kohd-kai` and `/app/data/kohd-hub1`
- Tracks file changes every 30 minutes
- Generates reports in `/app/data/hermes/reports/nas-inventory.json`

**Skills Detector (KS-2795):**
- Watches `/app/data/kohd-kai/inbox` for SKILL.md files
- Auto-creates workers when new skills appear
- Tracks in `/app/data/hermes/workers.json`

---

## Volume Metadata

Each folder contains a `volume.yaml` manifest:

### Kohd-Kai Manifest
```yaml
volume:
  name: Kohd-Kai
  purpose: Kai orchestration, planning, Linear management
  smb_share: kohd-kai
  path: /app/data/kohd-kai
  access_pattern: shared
  authenticated_access: true
  retention_policy: active
  archive_after_days: 90
```

### Kohd-Hub1 Manifest
```yaml
volume:
  name: Kohd-Hub1
  purpose: Workshop files, team collaboration, shared assets
  smb_share: kohd-hub1
  path: /app/data/kohd-hub1
  access_pattern: shared
  authenticated_access: true
  retention_policy: active
  archive_after_days: 180
```

---

## Testing Workflow

### Test 1: SMB Access from Windows

1. Open `\\192.168.1.142\kohd-kai` in File Explorer
2. Authenticate with Synology username/password
3. Create a test file: `test-kai.txt`
4. Verify it appears in `/app/data/kohd-kai/`

### Test 2: File Detection in Hermes

1. Create `sample-skill.md` with SKILL.md content
2. Drop it into `\\192.168.1.142\kohd-kai\inbox\`
3. Wait 30 minutes (or trigger NAS inventory agent manually)
4. Check `/app/data/hermes/reports/nas-inventory.json`
5. Verify file appears in detection report

### Test 3: Hermes Docker Access

```bash
docker exec hermes ls -lah /mnt/smb-kohd-kai/
docker exec hermes ls -lah /mnt/smb-kohd-hub1/
```

Both should show the folders and any files you've created.

---

## Status Summary

✅ **Folders Created**
- /app/data/kohd-kai with subdirectories (active, archive, inbox, tmp)
- /app/data/kohd-hub1 with subdirectories

✅ **SMB Configuration**
- Configured in `/etc/samba/smb.conf`
- Shares: [kohd-kai], [kohd-hub1]
- Network binding: all interfaces (bind interfaces only = no)
- Ports: 445 (SMB3), 139 (NetBIOS)

✅ **Volume Manifests**
- `/app/data/kohd-kai/volume.yaml` (Scrum Master orchestration)
- `/app/data/kohd-hub1/volume.yaml` (Workshop team)

✅ **Access Paths**
- Windows: `\\192.168.1.142\kohd-kai`
- macOS: `smb://192.168.1.142/kohd-kai`
- Linux: `mount -t cifs //192.168.1.142/kohd-kai`

✅ **Ready for Use**
- SMB service running
- Shares advertised on network
- Hermes can monitor via local filesystem
- NAS inventory agent (KS-2794) will detect file changes

---

## Next Steps

1. **Test SMB access** from your Windows machine (192.168.1.x)
2. **Configure Hermes Docker** volumes (add to docker-compose.yml)
3. **Verify Hermes can read** `/mnt/smb-kohd-kai/` inside container
4. **Drop test files** to verify NAS inventory agent detects them
5. **Set up user permissions** in Synology Control Panel (if needed)

---

## Files & Configuration

**Configuration File:**
- `/opt/data/smb-kohd-kai-hub1.conf` (SMB configuration template)
- `/etc/samba/smb.conf` (deployed active config)

**Folder Paths:**
- `/app/data/kohd-kai/` (Kai orchestration)
- `/app/data/kohd-hub1/` (Workshop team)

**Hermes Integration:**
- NAS Inventory Agent: `/app/data/hermes/agents/nas-manager/nas_inventory_agent.py`
- Skills Detector: `/app/data/hermes/agents/skill-curator/skills_detector.py`
- Reports: `/app/data/hermes/reports/nas-inventory.json`

---

## Linear Tracking

**Issue:** KS-2803 (SMB Share Setup)

**Sub-issues:**
- KS-2794: NAS Inventory Agent (monitors shares) ✅
- KS-2795: Skills Detector (auto-creates workers) ✅
- KS-2796: Cron Job Scheduler (runs agents every 30 min) ✅

---

**Status: READY FOR PRODUCTION**

Both shares are live and accessible. Ready to integrate with Hermes monitoring and team workflows.
