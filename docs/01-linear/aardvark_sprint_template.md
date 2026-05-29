# KOHD Sprint Template

Generated: 2026-05-29T13:01:04.789985+00:00

Rules:
- Assign only to open current-sprint issues when the cycle exists.
- Every issue must include business requirements, acceptance criteria, technical requirements, definition of done, Agile points, labour breakdown, estimated tokens & cost, milestones, dependencies, and implementation notes.
- Use Milestone 1 as the discovery/dependency-mapping sprint slice.
- All estimates below are planning estimates and must be recalibrated once the cycle is live.

# Aardvark — Sprint Template (Milestone 1)

Project: CD__aardvark
Scope: discovery, qualification, dependency mapping, and first executable sprint slice

## Milestone 1 Objective
Establish the operational baseline for Aardvark so the project can enter sprint execution with a clear dependency graph and minimal ambiguity.

## Sprint Slice / Issue Set

### 1) Capture Operational Topology
- Business requirement: map the real operational topology before delivery begins
- Acceptance criteria:
  - [ ] Core entities identified
  - [ ] System boundaries documented
  - [ ] Dependencies recorded
- Technical requirements:
  - Use current KOHD registry conventions
  - Capture people, tools, systems, and process relationships
- Definition of done:
  - Topology is documented and approved for planning
- Agile points: 4
- Suggested worker: Laura Bennett (Scrum Master / planning)
- Primary model: gpt-5-mini or similar premium reasoning
- Estimated tokens: 4,000
- Token pricing profile: premium reasoning
- Labour: 6h AI + 1h human review
- Milestone: Milestone 1
- Dependencies: none

### 2) Platform Inventory Audit
- Business requirement: identify all systems and assets that affect onboarding and operations
- Acceptance criteria:
  - [ ] Platforms listed
  - [ ] Owners identified
  - [ ] Risk/dependency notes captured
- Technical requirements:
  - Include comms, DNS, identity, support, and operational tooling
- Definition of done:
  - Inventory complete enough to drive sprint sequencing
- Agile points: 4
- Suggested worker: Laura Bennett
- Primary model: claude-haiku or GPT-4o-mini for first-pass inventory, premium model for synthesis
- Estimated tokens: 3,500
- Token pricing profile: cheap-fast + reasoning synthesis
- Labour: 5h AI + 1h human review
- Milestone: Milestone 1
- Dependencies: Capture Operational Topology

### 3) Define Entity Model and Job/Customer Schema
- Business requirement: establish the key data model for Aardvark operations
- Acceptance criteria:
  - [ ] Core entities defined
  - [ ] Relationships mapped
  - [ ] Open questions logged
- Technical requirements:
  - Define job, customer, dispatch, routing, and status objects
- Definition of done:
  - Model is ready for implementation stories
- Agile points: 5
- Suggested worker: Olivia Chen or Ruby Patel depending implementation target
- Primary model: gpt-5-mini
- Estimated tokens: 6,000
- Token pricing profile: premium reasoning
- Labour: 8h AI + 1h human review
- Milestone: Milestone 1
- Dependencies: Capture Operational Topology

### 4) Linear Governance & Intake Setup
- Business requirement: ensure Aardvark work enters Linear with the full KOHD governance fields
- Acceptance criteria:
  - [ ] Template fields present
  - [ ] Worker assignment rules documented
  - [ ] Cost/token logging enabled
- Technical requirements:
  - Use KOHD global planning standard
- Definition of done:
  - Issues are ready for live sprint conversion
- Agile points: 4
- Suggested worker: Laura Bennett
- Primary model: claude-haiku for documentation, gpt-5-mini for policy review
- Estimated tokens: 3,000
- Token pricing profile: mixed
- Labour: 4h AI + 1h human review
- Milestone: Milestone 1
- Dependencies: Platform Inventory Audit

### 5) Slack Operational Structure
- Business requirement: provision comms routing and operational channels
- Acceptance criteria:
  - [ ] Channels defined
  - [ ] Owners assigned
  - [ ] Escalation path documented
- Technical requirements:
  - Integrate with KOHD comms rules
- Definition of done:
  - Comms structure ready for sprint delivery
- Agile points: 3
- Suggested worker: Mia Carter / Laura Bennett
- Primary model: claude-haiku
- Estimated tokens: 2,000
- Token pricing profile: cheap-fast
- Labour: 3h AI + 0.5h human review
- Milestone: Milestone 1
- Dependencies: Capture Operational Topology

## Dependency Order
1. Capture Operational Topology
2. Platform Inventory Audit
3. Define Entity Model and Job/Customer Schema
4. Linear Governance & Intake Setup
5. Slack Operational Structure

## Sprint Notes for Laura
- Keep Aardvark as a live planning surface only until the active cycle exists.
- Once a cycle is live, assign only open issues in that cycle.
- If the cycle is blocked, escalate immediately.
