# Image Node + Routing + WebDAV Specification

This page defines the recommended KOHD image-production setup for both a primary Windows PC render node and a secondary Mac mini node, plus the autonomous routing and WebDAV delivery rules.

## 1) Windows PC recommendation

Primary role: dedicated production render node.

Recommended spec:
- CPU: modern 8+ core Intel or AMD CPU
- GPU: NVIDIA RTX 4080 / 4090 class preferred
- VRAM: 16 GB preferred, 12 GB minimum
- RAM: 64 GB recommended, 32 GB minimum
- Storage: 2 TB NVMe SSD minimum, 4 TB preferred if you expect large model libraries
- OS: Windows 11 Pro
- Network: wired gigabit or better

Why this is the best primary node:
- best ComfyUI compatibility
- best batch throughput
- best realism and stability for headshots and campaign assets
- easiest path for a dedicated always-on render box

Recommended use:
- photorealistic worker portraits
- campaign assets
- multi-variant batch generation
- heavier workflows and upscaling

## 2) Mac mini recommendation

Secondary role: backup, lighter production, and utility node.

Recommended spec:
- Apple Silicon only
- M4 Pro / M3 Pro / M2 Pro preferred
- Unified memory: 32 GB preferred, 16 GB minimum
- Storage: 1 TB preferred
- OS: macOS latest stable

Why this is useful:
- low-power always-on box
- good secondary render / fallback node
- useful for lightweight jobs, previews, and queue overflow
- a clean backup if the Windows node is down or busy

Recommended use:
- lower-throughput creative jobs
- previews and drafts
- fallback queue processing
- admin/orchestration helpers

## 3) Hermes routing logic

Hermes should own routing. Humans should not be in the loop for ordinary jobs.

Routing rules:
1. Classify the asset request.
2. Choose the primary node.
3. Send the job automatically.
4. Monitor generation.
5. Run QA checks.
6. Publish to WebDAV if the checks pass.
7. Escalate only when the workflow fails repeatedly or the content is high-risk.

Default routing:
- Worker/advisory headshots → Windows PC first, Mac mini second
- Social media campaign images → Windows PC first, Mac mini second
- Lightweight drafts / previews → Mac mini may be used first if the Windows node is busy
- Heavier batch work / realism-critical work → Windows PC first

Fallback logic:
- If Windows node is offline, queue to Mac mini
- If Mac mini is busy, queue to Windows node
- If both are unavailable, fail over to the cloud fallback path or alert the operator

Autonomy rule:
- routine jobs should run end-to-end without manual file handling
- humans only intervene on policy exceptions, repeated failure, or high-risk content

## 4) WebDAV naming and approval rules

Goal: all generated assets should land in a managed WebDAV/shared-storage structure with provenance and clear separation between drafts and finals.

Recommended folder structure:
- `webdav://kohd-assets/images/headshots/drafts/`
- `webdav://kohd-assets/images/headshots/finals/`
- `webdav://kohd-assets/images/campaigns/drafts/`
- `webdav://kohd-assets/images/campaigns/finals/`
- `webdav://kohd-assets/images/archive/`
- `webdav://kohd-assets/images/rejected/`

Naming convention:
- `YYYYMMDD_<category>_<subject>_<style>_<version>_<shortid>.png`
- Examples:
  - `20260529_headshot_zoe-parker_founder-friendly_v1_a1b2c3.png`
  - `20260529_campaign_launch_silicon-valley_v2_d4e5f6.png`

Sidecar metadata file (recommended):
- same basename, `.json`
- include:
  - source Linear issue
  - prompt
  - model / workflow used
  - node used
  - generation timestamp
  - QA result
  - approval state
  - final/publication status

Approval model:
- Drafts are always auto-saved
- QA runs automatically on every candidate
- If the asset passes policy and quality checks, it is promoted to finals automatically
- Human approval is only required for high-risk or ambiguous content

High-risk content includes:
- public-facing content with legal/compliance sensitivity
- sensitive people/brand/legal issues
- anything with children, medical, financial, or regulated claims
- anything the policy engine flags as unsafe

Promotion rule:
- Draft → QA pass → Final
- Draft → QA fail → regenerate or reject
- Draft → high-risk flag → human review

## Operational principle
No manual file handling for normal runs.
The workflow should generate, validate, save, and reference assets automatically.
