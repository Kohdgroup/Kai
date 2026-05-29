# WebDAV Folder and Metadata Schema

This schema is the import-ready standard for KOHD image outputs.

## Folder structure
- `webdav://kohd-assets/images/headshots/drafts/`
- `webdav://kohd-assets/images/headshots/finals/`
- `webdav://kohd-assets/images/headshots/rejected/`
- `webdav://kohd-assets/images/campaigns/drafts/`
- `webdav://kohd-assets/images/campaigns/finals/`
- `webdav://kohd-assets/images/campaigns/rejected/`
- `webdav://kohd-assets/images/archive/`

## Filename pattern
`YYYYMMDD_<category>_<subject>_<style>_<version>_<shortid>.png`

Example:
- `20260529_headshot_zoe-parker_founder-friendly_v1_a1b2c3.png`

## Sidecar JSON schema
```json
{
  "id": "a1b2c3",
  "created_at": "2026-05-29T12:00:00Z",
  "category": "headshot",
  "subject": "zoe-parker",
  "style": "founder-friendly",
  "version": "v1",
  "source_issue": "KS-2818",
  "engine": "ComfyUI",
  "runtime": "Comfy Cloud",
  "node": "windows-pc-01",
  "prompt": "...",
  "model": "<model-id>",
  "aspect_ratio": "square",
  "qa_status": "pass",
  "approval_status": "auto-approved",
  "output_path": "webdav://kohd-assets/images/headshots/finals/...png"
}
```

## Rules
- drafts and finals are always separate
- rejected items never overwrite finals
- every final must have a sidecar JSON file
- every final must carry source Linear provenance
