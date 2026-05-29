# Image Generation Workflow

Source of truth: KS image generation issue in Linear.

## Recommended engine
Use Hermes built-in image generation via FAL.ai.

### Model routing
- Photorealistic people / headshots: `fal-ai/flux-2-pro`
- Campaign images with text/layout: `fal-ai/gpt-image-2`
- Brand / production design assets: `fal-ai/recraft/v4/pro/text-to-image`
- Typography-heavy social cards: `fal-ai/ideogram/v3`
- Fast draft variations: `fal-ai/flux-2/klein/9b`

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
