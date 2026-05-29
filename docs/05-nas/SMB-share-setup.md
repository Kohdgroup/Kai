# SMB Share Configuration for KOHD NAS

## Overview

This document describes the SMB (Server Message Block) share setup that exposes KOHD NAS volumes to network file transfer. Users can drag-and-drop files from their machines (Windows, macOS, Linux) into the NAS volumes via SMB protocol.

## Configured Shares

| Share Name | Path | Purpose | Access |
|-----------|------|---------|--------|
| `kohd-ecopuk` | `/app/data/hermes/volumes/ecopuk` | EcoPUK ecosystem backup & archives | Read/Write |
| `kohd-group` | `/app/data/hermes/volumes/kohd` | KOHD team collaboration & platform data | Read/Write |
| `kohd-shared` | `/app/data/hermes/volumes/shared` | Shared assets, templates, knowledge | Read/Write |
| `kohd-hermes-inbox` | `/app/data/hermes/volumes/kohd/inbox` | Hermes file drop point for processing | Drop-off |

## Connection Details

The SMB shares are accessible on the **internal NAS network interface (eth0)** on ports 139 and 445.

### From Windows (Internal Network)
```
\\KOHD-NAS\kohd-group
```
Or use the NAS IP address directly:
```
\\192.168.x.x\kohd-group
```

### From macOS (Internal Network)
```
smb://KOHD-NAS/kohd-group
```
Or via IP:
```
smb://192.168.x.x/kohd-group
```

### From Linux (Internal Network)
```bash
# Mount with guest access (no password)
mount -t cifs -o username=guest //KOHD-NAS/kohd-group /mnt/kohd-group

# Or with explicit guest credentials
mount -t cifs -o username=nobody,password= //KOHD-NAS/kohd-group /mnt/kohd-group

# Or using IP address
mount -t cifs //192.168.x.x/kohd-group /mnt/kohd-group
```

## Network Configuration

**NAS Network Interface:** eth0  
**SMB Ports:** 445 (SMB3), 139 (NetBIOS)  
**Network Scope:** Local internal network (subnet accessible to eth0)  
**Hostname:** KOHD-NAS (NetBIOS name)  
**Workgroup:** KOHD  

The SMB service is bound **only** to the local NAS interface (eth0) and 127.0.0.1 (localhost). This ensures:
- Internal network clients can connect
- Shares are accessible on the same subnet as the NAS
- No exposure to external networks

## Workflow Example: Drop File into Inbox

1. User opens file manager on their machine
2. Navigates to `\\nas.local\kohd-hermes-inbox` (or `smb://nas.local/kohd-hermes-inbox`)
3. Drops a file (e.g., `my-skill.md`)
4. NAS inventory agent (KS-2794, running every 30 min) discovers the file
5. Skills detector (KS-2795) evaluates it:
   - If it's a SKILL.md → Auto-creates worker
   - If it's a config → Auto-loads it
   - Otherwise → File tracked in inventory
6. File can be moved to `/kohd/active/` or `/kohd/archive/` by agents
7. User later retrieves processed result from same share

## Setup Instructions

### Automatic Setup (Recommended)

```bash
sudo bash /opt/data/setup-smb-shares.sh
```

This script:
- Installs Samba if needed
- Copies SMB configuration
- Creates user groups
- Sets correct permissions
- Restarts SMB service
- Verifies shares are advertised

### Manual Setup

If automatic setup fails:

1. **Copy configuration:**
   ```bash
   sudo cp /opt/data/smb-kohd.conf /etc/samba/smb-kohd.conf
   ```

2. **Verify syntax:**
   ```bash
   sudo testparm /etc/samba/smb-kohd.conf
   ```

3. **Create groups:**
   ```bash
   sudo groupadd kohd
   ```

4. **Set permissions:**
   ```bash
   sudo chmod 755 /app/data/hermes/volumes/*
   sudo chgrp kohd /app/data/hermes/volumes/*
   ```

5. **Restart Samba:**
   ```bash
   sudo systemctl restart smbd nmbd
   ```

6. **Verify:**
   ```bash
   smbclient -L localhost -N
   ```

## Security Considerations

**Current Setup:**
- Guest access enabled (anonymous login allowed)
- All shares readable and writable by default
- No per-user authentication required for this MVP

**Production Hardening (Future):**
- Enable per-user authentication (SMB user accounts)
- Set read-only policies on archive volumes
- Enable SMB signing and encryption
- Implement audit logging per share
- Restrict access by IP/VLAN

## Troubleshooting

### Can't see shares in file manager
- Ping `nas.local` to verify connectivity
- Try IP address directly: `\\192.168.x.x\kohd-group` (replace with NAS IP)
- Restart SMB service: `sudo systemctl restart smbd`

### "Access Denied" when connecting
- Check SMB service is running: `systemctl status smbd`
- Verify permissions on volume: `ls -la /app/data/hermes/volumes/`
- Try as different user (may have user-level restrictions)

### Files disappear after upload
- They're likely being moved by the NAS inventory agent
- Check `/app/data/hermes/reports/nas-inventory.json` for file tracking
- Check `/app/data/hermes/volumes/kohd/active/` and `/archive/`

### Slow file transfers
- Check network bandwidth (`iftop` or `nethogs`)
- SMB performance is network-limited; local copies are faster
- Consider using rsync/scp for large files

### SMB service won't start
- Check logs: `tail -f /var/log/samba/log.smbd`
- Verify config: `testparm /etc/samba/smb.conf`
- Ensure ports 137-139, 445 are not in use: `netstat -tulpn | grep samba`

## Integration with Hermes

The NAS inventory agent (KS-2794) monitors shares and updates `/app/data/hermes/reports/nas-inventory.json` every 30 minutes. This JSON report includes:
- File counts per share
- File sizes
- Last modified timestamps
- File hashes (for change detection)

The skills detector (KS-2795) watches the inbox for new SKILL.md files and auto-creates workers.

## Performance Notes

- **Latency:** Network-bound (typically 10-100ms per operation)
- **Throughput:** Depends on network (typically 50-500 MB/s for SMB)
- **Concurrency:** Multiple users can access simultaneously
- **Caching:** Clients cache; refresh may take a few seconds

## Next Steps

1. Run setup script: `sudo bash /opt/data/setup-smb-shares.sh`
2. Test connection from your machine
3. Drop a file into inbox and verify it appears in NAS inventory report
4. Monitor `/app/data/hermes/reports/nas-inventory.json` for updates
