# KOHD NAS Network Configuration

## Overview

The KOHD NAS is configured to expose SMB shares on the **internal local network interface (eth0)**. This allows team members and systems on the same subnet to access NAS volumes without external network exposure.

## Network Interface Configuration

**Primary Interface:** eth0  
**MAC Address:** 02:42:ac:1c:00:04  
**Function:** Internal network communication (SMB, CIFS, file sharing)  
**Binding:** SMB service bound to eth0 + localhost (127.0.0.1)  

## SMB Network Details

| Property | Value |
|----------|-------|
| **NetBIOS Hostname** | KOHD-NAS |
| **Workgroup** | KOHD |
| **SMB Ports** | 445 (SMB3), 139 (NetBIOS) |
| **Network Scope** | Local internal subnet (eth0) |
| **Guest Access** | Enabled (no password required) |
| **Interface Binding** | eth0, 127.0.0.1 only |

## Access from Internal Network

### Windows
```
\\KOHD-NAS\kohd-group
```
Or navigate via "Browse Network" → KOHD-NAS → kohd-group

### macOS
```
smb://KOHD-NAS/kohd-group
```
Finder → Go → Connect to Server → Enter above address

### Linux
```bash
# Guest mount
sudo mount -t cifs //KOHD-NAS/kohd-group /mnt/kohd-group

# Or using IP
sudo mount -t cifs //192.168.x.x/kohd-group /mnt/kohd-group
```

## Shares Available

All shares are accessible on the **same subnet as eth0**:

1. **kohd-ecopuk** → `/app/data/hermes/volumes/ecopuk`
   - EcoPUK ecosystem backup
   - Read/Write
   
2. **kohd-group** → `/app/data/hermes/volumes/kohd`
   - KOHD primary platform data
   - Team collaboration
   - Read/Write
   
3. **kohd-shared** → `/app/data/hermes/volumes/shared`
   - Shared assets and templates
   - Cross-project access
   - Read/Write
   
4. **kohd-hermes-inbox** → `/app/data/hermes/volumes/kohd/inbox`
   - File drop-off point for processing
   - Monitored by NAS inventory agent
   - Read/Write

## Network Topology

```
Internal Network (Subnet with eth0)
    │
    ├─ Windows PC    → \\KOHD-NAS\kohd-group (port 445, 139)
    ├─ macOS         → smb://KOHD-NAS/kohd-group
    ├─ Linux Server  → mount -t cifs //KOHD-NAS/...
    │
    └─ KOHD NAS (eth0: SMB service listening)
            │
            └─ Samba/SMB (bound to eth0)
                    │
                    ├─ kohd-ecopuk (7.9TB pool)
                    ├─ kohd-group  (same 7.9TB pool)
                    ├─ kohd-shared (same 7.9TB pool)
                    └─ kohd-hermes-inbox (subdirectory of kohd)
```

## External Network Isolation

**The SMB service is NOT accessible from external networks:**
- eth0 interface binding only (local subnet)
- No port forwarding to external IP
- Firewall rules prevent external access (if configured)
- This is intentional for security

If external access is needed in future, a separate VPN or jump-server would be required.

## Discovering the NAS on Network

### Method 1: NetBIOS Name (Windows/macOS with Bonjour)
```
KOHD-NAS
```

### Method 2: IP Address
Get NAS IP from internal DHCP or static assignment:
```
192.168.x.x  (replace x with actual subnet)
```

### Method 3: SMB Browse (Windows "My Network Places")
Browse network → KOHD workgroup → KOHD-NAS

### Method 4: From NAS Terminal
```bash
# Get eth0 IP
cat /proc/net/dev | grep eth0
# Or check system logs
tail -f /var/log/samba/log.smbd
```

## Configuration Files

**SMB Configuration:**
- `/opt/data/smb-kohd.conf` — Master SMB configuration
- `/etc/samba/smb.conf` — Installed version (after setup script)

**Key Settings in Config:**
```
bind interfaces only = yes
interfaces = eth0 127.0.0.1
smb ports = 445 139
```

## Performance on Internal Network

- **Latency:** < 5ms (local network)
- **Throughput:** 50-1000 MB/s (depending on hardware)
- **Concurrent Users:** 10+ simultaneous connections
- **Caching:** Client-side caching supported

## Security Notes

**Current MVP Configuration:**
- Guest access enabled (no authentication)
- All users can read/write
- No encryption required
- Open access on local network

**Production Hardening (Future):**
- Enable SMB encryption
- Implement per-user authentication
- Set read-only policies on archives
- Enable SMB signing
- Add audit logging
- Restrict by IP/VLAN
- Use Kerberos for enterprise integration

## Troubleshooting

**Can't find KOHD-NAS:**
1. Ensure your machine is on same subnet as eth0
2. Try IP address directly instead of hostname
3. Check firewall rules on NAS or client

**Connection refused on port 445:**
1. Verify SMB service is running: `systemctl status smbd`
2. Check eth0 is active: `/sys/class/net/eth0/`
3. Review logs: `/var/log/samba/log.smbd`

**Shares visible but can't mount:**
1. Try with explicit guest credentials: `username=guest,password=`
2. Check file permissions: `ls -la /app/data/hermes/volumes/`
3. Review SMB logs for errors

**Slow transfers:**
1. Check network bandwidth: `iftop` or `nethogs`
2. Verify no competing traffic on eth0
3. Check SMB log level (current: 2, can increase to debug)

## Integration with Hermes

The NAS inventory agent (KS-2794) monitors shares every 30 minutes and creates reports. SMB provides the network access layer that enables:
- File drops from network clients
- Team collaboration on shared data
- Multi-agent workflows (files in inbox, processed by agents)

## Next Steps

1. Run setup script: `sudo bash /opt/data/setup-smb-shares.sh`
2. Test from internal network client: `\\KOHD-NAS\kohd-group`
3. Verify shares appear in inventory: `/app/data/hermes/reports/nas-inventory.json`
4. Monitor access logs: `tail -f /var/log/samba/log.smbd`
