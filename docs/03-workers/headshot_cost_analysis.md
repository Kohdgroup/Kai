# Headshot Cost Analysis

Count analyzed: 18 profiles
Working assumption: 3 candidate renders per person (54 total renders)

## 1) API image generation (illustrative)
- Low scenario: $0.03/render → $1.62 total
- Mid scenario: $0.05/render → $2.70 total
- High scenario: $0.10/render → $5.40 total

## 2) Self-hosted / ComfyUI on GPU
Assuming cloud GPU cost of $3.00/hour:
- 10 sec/render → $0.45
- 20 sec/render → $0.90
- 30 sec/render → $1.35

## 3) Traditional photography benchmark
- $1,350 to $3,600 for 18 people

## Key observation
The direct generation cost is usually tiny compared with review/selection time and workflow setup.
The biggest cost driver is not the pixels; it is iteration, curation, and maintaining a consistent style.

## Recommendation
- Use a reusable AI workflow for the portraits.
- Generate 2–3 candidates per person.
- Pick one final image per person.
- Store the final outputs in WebDAV / shared storage.
- Keep the style prompt and selection rules versioned in docs.
