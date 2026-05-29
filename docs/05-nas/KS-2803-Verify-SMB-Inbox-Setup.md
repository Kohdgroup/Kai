# KS-2803: Verify SMB Inbox Setup & Drop Skill File

## Current Status

✅ **Inbox directories exist** (verified via /app/data filesystem):
- /app/data/kohd-kai/inbox/ — EMPTY
- /app/data/kohd-hub1/inbox/ — EMPTY
- /app/data/kohd-group/inbox/ — EMPTY

✅ **SMB Inbox Manager is functional** (Python script ready to process files on demand)

❌ **Your skill file** — Not found in any inbox

## Step-by-Step: Drop & Process Your Skill File

### Step 1: Locate Your Skill File

Where did you drop the skill file? 
- From Windows: `\\192.168.1.142\kohd-kai\` (root, not inbox subfolder)
- From Mac: `smb://192.168.1.142/kohd-kai/` 
- Filename: `*.skill.md`

### Step 2: Move It to the Inbox (IMPORTANT)

**From Windows File Explorer:**

1. Open: `\\192.168.1.142\kohd-kai`
2. You should see: `active/`, `archive/`, `inbox/`, `tmp/` folders
3. If your skill file is in the root (kohd-kai/), **cut it** and **paste it into kohd-kai/inbox/**
4. Example:
   - FROM: `\\192.168.1.142\kohd-kai\my-skill.skill.md`
   - TO: `\\192.168.1.142\kohd-kai\inbox\my-skill.skill.md`

**From macOS Finder:**

1. Go → Connect to Server: `smb://192.168.1.142/kohd-kai`
2. Navigate to `inbox` folder
3. Drag your `.skill.md` file into the inbox folder

### Step 3: Verify Processing

Once your file is in the inbox:

**From Windows:**
- Open: `\\192.168.1.142\kohd-kai\inbox\`
- You should see your file there
- Wait 30 seconds
- The file should **move to** `\\192.168.1.142\kohd-kai\archive\`

**Command line (test locally):**
```bash
# This will scan the inboxes and process any files
cd /app/data/hermes/agents/nas-manager
python3 /app/data/hermes/agents/nas-manager/inline_smb_processor.py
```

## File Processing Rules

| File Type | Action | Destination |
|-----------|--------|-------------|
| `*.skill.md` | Load skill | `/opt/data/skills/` + archive |
| `*.task.json` | Create Linear issue | `/app/data/hermes/tasks/` + archive |
| `*.yaml` | Merge config | `/opt/data/` + archive |
| `*.pptx`, `*.pdf` | Archive | `/kohd-kai/archive/` |
| Other files | Move to active | `/kohd-kai/active/` |

## Quick Verification

Check if your file was processed:

```bash
# List inbox (should be empty after processing)
ls -la /app/data/kohd-kai/inbox/

# List archive (should contain your file)
ls -la /app/data/kohd-kai/archive/

# Check state file (shows what was processed)
cat /app/data/hermes/smb_manager_state.json
```

## Why the File Didn't Move

Most likely:
1. ✅ **Inbox directory structure** — Created correctly
2. ✅ **SMB shares** — Accessible and visible in File Station
3. ❌ **File location** — You dropped it in the root (kohd-kai/) instead of subfolder (kohd-kai/inbox/)
4. ❌ **Processing hasn't run yet** — SMB manager needs to be triggered

## Next Steps

1. **Move your skill file** to the inbox folder using File Station or Finder
2. **Verify it appears** in `\\192.168.1.142\kohd-kai\inbox\`
3. **Run the processor** (or wait for scheduled scan)
4. **Check archive** — file should move there after processing
5. **Verify skill** was loaded to `/opt/data/skills/`

---

**Questions?** Check:
- File Station on Synology DSM (visible folders?)
- SMB access from your machine (`\\192.168.1.142\kohd-kai` accessible?)
- File permissions (can you create/delete files in the inbox?)
