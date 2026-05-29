# Image Generation Workflow

Source of truth: KS image generation issue in Linear.

## Recommended engine
Use ComfyUI on a dedicated Windows PC as the primary image engine when cost is the priority and processing time is not. Use Hermes built-in image generation via FAL.ai as the fallback / fast-prototyping path.

### Model routing
- Photorealistic people / headshots: ComfyUI portrait workflow on Windows PC
- Campaign images with text/layout: ComfyUI production workflow
- Brand / production design assets: ComfyUI design workflow
- Typography-heavy social cards: FAL/Herme built-in path or a dedicated ComfyUI typography workflow
- Fast draft variations: Hermes built-in `fal-ai/flux-2/klein/9b`

## Standard workflow
1. Brief
2. Prompt
3. Model choice
4. Generate 2–3 candidates
5. Vision QA
6. Select final
7. Save to WebDAV/shared storage
8. Link back to Linear

## Default style
Modern startup / founder-friendly / Silicon Valley feel
- photorealistic
- neutral background
- soft natural light
- relaxed confidence
- business attire matched to role
