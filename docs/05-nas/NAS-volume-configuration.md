# NAS Volume Configuration - KOHD

## Current Storage Setup

**Physical Devices:**
- 4 × 2.7TB drives (sda, sdb, sdc, sdd)
- Total raw capacity: ~10.8TB

**RAID Configuration:**
- md0 (RAID1): Boot/system partition - 4GB
- md1 (RAID1): Swap - 2GB  
- md2 (RAID5): Data volume - 8.7TB (3 drives + 1 parity)

**Active Volume:**
- `/dev/mapper/cachedev_0` (Btrfs on md2)
- 7.9TB total capacity
- 1.5TB currently used (18%)
- 6.5TB available
- Mounted at: `/` (root) and `/app/data` (symlink)

## Managed Volumes

All three KOHD volumes (ecopuk, kohd, shared) are **on a single btrfs filesystem** mounted at `/app/data/hermes/volumes/`:

```
/app/data/hermes/volumes/
├── ecopuk/
│   ├── inbox/
│   ├── active/
│   ├── archive/
│   ├── tmp/
│   ├── manifests/
│   └── reports/
├── kohd/
│   ├── inbox/
│   ├── active/
│   ├── archive/
│   ├── tmp/
│   ├── manifests/
│   └── reports/
└── shared/
    ├── inbox/
    ├── active/
    ├── archive/
    ├── tmp/
    ├── manifests/
    └── reports/
```

## Storage Pool Architecture

**Pool:** `md2` (RAID5 across 3 drives + 1 parity)
**Filesystem:** Btrfs (Copy-on-Write, snapshots, compression)
**Total Capacity:** 7.9TB
**Available:** 6.5TB (81% free)
**Status:** Healthy (RAID5 [UUUU] all drives up)

## Volume Management Strategy

Since all volumes are on one Btrfs filesystem, the NAS inventory agent monitors them as:

1. **Single pool monitoring** — tracks total utilization
2. **Per-volume quotas** — can be implemented via Btrfs subvolume quotas
3. **Unified lifecycle policies** — archival, retention, cleanup
4. **Shared snapshot strategy** — can snapshot across volumes or per-volume

## Future Expansion Path

Current setup supports up to **9 bays** (4 currently used):
- Add up to 5 more 2.7TB+ drives to md2 RAID5
- Current RAID5 will rebalance automatically
- Capacity will expand proportionally
- Btrfs handles growth transparently

## Key Facts

| Property | Value |
|----------|-------|
| Active Volume Pool | md2 (RAID5) |
| Filesystem | Btrfs |
| Root Mount | / and /app/data |
| Total Capacity | 7.9TB |
| Used | 1.5TB (18%) |
| Available | 6.5TB (82%) |
| RAID Status | All drives healthy [UUUU] |
| Managed Volumes | 3 (ecopuk, kohd, shared) |
| Volume Structure | Single Btrfs filesystem |

## Monitoring Strategy

The NAS inventory agent (`KS-2794`) monitors:
- Single unified pool (md2/cachedev_0)
- Three logical volumes (folder-based)
- Per-folder utilization (inbox, active, archive)
- File counts and sizes
- Policy compliance per volume

All data is on **one RAID5 pool** with 6.5TB free, fully managed by the monitoring agent.
