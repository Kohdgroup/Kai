# KS-2803: Creating Synology Shared Folders via DSM Control Panel

## Quick Start - Create Shares in 5 Minutes

### **Step 1: Open Synology DSM Web Interface**

Go to: **http://192.168.1.142:5000** (or use hostname if available)

Log in with your Synology admin credentials (e.g., admin/password)

---

## **Step 2: Create First Share - "Kohd-Kai"**

1. In DSM, go to **Control Panel** (bottom left)
2. Select **Shared Folder**
3. Click **Create**

**Share Settings:**
- **Name:** `kohd-kai`
- **Location:** Select `/volume1` (or whichever volume you want to use)
- **Description:** "Kai Orchestration - Planning, Linear Management"
- **Enable Recycle Bin:** ✓ (optional, for safety)
- **Hide This Shared Folder In "My Places":** ☐ (leave unchecked - we want it visible)

4. Click **Next**

**Advanced Settings (if prompted):**
- **Encrypt:** ☐ (leave unchecked for now)
- **Enable file compression:** ☐ (optional)

5. Click **Next**

**Permissions:**
- Click **Add** under "Permissions"
- Select user: `admin` (or your primary user)
- Permission: **Read/Write**
- Apply Recursive: ☑ (check this)

6. Click **Done**

✅ **Kohd-Kai share created!**

---

## **Step 3: Create Second Share - "Kohd-Hub1"**

Repeat the same process:

1. **Control Panel** → **Shared Folder** → **Create**

**Share Settings:**
- **Name:** `kohd-hub1`
- **Location:** `/volume1`
- **Description:** "Hub1 Workshop - Team Collaboration, Shared Assets"
- **Enable Recycle Bin:** ✓
- **Hide This Shared Folder:** ☐

2. **Next** → (skip Advanced if not needed) → **Next**

**Permissions:**
- Add `admin` user (or your primary account)
- Permission: **Read/Write**
- Apply Recursive: ☑

3. **Done**

✅ **Kohd-Hub1 share created!**

---

## **Step 4: Verify in File Station**

1. Open **File Station** (main menu, top left)
2. Left sidebar should now show:
   - kohd-kai
   - kohd-hub1

3. Click on **kohd-kai** → verify you can:
   - See empty folder
   - Create a new file (test-file.txt)
   - Delete it
   - If you can do this, permissions are correct ✅

4. Repeat for **kohd-hub1**

---

## **Step 5: Verify SMB Access from Your Machine**

### **Windows:**
1. Open File Explorer
2. Type in address bar: `\\192.168.1.142\kohd-kai`
3. Press Enter
4. When prompted, log in with Synology username/password
5. Verify you can see the shared folder
6. Try creating a test file: `test-kai.txt`
7. Verify file appears in File Station on NAS

### **macOS:**
1. Open Finder
2. Press **Cmd+K** (Go → Connect to Server)
3. Type: `smb://192.168.1.142/kohd-kai`
4. Click **Connect**
5. Enter Synology username/password
6. Verify access

### **Linux:**
```bash
smbclient -L \\192.168.1.142 -U your_username
# Should list kohd-kai and kohd-hub1
```

---

## **Step 6: Create Subdirectories (Optional but Recommended)**

From File Station on the NAS:

1. Click **kohd-kai**
2. Right-click → **New** → **Folder**
3. Create these folders:
   - `active`
   - `archive`
   - `inbox`
   - `tmp`

4. Repeat for **kohd-hub1**

---

## **Step 7: Set Up User Permissions (Important for SMB Access)**

If you want specific users to access these shares:

1. **Control Panel** → **Shared Folder**
2. Select **kohd-kai**
3. Click **Edit**
4. Go to **Permissions** tab
5. Add users as needed:
   - `neil` — Read/Write
   - `admin` — Read/Write
   - Or create a dedicated user like `kohd-manager`

6. Click **OK**

---

## **Troubleshooting**

### **Problem: SMB shares not visible in File Station**

**Check:**
1. Are you logged into DSM with an admin account?
2. Are shares actually created? (Control Panel → Shared Folder → should list kohd-kai, kohd-hub1)
3. Try refreshing File Station (F5)

**Fix:**
- Log out of DSM and log back in
- Restart DSM service: Control Panel → Services → SMB → restart

### **Problem: Can't authenticate over SMB from Windows/Mac**

**Check:**
1. Is SMB service enabled? (Control Panel → Services → SMB → toggle on)
2. Are network ports open? (445, 139)
3. Are you using correct username/password?

**Fix:**
- Try connecting with `admin` account (guaranteed to exist)
- If connecting from different subnet, may need to configure firewall
- On Windows, try: `\\192.168.1.142\kohd-kai` (IP instead of hostname)

### **Problem: Permission denied writing to share**

**Check:**
1. In Control Panel → Shared Folder → select share → Permissions
2. Does your user have **Read/Write** permission?
3. Is "Apply Recursive" checked?

**Fix:**
- Add your user with Read/Write permission
- Check "Apply Recursive" 
- Wait 30 seconds for permissions to apply
- Try again

---

## **What Should Happen After Setup**

```
Synology NAS DSM (Physical)
├── File Station
│   ├── kohd-kai/          ← Visible here
│   │   ├── active/
│   │   ├── archive/
│   │   ├── inbox/
│   │   └── tmp/
│   └── kohd-hub1/         ← Visible here
│       ├── active/
│       ├── archive/
│       ├── inbox/
│       └── tmp/
│
├── SMB Service
│   ├── \kohd-kai          ← Accessible via network
│   └── \kohd-hub1         ← Accessible via network
│
└── Control Panel
    ├── Shared Folder
    │   ├── kohd-kai      ← Listed
    │   └── kohd-hub1     ← Listed
    │
    └── Services → SMB    ← Enabled
```

---

## **Next: Once Shares Are Created**

Once you verify:
1. ✅ Shares visible in File Station
2. ✅ Can create/delete files in File Station
3. ✅ Can access via SMB from Windows/Mac (\\192.168.1.142\kohd-kai)
4. ✅ Can read/write files via network

**Then we can:**
- Copy our Docker containers to run on the NAS
- Mount the shares inside Docker
- Start SMB Manager agent
- Test the full inbox workflow

---

## **Commands Reference**

### From Synology NAS Command Line (if needed)

```bash
# Check if SMB is running
synoservice --status smbd

# Restart SMB
synoservice --restart smbd

# List current shares
cat /etc/samba/smb.conf | grep "^\["

# Check share permissions
cat /etc/samba/user_shares/kohd-kai
```

---

## **Files Created on NAS**

Once you create the shares, Synology automatically creates:

```
/volume1/kohd-kai/          (actual folder)
/volume1/kohd-hub1/         (actual folder)
/etc/samba/user_shares/kohd-kai       (config)
/etc/samba/user_shares/kohd-hub1      (config)
```

These are where SMB will serve files from.

---

## Status Check

**Before DSM Setup:**
- ✗ Shares not visible in File Station
- ✗ Can't access via SMB
- ✗ Permissions not configured

**After DSM Setup (This Step):**
- ✅ Shares visible in File Station
- ✅ Accessible via SMB (\\192.168.1.142\kohd-kai)
- ✅ Can read/write files
- ✅ Docker containers can mount them

**Then (Next Steps):**
- Deploy Docker containers
- Mount shares inside Docker
- Start SMB Manager agent
- Test file drop workflow
