# KOHD Sprint Template

Generated: 2026-05-29T13:01:04.789985+00:00

Rules:
- Assign only to open current-sprint issues when the cycle exists.
- Every issue must include business requirements, acceptance criteria, technical requirements, definition of done, Agile points, labour breakdown, estimated tokens & cost, milestones, dependencies, and implementation notes.
- Use Milestone 1 as the discovery/dependency-mapping sprint slice.
- All estimates below are planning estimates and must be recalibrated once the cycle is live.

# EcoPUK — Sprint Template (Milestone 1)

Project: CD__ecopuk
Scope: discovery, dependency mapping, and first executable sprint slice

## Milestone 1 Objective
Establish the order-to-cash foundation so EcoPUK can sequence catalog, pricing, quoting, and shipping dependencies cleanly.

## Sprint Slice / Issue Set

### 1) Product Catalog & Inventory Management
- Business requirement: define product catalogue and stock/inventory boundaries
- Acceptance criteria:
  - [ ] Product groups defined
  - [ ] Inventory source of truth identified
  - [ ] Catalog fields mapped
- Technical requirements:
  - Model product, variant, availability, and pricing inputs
- Definition of done:
  - Catalog structure ready for downstream pricing and quoting
- Agile points: 5
- Suggested worker: Daniel Foster / Olivia Chen
- Primary model: gpt-5-mini
- Estimated tokens: 6,000
- Token pricing profile: premium reasoning
- Labour: 8h AI + 1h human review
- Milestone: Milestone 1
- Dependencies: none

### 2) Dynamic Pricing Engine
- Business requirement: compute product and shipping-inclusive pricing deterministically
- Acceptance criteria:
  - [ ] Pricing rules defined
  - [ ] Inputs/outputs documented
  - [ ] Edge cases captured
- Technical requirements:
  - Support manual rules and external rates
- Definition of done:
  - Pricing logic is ready for quote generation
- Agile points: 8
- Suggested worker: Ruby Patel / Olivia Chen
- Primary model: gpt-5-mini
- Estimated tokens: 8,000
- Token pricing profile: premium reasoning
- Labour: 12h AI + 1h human review
- Milestone: Milestone 1
- Dependencies: Product Catalog & Inventory Management

### 3) Quote Generation with Shipping Cost Integration
- Business requirement: produce accurate customer quotes including shipping
- Acceptance criteria:
  - [ ] Quote flow defined
  - [ ] Shipping cost input included
  - [ ] Approval path mapped
- Technical requirements:
  - Use pricing engine outputs and DHL rates
- Definition of done:
  - Quote flow ready for implementation
- Agile points: 8
- Suggested worker: Daniel Foster
- Primary model: gpt-5-mini
- Estimated tokens: 7,000
- Token pricing profile: premium reasoning
- Labour: 10h AI + 1h human review
- Milestone: Milestone 1
- Dependencies: Dynamic Pricing Engine

### 4) Customer Management & Segment Classification
- Business requirement: classify customer types and route them correctly
- Acceptance criteria:
  - [ ] Customer segments defined
  - [ ] Routing rules captured
  - [ ] Data fields listed
- Technical requirements:
  - Support segments, pricing tiers, and service rules
- Definition of done:
  - Segmentation ready for quote/order flow
- Agile points: 4
- Suggested worker: Hannah Clarke / Clara Evans
- Primary model: claude-haiku for first pass, gpt-5-mini for policy
- Estimated tokens: 3,500
- Token pricing profile: mixed
- Labour: 5h AI + 1h human review
- Milestone: Milestone 1
- Dependencies: Product Catalog & Inventory Management

### 5) Order Capture & PO Management
- Business requirement: capture orders and related purchase order details
- Acceptance criteria:
  - [ ] Order fields defined
  - [ ] PO workflow mapped
  - [ ] Exceptions noted
- Technical requirements:
  - Support quote-to-order conversion
- Definition of done:
  - Order intake ready for implementation
- Agile points: 8
- Suggested worker: Daniel Foster / Ruby Patel
- Primary model: gpt-5-mini
- Estimated tokens: 7,500
- Token pricing profile: premium reasoning
- Labour: 10h AI + 1h human review
- Milestone: Milestone 1
- Dependencies: Quote Generation with Shipping Cost Integration

## Dependency Order
1. Product Catalog & Inventory Management
2. Dynamic Pricing Engine
3. Customer Management & Segment Classification
4. Quote Generation with Shipping Cost Integration
5. Order Capture & PO Management

## Sprint Notes for Laura
- Keep EcoPUK as a live planning surface only until the active cycle exists.
- Once a cycle is live, assign only open issues in that cycle.
- If the cycle is blocked, escalate immediately.
