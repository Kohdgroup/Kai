# Hermes Image Routing Decision Table

This table defines how Hermes chooses the render node and output path.

## Decision table
| Asset type | Primary node | Secondary node | Engine | Output |
|---|---|---|---|---|
| Worker headshot | Windows PC | Mac mini | ComfyUI | WebDAV finals |
| Advisory headshot | Windows PC | Mac mini | ComfyUI | WebDAV finals |
| Social campaign image | Windows PC | Mac mini | ComfyUI | WebDAV finals |
| Social campaign draft | Mac mini | Windows PC | ComfyUI | WebDAV drafts |
| Fast one-off draft | Mac mini | Windows PC | Hermes FAL | WebDAV drafts |
| High-risk/public approval asset | Windows PC | Mac mini | ComfyUI | WebDAV drafts, then human approval |

## Routing rules
1. Prefer Windows PC for realism-critical jobs.
2. Prefer Mac mini for lightweight drafts or when Windows is busy.
3. If both are available, queue the primary node first and the secondary as fallback.
4. If the job is high-risk, require approval before promotion to finals.
5. Every successful run must write provenance back to Linear.
