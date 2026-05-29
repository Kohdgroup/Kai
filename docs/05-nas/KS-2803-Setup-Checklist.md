# KS-2803 Synology Shared Folder Setup - Quick Checklist

## 🎯 Your Task (5-10 minutes)

You need to create two Synology shared folders via the web UI. These are **not** the Linux folders we created earlier - they need to be created through Synology DSM so they:
- Appear in File Station (the Synology file browser)
- Are accessible via SMB (\\192.168.1.142\kohd-kai)
- Have proper user permissions
- Are discoverable by Docker/Hermes

---

## ✅ Checklist

### **Step 1: Open Synology DSM**
- [ ] Open browser: http://192.168.1.142:5000
- [ ] Login with admin credentials
- [ ] You should see DSM desktop

### **Step 2: Create "kohd-kai" Share**
- [ ] Click **Control Panel** (bottom left of screen)
- [ ] Click **Shared Folder**
- [ ] Click **Create** button
- [ ] Fill in:
  - **Name:** `kohd-kai` (exactly this, lowercase)
  - **Location:** `/volume1`
  - **Description:** "Kai Orchestration"
  - **Recycle Bin:** Check the box
  - **Hide in My Places:** Leave unchecked
- [ ] Click **Next**
- [ ] (Skip Advanced settings) Click **Next**
- [ ] **Permissions:**
  - [ ] Click **Add**
  - [ ] Select user: `admin`
  - [ ] Permission: `Read/Write`
  - [ ] Check "Apply Recursive"
  - [ ] Click **OK**
- [ ] Click **Done**
- [ ] **Verification:** Go to **File Station** → should see `kohd-kai` in sidebar

### **Step 3: Create "kohd-hub1" Share**
- [ ] Click **Control Panel** → **Shared Folder** → **Create**
- [ ] Fill in:
  - **Name:** `kohd-hub1` (exactly this, lowercase)
  - **Location:** `/volume1`
  - **Description:** "Hub1 Workshop"
  - **Recycle Bin:** Check the box
- [ ] Click **Next**
- [ ] Click **Next** (skip Advanced)
- [ ] **Permissions:**
  - [ ] Click **Add**
  - [ ] Select user: `admin`
  - [ ] Permission: `Read/Write`
  - [ ] Check "Apply Recursive"
  - [ ] Click **OK**
- [ ] Click **Done**
- [ ] **Verification:** Go to **File Station** → should see `kohd-hub1` in sidebar

### **Step 4: Test File Station Access**
- [ ] Open **File Station** (from DSM main menu)
- [ ] Left sidebar shows both:
  - [ ] `kohd-kai`
  - [ ] `kohd-hub1`
- [ ] Click **kohd-kai**
  - [ ] Create new file: right-click → **New** → **File** → name it `test.txt`
  - [ ] Verify file appears
  - [ ] Delete it
- [ ] Click **kohd-hub1**
  - [ ] Create new file: `test.txt`
  - [ ] Verify file appears
  - [ ] Delete it

### **Step 5: Test SMB Access from Your Windows Machine**
- [ ] Open **File Explorer** on your Windows PC
- [ ] Type in address bar: `\\192.168.1.142\kohd-kai`
- [ ] Press Enter
- [ ] When prompted for credentials:
  - [ ] Username: `admin` (or your DSM username)
  - [ ] Password: your DSM password
  - [ ] Check "Remember my credentials"
- [ ] Verify you see the empty folder
- [ ] Create a test file: `windows-test.txt`
- [ ] Verify it appears
- [ ] Repeat for `\\192.168.1.142\kohd-hub1`

### **Step 6: Verify SMB from macOS (if applicable)**
- [ ] Open **Finder**
- [ ] Press **Cmd+K** (or Go → Connect to Server)
- [ ] Type: `smb://192.168.1.142/kohd-kai`
- [ ] Click **Connect**
- [ ] Authenticate with admin credentials
- [ ] Verify access

### **Step 7: (Optional) Create Subdirectories**
For better organization, create these folders inside each share:

**In kohd-kai:**
- [ ] active
- [ ] archive
- [ ] inbox
- [ ] tmp

**In kohd-hub1:**
- [ ] active
- [ ] archive
- [ ] inbox
- [ ] tmp

---

## 🆘 If Something Doesn't Work

### **Shares don't appear in File Station**
- [ ] Are you logged in as `admin`?
- [ ] Did you click **Done** after creating the share?
- [ ] Try refreshing: Press F5
- [ ] Log out of DSM and log back in

### **Can't connect via SMB (\\192.168.1.142\kohd-kai)**
- [ ] Check SMB service is enabled:
  - [ ] Control Panel → **Services** → **SMB**
  - [ ] Make sure toggle is **ON**
- [ ] Try using IP address instead of hostname
- [ ] Check Windows Firewall isn't blocking port 445
- [ ] On Windows, try: `net use \\192.168.1.142\kohd-kai /user:admin`

### **Permission Denied when writing**
- [ ] Control Panel → **Shared Folder** → select share
- [ ] Click **Edit** → **Permissions**
- [ ] Verify your user has **Read/Write** permission
- [ ] Check "Apply Recursive" checkbox
- [ ] Click OK
- [ ] Wait 30 seconds and try again

---

## 📝 Summary

| Item | Status |
|------|--------|
| kohd-kai share created in DSM | ☐ |
| kohd-hub1 share created in DSM | ☐ |
| Both visible in File Station | ☐ |
| Can access via SMB from Windows | ☐ |
| Can read/write files | ☐ |
| User permissions configured | ☐ |

---

## 🎬 What Happens Next

Once all checkboxes are ✅ and you can:
1. See shares in File Station
2. Access via SMB (\\192.168.1.142\kohd-kai)
3. Create/delete files
4. Authenticate with username/password

**Then we can:**
- Copy Docker containers to run on NAS
- Mount the real Synology shares inside Docker
- Start the SMB Inbox Manager
- Test file drops and auto-processing

---

**Let me know once you've completed these steps!**
