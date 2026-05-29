# Autonomous Image Pipeline and WebDAV Sink

## Source of truth
- Linear image generation workstream
- ComfyUI on the local Windows node as the primary engine when the priority is low cost
- Hermes built-in FAL as fast-path / overflow fallback

## Storage layout
- `webdav://kohd-assets/headshots/drafts/`
- `webdav://kohd-assets/headshots/finals/`
- `webdav://kohd-assets/campaigns/drafts/`
- `webdav://kohd-assets/campaigns/finals/`
- `webdav://kohd-assets/archive/`

## Required automation
1. Generate image
2. Store draft automatically
3. Run QA/vision review
4. Approve or regenerate
5. Promote final asset
6. Write Linear link / provenance
7. Notify stakeholders if needed

## Operating principle
No manual file handling once the workflow is established.
