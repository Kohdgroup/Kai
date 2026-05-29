# KOHD AI Routing & Automation

Project: https://linear.app/kohd/project/kohd-ai-routing-and-automation-ec744fd873ae
Initiative: 52301789a7d3
Owner: Zoe Parker

Milestones:
- Model Inventory & Capability Map — 8 SP — 45k tokens — £480 / $600
- Skill-to-Model Routing Matrix — 13 SP — 80k tokens — £920 / $1,150
- Modality Routing for Image/Web/Video/Audio — 8 SP — 50k tokens — £640 / $800
- Weekly Learning Loop Automation — 5 SP — 25k tokens — £400 / $500
- Documentation & Linear View Operations — 3 SP — 12k tokens — £240 / $300

Routing policy:
- Premium reasoning: gpt-5.4-mini, gpt-5-mini, claude-sonnet-4
- Cheap-fast text: gpt-5.4-nano, claude-haiku-4-5, gpt-4o-mini
- Image: comfyui, stable-diffusion, flux
- Web: claude-design, pretext, design-md
- Video: video_gen, manim-video
- Audio: tts, audiocraft-audio-generation

Linear view fields:
- project, initiative, owner, skill_family, worker, primary_model, fallback_model, modality, story_points, token_estimate, human_cost_gbp, human_cost_usd, last_reviewed, confidence, automation_candidate
