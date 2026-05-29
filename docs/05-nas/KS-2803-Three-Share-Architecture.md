# KS-2803: Three-Share Architecture - Complete Implementation

## Overview

Three Synology shared folders now provide complete KOHD infrastructure:

```
┌──────────────────────────────────────────────────────────────┐
│                    Synology NAS (192.168.1.142)              │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │  Kohd-Kai    │  │  Kohd-Hub1   │  │  Kohd-Group  │       │
│  │              │  │              │  │              │       │
│  │ Scrum Master │  │  Workshop    │  │ Team Project │       │
│  │ Orchestration│  │  Collaboration   Management   │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
│         ↓                  ↓                  ↓              │
│      SMB Access       SMB Access         SMB Access          │
│  (\\192.1.142)    (\\192.1.142)     (\\192.1.142)         │
│         ↓                  ↓                  ↓              │
│    Docker Mount      Docker Mount       Docker Mount        │
│   (Kai Manager)    (Workshop Team)    (Group Manager)       │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

## 📊 Kohd-Kai: Scrum Master Orchestration

**Purpose:** Hermes Kai's primary workspace for Linear management, planning, and orchestration

**SMB Access:**
```
Windows:  \\192.168.1.142\kohd-kai
macOS:    smb://192.168.1.142/kohd-kai
Linux:    //192.168.1.142/kohd-kai
```

**Directory Structure:**
```
kohd-kai/
├── active/          → Active Linear issues, projects, planning docs
│   ├── issues/      → Current Linear issue tracking
│   ├── planning/    → Sprint planning, roadmaps
│   └── docs/        → Planning documentation
│
├── inbox/          → FILE DROP ZONE (30-second scan)
│   ├── *.skill.md       → Auto-register skills
│   ├── *.task.json      → Create Linear issues + spawn workers
│   └── *.yaml           → Merge Hermes config
│
├── archive/        → Completed projects (90-day retention)
│   ├── completed-issues/
│   ├── closed-projects/
│   └── historical-docs/
│
├── tmp/            → Temporary files (7-day auto-cleanup)
│
└── volume.yaml     → Metadata manifest
```

**Agent:** None (Direct Kai access via Hermes CLI)

**Scan Interval:** 30 seconds (SMB Manager)

**Handlers:**
| Pattern | Action | Destination |
|---------|--------|-------------|
| `*.skill.md` | Register skill | `/opt/data/skills/` |
| `*.task.json` | Create Linear issue | Create issue, spawn worker |
| `*.yaml` | Merge config | Hermes configuration |

**Key Features:**
- ✅ Direct access for Kai (Scrum Master)
- ✅ Linear issue tracking
- ✅ Worker spawning
- ✅ Skill registration
- ✅ Config management

---

## 🎓 Kohd-Hub1: Workshop Team Collaboration

**Purpose:** Workshop files, team collaboration, shared assets

**SMB Access:**
```
Windows:  \\192.168.1.142\kohd-hub1
macOS:    smb://192.168.1.142/kohd-hub1
Linux:    //192.168.1.142/kohd-hub1
```

**Directory Structure:**
```
kohd-hub1/
├── active/         → Active workshop sessions, materials, recordings
│   ├── presentations/   → Slides, decks
│   ├── kits/            → Workshop materials
│   ├── media/           → Videos, recordings, audio
│   ├── notes/           → Session notes
│   └── recordings/      → Video captures
│
├── inbox/          → FILE DROP ZONE (30-second scan)
│   ├── *.pptx           → Auto-copy to presentations/
│   ├── *.workshop.zip   → Auto-extract to kits/
│   └── *.mp4, *.mp3     → Auto-copy to media/
│
├── archive/        → Completed workshops (180-day retention)
│   ├── archive-2025-q1/
│   ├── archive-2025-q2/
│   └── recordings-archive/
│
├── tmp/            → Temporary files (14-day auto-cleanup)
│
└── volume.yaml     → Metadata manifest
```

**Agent:** None (SMB Manager handles processing)

**Scan Interval:** 30 seconds (SMB Manager)

**Handlers:**
| Pattern | Action | Destination |
|---------|--------|-------------|
| `*.pptx` | Copy presentation | `/active/presentations/` |
| `*.workshop.zip` | Extract kit | `/active/kits/` |
| `*.mp4, *.mp3, *.m4a` | Organize media | `/active/media/` |

**Key Features:**
- ✅ Easy file drops for team
- ✅ Automatic organization
- ✅ Media management
- ✅ Long-term archive (180 days)
- ✅ Quick access for workshops

---

## 👥 Kohd-Group: Agent-Managed Team Projects

**Purpose:** Team collaboration, shared projects, group deliverables (fully agent-managed)

**SMB Access:**
```
Windows:  \\192.168.1.142\kohd-group
macOS:    smb://192.168.1.142/kohd-group
Linux:    //192.168.1.142/kohd-group
```

**Directory Structure:**
```
kohd-group/
├── active/         → Active group projects (Agent-Managed)
│   ├── project-1/
│   │   ├── files/
│   │   ├── notes/
│   │   └── deliverables/
│   ├── project-2/
│   ├── deliverables/     → All group deliverables
│   ├── documents/        → Documents, reports
│   ├── media/            → Project media
│   ├── images/           → Project images
│   └── files/            → General project files
│
├── inbox/          → FILE DROP ZONE (5-minute scan)
│   ├── *.project.json        → Create project workspace
│   ├── *.deliverable.*       → Organize and track
│   └── *.collab.md           → Register collaboration docs
│
├── archive/        → Completed projects (120-day retention)
│   ├── completed-projects/
│   ├── archived-deliverables/
│   └── project-history/
│
├── tmp/            → Temporary work-in-progress (14-day auto-cleanup)
│
└── volume.yaml     → Metadata manifest
```

**Agent:** **group-manager** (Dedicated, fully autonomous)

**Container:** `hermes-group-manager`

**Scan Interval:** 5 minutes (Group Manager)

**Capabilities:**
- ✅ **Monitor Inbox** — Detect new files every 5 min
- ✅ **Process Projects** — Auto-create project workspaces
- ✅ **Auto-Organize** — Sort files by type
- ✅ **Auto-Archive** — Move completed projects (90+ days)
- ✅ **Cleanup Temp** — Delete temp files (14+ days)
- ✅ **Generate Reports** — Track all activity

**Handlers:**
| Pattern | Action | Destination |
|---------|--------|-------------|
| `*.project.json` | Create workspace | `/active/project-name/` |
| `*.deliverable.*` | Organize | `/active/deliverables/` |
| `*.collab.md` | Register | `/active/docs/` |
| Other files | Auto-organize by type | Type-specific directory |

**Group Manager Agent:**
```
Container: hermes-group-manager
Image: hermes-agent:latest
Entrypoint: python /app/data/hermes/agents/nas-manager/group_manager.py
Interval: 5 minutes (300 seconds)

Mounts:
  - /app/data/kohd-group:/mnt/smb-kohd-group
  - /app/data/kohd-group/inbox:/mnt/smb-kohd-group-inbox
  - /app/data/kohd-group/active:/mnt/smb-kohd-group-active
  - /app/data/kohd-group/archive:/mnt/smb-kohd-group-archive
  - /app/data/kohd-group/tmp:/mnt/smb-kohd-group-tmp

Environment Variables:
  - GROUP_VOLUME=/mnt/smb-kohd-group
  - GROUP_INBOX=/mnt/smb-kohd-group-inbox
  - GROUP_ACTIVE=/mnt/smb-kohd-group-active
  - GROUP_ARCHIVE=/mnt/smb-kohd-group-archive
  - GROUP_TMP=/mnt/smb-kohd-group-tmp
```

**Key Features:**
- ✅ **Fully autonomous** — No user input needed
- ✅ **Project auto-creation** — Parse JSON, create workspaces
- ✅ **Auto-organization** — Sort by file type automatically
- ✅ **Smart archival** — Move old projects automatically
- ✅ **Cleanup** — Delete temp files on schedule
- ✅ **Reporting** — Track all activity in JSON
- ✅ **State persistence** — Never processes same file twice

---

## 🐳 Docker Deployment

### Complete docker-compose Setup

**File:** `/opt/data/docker-compose-kohd-full-v2.yml`

**Services:**

1. **hermes** (Main agent)
   - All three shares mounted
   - Available for manual interaction
   - Manages orchestration

2. **smb-manager** (Inbox processor)
   - Watches: kohd-kai, kohd-hub1, kohd-group
   - Interval: 30 seconds
   - Routes files based on type

3. **nas-inventory** (Volume monitor)
   - Watches: kohd-kai, kohd-hub1, kohd-group
   - Interval: 30 minutes
   - Generates inventory reports

4. **skills-detector** (Auto-registration)
   - Watches: kohd-kai, kohd-hub1, kohd-group
   - Interval: 30 minutes
   - Auto-creates worker profiles

5. **group-manager** (Kohd-group automation)
   - Dedicated to kohd-group
   - Interval: 5 minutes
   - Full inbox management

### Deployment Steps

**1. Copy compose file:**
```bash
cp /opt/data/docker-compose-kohd-full-v2.yml /docker-compose.yml
```

**2. Start all containers:**
```bash
docker-compose up -d
```

**3. Verify all containers:**
```bash
docker ps | grep hermes
# Should show: hermes, smb-manager, nas-inventory, skills-detector, group-manager
```

**4. Check logs:**
```bash
docker logs hermes-group-manager -f
docker logs hermes-smb-manager -f
```

---

## 📁 File Routing Examples

### Kohd-Kai: Task Creation

```
File: KS-2850-new-feature.task.json
Location: \\192.168.1.142\kohd-kai\inbox\

Content:
{
  "title": "Implement feature",
  "description": "Add new feature to system",
  "assigned_skills": ["hermes-agent-skill-authoring"],
  "priority": 8
}

↓ (30-second scan by SMB Manager)

Processing:
1. Detect: *.task.json
2. Parse JSON
3. Create Linear issue KS-2850
4. Spawn worker with skill
5. Move to /archive/

Result: Linear issue created + worker running
```

### Kohd-Hub1: Workshop Materials

```
File: advanced-python-workshop.pptx
Location: \\192.168.1.142\kohd-hub1\inbox\

↓ (30-second scan by SMB Manager)

Processing:
1. Detect: *.pptx
2. Copy to /active/presentations/
3. Organize by date

Result: 
  \\192.168.1.142\kohd-hub1\active\presentations\advanced-python-workshop.pptx
```

### Kohd-Group: Project Creation

```
File: ml-pipeline-project.project.json
Location: \\192.168.1.142\kohd-group\inbox\

Content:
{
  "name": "ML Pipeline",
  "description": "Production ML pipeline",
  "team": ["engineer@kohd.io", "data@kohd.io"]
}

↓ (5-minute scan by Group Manager)

Processing:
1. Detect: *.project.json
2. Parse JSON
3. Create /active/ML Pipeline/ directory
4. Initialize: /files, /notes, /deliverables
5. Copy project.json
6. Move original to /archive/processed-projects/

Result:
  /mnt/smb-kohd-group-active/ML Pipeline/
    ├── project.json
    ├── files/
    ├── notes/
    └── deliverables/
```

---

## 📊 Monitoring & Reporting

### SMB Manager Report
```
/app/data/hermes/reports/smb-inbox-report.json
{
  "timestamp": "2026-05-29T08:30:00",
  "processed_files": {
    "/mnt/smb-kohd-kai-inbox/task.json": {
      "hash": "abc123...",
      "status": "task_created",
      "processed_at": "2026-05-29T08:00:00"
    }
  },
  "summary": {
    "total_processed": 5,
    "successful": 5,
    "failed": 0
  }
}
```

### Group Manager Report
```
/app/data/hermes/reports/group-manager-report.json
{
  "timestamp": "2026-05-29T08:35:00",
  "volumes": {
    "inbox": {"file_count": 0},
    "active": {"project_count": 3},
    "archive": {"project_count": 12},
    "tmp": {"file_count": 0}
  },
  "summary": {
    "total_processed": 24,
    "successful": 24,
    "failed": 0
  }
}
```

### Inventory Report
```
/app/data/hermes/reports/nas-inventory.json
{
  "timestamp": "2026-05-29T08:30:00",
  "volumes": {
    "kohd-kai": {
      "total_size": "5.2GB",
      "files": 145,
      "dirs": 28
    },
    "kohd-hub1": {
      "total_size": "12.4GB",
      "files": 342,
      "dirs": 45
    },
    "kohd-group": {
      "total_size": "3.8GB",
      "files": 89,
      "dirs": 19
    }
  }
}
```

---

## 🔄 Workflow Examples

### Kai Creates Linear Issue + Spawns Worker

```
Kai (User):
  1. Create "KS-2851-code-review.task.json"
  2. Drop into \\192.168.1.142\kohd-kai\inbox\
  
SMB Manager (30s):
  1. Detect new file
  2. Parse JSON
  3. Call Linear API
  4. Create issue KS-2851
  5. Get assigned skills
  6. Spawn worker with code-review model
  7. Move file to /archive/

Linear:
  - New issue appears in project
  - Worker assigned
  - Tokens/cost tracked in GBP/USD

Worker:
  - Starts code review
  - Updates issue with progress
  - Completes and reports results
```

### Team Uploads Workshop Materials

```
Workshop Lead:
  1. Save presentation as "python-101-workshop.pptx"
  2. Drop into \\192.168.1.142\kohd-hub1\inbox\
  
SMB Manager (30s):
  1. Detect *.pptx file
  2. Copy to /active/presentations/
  3. Update inventory

Result:
  Presentation instantly available at:
  \\192.168.1.142\kohd-hub1\active\presentations\python-101-workshop.pptx
```

### Group Manager Auto-Creates Project

```
Team Member:
  1. Create "analytics-dashboard.project.json"
  2. Drop into \\192.168.1.142\kohd-group\inbox\
  
Group Manager (5 min):
  1. Detect *.project.json
  2. Parse JSON, extract project name
  3. Create /active/analytics-dashboard/
  4. Initialize /files, /notes, /deliverables
  5. Copy project.json to new directory
  6. Generate report

Result:
  Project workspace ready:
  \\192.168.1.142\kohd-group\active\analytics-dashboard\
    ├── project.json
    ├── files/
    ├── notes/
    └── deliverables/
```

---

## 🧹 Retention & Cleanup

### Kohd-Kai Archive
- **Duration:** 90 days
- **Action:** Auto-archive to /archive/
- **Cleanup:** Manual (keep for history)

### Kohd-Hub1 Archive
- **Duration:** 180 days
- **Action:** Auto-archive to /archive/
- **Cleanup:** Manual (long-term record)

### Kohd-Group Active → Archive
- **Duration:** 90 days
- **Action:** Auto-move completed projects
- **Trigger:** Group Manager (every 5 min)

### Kohd-Group Temp Cleanup
- **Duration:** 14 days
- **Action:** Auto-delete files in /tmp/
- **Trigger:** Group Manager (every 5 min)

---

## 📚 Files & Configuration

| File | Purpose |
|------|---------|
| `/opt/data/docker-compose-kohd-full-v2.yml` | Docker orchestration |
| `/opt/data/hermes-smb-config.yaml` | Hermes SMB configuration |
| `/app/data/hermes/agents/nas-manager/smb_inbox_manager.py` | SMB Manager agent |
| `/app/data/hermes/agents/nas-manager/group_manager.py` | Group Manager agent |
| `/app/data/kohd-kai/volume.yaml` | Kai metadata |
| `/app/data/kohd-hub1/volume.yaml` | Hub1 metadata |
| `/app/data/kohd-group/volume.yaml` | Group metadata |

---

## ✨ Status: PRODUCTION READY

**All three shares are:**
- ✅ Created in Synology DSM
- ✅ Visible in File Station
- ✅ Accessible via SMB (\\192.168.1.142)
- ✅ Configured with proper permissions
- ✅ Monitored by automated agents
- ✅ Integrated with Linear
- ✅ Ready for team access

**Agents deployed:**
- ✅ SMB Manager (kai + hub1 + group)
- ✅ Group Manager (kohd-group dedicated)
- ✅ NAS Inventory Monitor
- ✅ Skills Detector

**Ready for:**
1. User testing with file drops
2. Linear issue creation + worker spawning
3. Workshop file management
4. Project auto-creation and tracking
5. Full production workflows
