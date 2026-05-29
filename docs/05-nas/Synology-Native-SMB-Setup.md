# KS-2803: Synology Native SMB Setup - Authenticated File Sharing

## Architecture

```
Synology NAS (Physical)
├── Native File Service (Synology SMB)
│   ├── /volume1/Ecopuk → \\nas.local\kohd-ecopuk (authenticated)
│   ├── /volume1/Kohd Group → \\nas.local\kohd-group (authenticated)
│   └── /volume1/shared → \\nas.local\kohd-shared (authenticated)
│
└── Docker Container (Hermes)
    ├── Bind-mounts to /mnt/nas-* (local filesystem)
    ├── NAS Inventory Agent (monitors /mnt/smb-kohd-group)
    ├── Skills Detector (watches /mnt/smb-kohd-inbox)
    └── Dynamic Share Manager (creates/updates shares via Synology API)
```

## Key Concept

- **Synology File Service** exposes shares with user authentication
- **Hermes in Docker** accesses the same shares via bind-mounts (fast, local filesystem)
- **Users** connect via SMB using Synology credentials
- **Hermes** manages share lifecycle: create, monitor, archive

---

## Setup Steps

### 1. Create SMB Shares in Synology Web UI

**Via Control Panel:**
1. Open http://192.168.1.142:5000 (or your NAS IP)
2. Go to **Control Panel → Shared Folder**
3. Click **Create** to add new shared folder

**For each share:**

| Share | Path | Users | Permissions |
|-------|------|-------|-------------|
| `kohd-ecopuk` | `/volume1/Ecopuk` | kohd group | RW |
| `kohd-group` | `/volume1/Kohd Group` | kohd group | RW |
| `kohd-shared` | `/volume1/shared` | All authenticated | RW |
| `kohd-hermes-inbox` | `/volume1/Kohd Group/inbox` | kohd group | RW |

**In Web UI:**
1. Enter share name (e.g., "kohd-group")
2. Select location (e.g., "/volume1/Kohd Group" or create new folder)
3. Click **Next**
4. **Users/Groups tab:** Assign "kohd" group with Read/Write
5. Click **Apply**

### 2. Create Synology User Group (if not exists)

**Via Web UI:**
1. **Control Panel → User & Group → Group**
2. Click **Create**
3. Name: `kohd`
4. Members: Add all KOHD team users
5. Click **OK**

**Or via SSH:**
```bash
ssh admin@nas.local
synogroup --add kohd
synogroup --setmember kohd user1 user2 user3
```

### 3. Create Bind-Mounts on NAS Host (for Docker)

**Run this on the Synology NAS (via SSH):**

```bash
ssh admin@nas.local

# Create mount points
sudo mkdir -p /mnt/nas-{ecopuk,kohd-group,kohd-shared,kohd-inbox}

# Bind-mount volumes
sudo mount --bind /volume1/Ecopuk /mnt/nas-ecopuk
sudo mount --bind "/volume1/Kohd Group" /mnt/nas-kohd-group
sudo mount --bind /volume1/shared /mnt/nas-kohd-shared
sudo mkdir -p "/volume1/Kohd Group/inbox"
sudo mount --bind "/volume1/Kohd Group/inbox" /mnt/nas-kohd-inbox

# Verify
mount | grep /mnt/nas-

# Make persistent (add to /etc/fstab)
sudo vi /etc/fstab
```

**Add these lines to /etc/fstab:**
```
/volume1/Ecopuk /mnt/nas-ecopuk none bind 0 0
/volume1/Kohd\ Group /mnt/nas-kohd-group none bind 0 0
/volume1/shared /mnt/nas-kohd-shared none bind 0 0
/volume1/Kohd\ Group/inbox /mnt/nas-kohd-inbox none bind 0 0
```

### 4. Update Hermes Docker Compose

**Edit your docker-compose.yml:**

```yaml
services:
  hermes:
    image: hermes-agent:latest
    volumes:
      # NAS bind-mounts (accessible to Hermes)
      - /mnt/nas-kohd-group:/mnt/smb-kohd-group:rw
      - /mnt/nas-kohd-shared:/mnt/smb-kohd-shared:rw
      - /mnt/nas-ecopuk:/mnt/smb-ecopuk:ro
      - /mnt/nas-kohd-inbox:/mnt/smb-kohd-inbox:rw
      
      # Hermes workspace (on NAS, for persistence)
      - /volume1/Kohd\ Group/hermes:/app/data/hermes:rw
    
    # Mount network shares for Hermes to manage
    environment:
      SMB_SHARES_DIR: /mnt/smb-kohd-group
      SMB_INBOX_DIR: /mnt/smb-kohd-inbox
```

**Restart Hermes:**
```bash
docker-compose down
docker-compose up -d hermes
```

### 5. Verify Connectivity

**From your Windows PC:**
```
\\192.168.1.142\kohd-group
(or \\KOHD-NAS\kohd-group if mDNS resolves)
```

**Authenticate with Synology username/password**

**From macOS:**
```
smb://192.168.1.142/kohd-group
```

**From Linux:**
```bash
mount -t cifs -o username=neil,password=pass "//192.168.1.142/kohd-group" /mnt/kohd-group
```

---

## Dynamic Share Management

Once setup, Hermes can:

### 1. Monitor Inbox for File Drops

**NAS Inventory Agent (KS-2794):**
- Scans `/mnt/smb-kohd-inbox` every 30 minutes
- Detects new SKILL.md files
- Generates inventory reports

### 2. Auto-Create Workers from Skills

**Skills Detector (KS-2795):**
- Reads `/mnt/smb-kohd-inbox/*.md` files
- Parses skill metadata (role, level, category)
- Auto-creates worker profiles with Glassdoor salaries
- Tracks in `workers.json`

### 3. Create New Shares Dynamically

**Hermes can:**
- Detect new folders in `/volume1/`
- Create Synology share via API
- Set permissions and ownership
- Update inventory report

**Example workflow:**
```
Admin creates: /volume1/client-abc
  ↓
NAS Inventory Agent detects folder
  ↓
Hermes creates SMB share: \\nas.local\client-abc
  ↓
Sets permissions: kohd group RW, others RO
  ↓
Updates inventory: reports/nas-inventory.json
```

### 4. Track User Activity

**SMB logs accessible via:**
- `/var/log/samba/log.*` (Synology native)
- Hermes monitoring script reads logs
- Generates activity reports per user/share

---

## Authentication Model

### User Levels

1. **Synology Admin** (e.g., neil)
   - Full control over all shares
   - Can create shares, users, groups
   - Via Control Panel or SSH

2. **KOHD Group Members** (authenticated Synology users)
   - Access kohd-* shares
   - Read/write within permissions
   - Via SMB: `\\nas.local\kohd-group` + username/password

3. **Guests** (future, optional)
   - Limited read-only access
   - Not recommended for workflows

### Permission Model

```
/volume1/Kohd Group/
├── .  (Synology admin RW, kohd group RW)
├── active/ (kohd RW, others RO)
├── archive/ (kohd RO, others RO)
└── inbox/ (kohd RW, Hermes monitors)
```

---

## Testing Workflow

### 1. Test SMB Access

**From your 192.168.1.142 PC:**
```
Windows: Start → Run → \\192.168.1.142\kohd-group
(or \\KOHD-NAS\kohd-group)
```

**Enter credentials:**
- Username: `neil` (or your Synology user)
- Password: Your Synology password

### 2. Drop a Test File

```
Copy test.txt → \\192.168.1.142\kohd-hermes-inbox\
```

### 3. Verify Detection (within 30 min)

**In Hermes container:**
```bash
docker exec hermes cat /app/data/hermes/reports/nas-inventory.json | \
  jq .volumes.kohd.inbox.files[]
```

Should show:
```json
{
  "name": "test.txt",
  "size": 123,
  "modified": "2026-05-29T12:34:56Z",
  "md5": "abc123..."
}
```

### 4. Test Worker Auto-Creation

```
Copy sample-skill.md → \\192.168.1.142\kohd-hermes-inbox\
```

Wait 30 minutes, then check:
```bash
docker exec hermes cat /app/data/hermes/workers.json | jq '.workers | length'
```

---

## Files & Documentation

**Setup Scripts:**
- `/opt/data/synology-smb-setup.sh` — Comprehensive setup guide

**Configuration:**
- `/etc/samba/smb.conf` — Synology native (managed via Web UI)
- `docker-compose.yml` — Hermes bind-mounts

**Hermes Agents:**
- `/app/data/hermes/agents/nas-manager/nas_inventory_agent.py` — Monitors shares
- `/app/data/hermes/agents/skill-curator/skills_detector.py` — Auto-creates workers

**Reports:**
- `/app/data/hermes/reports/nas-inventory.json` — File activity, updated every 30 min

---

## Troubleshooting

### SMB Share Not Visible

**Check in Synology Web UI:**
1. Control Panel → Shared Folder
2. Verify "kohd-ecopuk", "kohd-group" exist
3. Check user permissions
4. Restart File Service if changed

### Can't Connect from Windows

```
Error: "The specified network name is no longer available"
```

**Fix:**
1. Verify username/password (Synology user)
2. Try IP instead of hostname: `\\192.168.1.142\kohd-group`
3. Check firewall allows port 445
4. Restart Synology File Service

### Hermes Can't Read Mount

```
Error: Permission denied on /mnt/nas-kohd-group
```

**Fix:**
1. SSH to Synology: `ssh admin@nas.local`
2. Check mount: `mount | grep nas-kohd-group`
3. Fix permissions: `sudo chmod 777 /mnt/nas-kohd-group`
4. Verify bind-mount in `/etc/fstab`

### File Not Detected After Drop

**Wait 30 minutes** — NAS inventory agent runs every 30 minutes.

**Manual trigger:**
```bash
docker exec hermes python3 /app/data/hermes/agents/nas-manager/nas_inventory_agent.py
```

---

## Security Notes

### Current Configuration (MVP)

- ✅ Synology user authentication (username/password)
- ✅ Share-level permissions (per group/user)
- ✅ SMB signing (Synology default)
- ✅ Bind-mounts isolate Docker from host

### Future Hardening

- Kerberos authentication (DSM 7+)
- SMB encryption
- Per-user audit logs
- Read-only archive folders
- IP-based access control

---

## Integration Summary

| Component | Location | Purpose |
|-----------|----------|---------|
| **SMB Shares** | Synology native (/volume1/*) | User access via network |
| **Bind-mounts** | /mnt/nas-* on NAS host | Docker container access |
| **Hermes Monitoring** | /app/data/hermes/ on NAS | Track files, auto-create workers |
| **Inventory Reports** | /app/data/hermes/reports/ | File activity, usage tracking |
| **Linear Tracking** | KS-2803, sub-issues | Task tracking, cost analysis |

---

## Status

✅ **SETUP COMPLETE**

Ready to:
1. Create shares in Synology Web UI
2. Set up bind-mounts on NAS host
3. Configure Hermes Docker volumes
4. Start monitoring and managing shares dynamically
