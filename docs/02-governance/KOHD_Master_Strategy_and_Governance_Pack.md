# KOHD Governance, Delivery, Legal & Marketing Master Strategy

Consolidated reference document combining governance architecture, compliance guidance, delivery model, agent governance recommendations, and strategic positioning.

---



# Source: KOHD_Governance_Document_Architecture_.md

# KOHD Governance Document Architecture

## Executive Recommendation

The recommended structure is to separate governance, communications, operational delivery, and agent behaviour into distinct controlled documents.

This creates a scalable governance framework suitable for clubs, business clients, MSP customers, and future AI-driven delivery operations.

---

# Document Hierarchy

## KS-POL-001 — KOHD Ways of Working Policy

### Owner
COO / Delivery Governance

### Purpose

Client-facing governance and operating principles.

### Contents

- Communication Commitments
- Project Roles
- Decision Ownership
- Working Assumptions
- Escalation Rules
- Scope Management
- Acceptance Process
- Project Pause Rules
- Change Management
- Governance Principles

### Characteristics

- Client-facing
- Relatively stable
- Updated infrequently

---

## KS-TPL-001 — KOHD Email Template Library

### Owner
Delivery Operations

### Purpose

Reusable communication templates.

### Contents

- Primary Contact Setup
- Clarification Request
- Decision Request
- Approval Request
- Testing Request
- Action Taken Confirmation
- Sprint Communications
- Scope Change Requests
- Acceptance Requests
- Project Pause Notifications
- Handover Communications
- Escalation Communications

### Characteristics

- Template-only document
- No governance language
- No operating procedures
- No internal process descriptions

---

## KS-OPS-001 — KOHD Project Delivery Playbook

### Owner
Delivery Operations

### Purpose

Internal delivery procedures and execution standards.

### Contents

- Template Usage Rules
- Trigger Conditions
- Escalation Timings
- Project Lifecycle States
- Acceptance Workflow
- Communication Standards
- Record Keeping Standards
- Internal Delivery Procedures
- Delivery Governance Processes

### Internal References

- Hermes
- Rai
- Linear
- Knowledge Systems
- Automation Workflows

### Characteristics

- Internal-only
- Regularly updated
- Operational guidance

---

## KS-AGT-001 — KOHD Agent Communication Standard

### Owner
AI Operations

### Purpose

Defines communication standards and behavioural rules for all KOHD agents.

### Contents

- Agent Communication Principles
- Escalation Thresholds
- Human Intervention Rules
- Communication Tone Standards
- Approval Boundaries
- Autonomous Action Rules
- Assisted Action Rules
- Record Keeping Expectations
- Decision Escalation Matrix

### Characteristics

- Internal-only
- AI-focused governance
- Prevents behavioural drift between agents

---

# Strategic Benefits

This structure creates clear separation between:

| Layer | Purpose |
|---------|---------|
| Policy | What KOHD expects |
| Templates | What people send |
| Playbook | How delivery teams operate |
| Agent Standard | How AI agents behave |

---

# Recommended Final Stack

KS-POL-001
KOHD Ways of Working Policy

KS-TPL-001
KOHD Email Template Library

KS-OPS-001
KOHD Project Delivery Playbook

KS-AGT-001
KOHD Agent Communication Standard

---

# Outcome

This governance architecture provides a scalable foundation for:

- EcoPUK
- Aardvark Art Services
- KOHD Club MVP
- Club Onboarding Programmes
- Business Client Onboarding
- Managed Service Customers
- Strategic Partners
- Future AI-Driven Delivery Operations

while remaining aligned with the Hermes → Rai → Linear → Delivery operating model.


---



# Source: KOHD_Governance_Framework_Refinements_.md

# KOHD Governance Framework Refinements

## Recommended Governance Controls

The following refinements should be adopted before creating the final controlled documents.

---

# KS-POL-001 — KOHD Ways of Working Policy

## Audience

External and Internal

## Must Contain

- Purpose
- Scope
- Communication Commitments
- Project Roles
- Decision Ownership
- Working Assumptions
- Escalation Process
- Change Management
- Acceptance Process

## Must NOT Contain

- Linear
- Hermes
- Rai
- Agent Terminology
- Internal Workflows
- Technical Implementation Details

## Objective

This document should read as a professional client-facing governance document.

---

# KS-TPL-001 — KOHD Email Template Library

## Audience

Delivery Teams

## Must Contain

- Templates Only
- Subject Patterns
- Standard Signature

## Must NOT Contain

- Policies
- Procedures
- Governance Language
- Operating Rules

## Objective

Every section should simply contain:

Template Name

Template Body

Nothing else.

---

# KS-OPS-001 — KOHD Project Delivery Playbook

## Audience

Internal Teams

## Purpose

Operational delivery guidance and execution standards.

## Contents

- Template Usage Rules
- Escalation Timings
- Project Lifecycle States
- Delivery Lifecycle
- Approval Workflows
- Record Keeping Standards
- Client Communication Standards

## Internal Tooling References

This document is the appropriate location for:

- Linear
- Hermes
- Rai
- Knowledge Repositories
- Delivery Automation
- Internal Workflows

---

# KS-AGT-001 — KOHD Agent Communication Standard

## Audience

Internal / AI Governance

## Purpose

Defines behavioural standards for all current and future KOHD agents.

## Contents

- Agent Authority Boundaries
- Escalation Thresholds
- Approval Requirements
- Communication Style
- Confidence Thresholds
- Autonomous Action Rules
- Human-in-the-Loop Requirements
- Audit Requirements
- Memory Usage Standards
- Record Retention Expectations

## Governance Requirement

This document should operate under strict change control.

It should be treated as a behavioural standard and not be freely modified without governance review.

---

# Mandatory Metadata Block

Every controlled document should begin with:

```yaml
Document ID: KS-POL-001
Document Name: KOHD Ways of Working Policy
Version: 1.0.0
Status: Draft
Owner: Delivery Governance
Approver: COO
Classification: Internal / Client Facing
Created: 2026-05-31
Last Updated: 2026-05-31
Review Cycle: Annual
Related Documents:
  - KS-TPL-001
  - KS-OPS-001
  - KS-AGT-001
```

Document-specific values should be adjusted as appropriate.

---

# Cross-Reference Requirements

Every document should contain a Related Documents section.

| Document | Purpose |
|-----------|-----------|
| KS-POL-001 | Governance & Operating Principles |
| KS-TPL-001 | Communication Templates |
| KS-OPS-001 | Delivery Operations |
| KS-AGT-001 | Agent Behaviour Standards |

This prevents document silos and improves discoverability.

---

# Recommended Next Step

Create the following as four independent controlled documents:

1. KS-POL-001 — KOHD Ways of Working Policy
2. KS-TPL-001 — KOHD Email Template Library
3. KS-OPS-001 — KOHD Project Delivery Playbook
4. KS-AGT-001 — KOHD Agent Communication Standard

Each document should include:

- Version Metadata
- Ownership
- Approval Workflow
- Review Cycle
- Cross-References

This creates a scalable governance framework suitable for clubs, business clients, managed services, strategic partners, and future AI-driven delivery operations.


---



# Source: KOHD_UK_Legal_Compliance_Review__.md

# KOHD Governance Framework - UK Legal & Compliance Review

## Executive Summary

The governance architecture is sound and appropriate for a UK-based service provider. However, several areas should be reviewed before operational deployment, particularly where governance, acceptance, AI decision-making, and personal data processing intersect.

The email templates themselves present relatively low risk. The higher-risk areas are governance policies, AI authority, acceptance mechanisms, and GDPR compliance.

---

# 1. Acceptance by Silence

## Risk Level: High

The proposed wording:

> Acceptance will be assumed after five business days if no material issues are raised.

may not always be enforceable under UK law.

### Acceptable Circumstances

This may be appropriate where:

- It is explicitly included within an agreed contract.
- It forms part of an agreed Statement of Work (SOW).
- Both parties have accepted the process.

### Recommendation

Replace with:

> Please review and confirm acceptance. Where acceptance timelines are governed by an agreed contract or statement of work, those terms will apply.

---

# 2. Working Assumptions

## Risk Level: Medium

The concept is sound but the wording should avoid implying KOHD can make decisions on behalf of the client.

### Recommended Wording

> Where information is unavailable and work would otherwise be delayed, KOHD may propose reasonable working assumptions for review and confirmation.

This maintains project momentum while reducing legal ambiguity.

---

# 3. Decision Ownership

## Risk Level: Medium

Avoid wording that could imply legal responsibility has been transferred.

### Avoid

> The Primary Contact is responsible for...

### Prefer

> The Primary Contact acts as KOHD's designated point of contact for business decisions, clarifications and approvals unless otherwise agreed.

---

# 4. Project Pause Notifications

## Risk Level: Medium

Care should be taken when describing project pauses, especially where fixed-fee services are involved.

### Avoid

> Project is paused.

### Prefer

> Progress on the affected workstream is currently dependent upon...

This avoids implying that all work has ceased.

---

# 5. Response Time Expectations

## Risk Level: Low

Operational targets are acceptable.

### Recommended Language

Use:

> Typical response target

rather than:

> Guaranteed response

unless contractual SLAs exist.

---

# 6. AI and Agent Communications

## Risk Level: High

This is one of the most important governance areas for KOHD.

### Agents Should Never:

- Enter contracts
- Approve expenditure
- Approve legal documents
- Approve invoices
- Approve refunds
- Accept liability
- Commit to delivery dates
- Make employment or HR decisions

without explicit human approval.

### Recommendation

Create a formal:

**Reserved Human Decisions Matrix**

within KS-AGT-001.

---

# 7. UK GDPR Compliance

## Risk Level: High

KOHD will process personal data when:

- Recording client communications
- Storing contact details
- Managing club member information
- Using AI memory systems
- Using Hermes, Honcho, Rai, or similar platforms

### KS-POL-001 Should Reference

- Privacy Policy
- Data Processing Agreement (DPA)
- Data Retention Policy

without duplicating them.

---

# 8. Email Retention and Project Records

## Risk Level: Medium

The statement:

> Responses will be recorded in the project record.

is generally acceptable.

However KOHD should also define:

- Retention periods
- Deletion procedures
- Access controls
- Audit requirements

within separate governance documents.

---

# 9. Clubs and Volunteer Governance

## Risk Level: Medium

Club officers and committee members frequently change.

### Recommendation

Add wording such as:

> The organisation is responsible for notifying KOHD when authorised contacts change.

This prevents instruction being taken from former committee members.

---

# 10. Documentation Standard Requirements

## Risk Level: Medium

KS-STD-001 should require legal review before production deployment of:

- KS-POL-001
- Terms of Business
- Master Services Agreement (MSA)
- Statement of Work Templates
- Data Processing Agreements
- AI Governance Policies

---

# Overall Risk Assessment

| Area | Risk |
|--------|--------|
| Email Template Library | Low |
| Project Delivery Playbook | Low |
| Agent Communication Standard | Medium |
| Ways of Working Policy | Medium |
| Acceptance Process | High |
| AI Decision Authority | High |
| GDPR & Data Retention | High |

---

# Recommended Additional Legal Documents

To support the governance framework, KOHD should consider creating:

## KS-LGL-001 — Master Services Agreement

Defines the contractual relationship between KOHD and clients.

## KS-LGL-002 — Statement of Work Template

Defines project-specific scope, deliverables, timelines, and responsibilities.

## KS-LGL-003 — Data Processing Agreement

Supports GDPR compliance and defines data processing responsibilities.

## KS-LGL-004 — AI & Automation Governance Policy

Defines how AI systems are used, monitored, governed, and audited.

## KS-LGL-005 — Club Governance & Committee Authority Policy

Defines authority structures, authorised contacts, and governance requirements for clubs.

---

# Final Recommendation

The governance framework should proceed as planned.

The greatest legal and operational protection for KOHD will come not from additional email templates, but from implementing the supporting legal, governance, and AI-control documents listed above.

These documents should be reviewed by appropriately qualified UK legal counsel before production use.


---



# Source: KOHD_Governance_Framework_Final_Review(1).md

# KOHD Governance Framework Review - Final Recommendations

## Review Summary

The KOHD Governance Framework draft is substantially stronger than previous iterations and is approaching production readiness.

The separation between governance, templates, operations, documentation standards, and agent governance is appropriate and provides a scalable foundation for KOHD's future delivery model.

---

# Strengths

## Governance Separation

Clear separation now exists between:

- KS-POL-001 — Governance
- KS-TPL-001 — Templates
- KS-OPS-001 — Operations
- KS-STD-001 — Documentation Standards
- KS-AGT-001 — Agent Governance

This significantly improves maintainability and ownership.

---

## Legal Improvements

The framework now includes:

- Removal of acceptance-by-silence language
- Improved working assumptions wording
- Clarified decision ownership
- Improved project pause language
- GDPR references
- Human approval boundaries

These changes materially reduce legal and governance risk.

---

## Agent Governance

The Reserved Human Decisions Matrix is particularly valuable.

The following controls are now appropriately included:

- Escalation thresholds
- Human approval requirements
- Confidence thresholds
- Audit requirements
- Memory standards
- Behaviour controls

This provides a strong foundation for future Hermes and Rai governance.

---

# Recommended Improvements Before Final Approval

## 1. Simplify KS-TPL-001 Further

### Current State

KS-TPL-001 still contains:

- Subject Line Rules
- Related Documents
- Notes
- Template Category Headings

### Recommendation

Move:

- Subject Line Rules → KS-OPS-001
- Related Documents → Metadata Only
- Notes → Remove

### End State

KS-TPL-001 should become:

Template Name

Template Body

Nothing else.

This keeps the document focused purely on reusable communications.

---

## 2. Expand Project Lifecycle States

### Current States

- Intake
- Discovery
- Planning
- Delivery
- Testing
- Acceptance
- Handover
- Closed

### Recommended States

- Intake
- Qualification
- Discovery
- Architecture
- Planning
- Build
- Validation
- Acceptance
- Deployment
- Hypercare
- Operational Support
- Closed

This better aligns with KOHD OS and managed-service delivery.

---

## 3. Add Agent Risk Classification

Add the following section to KS-AGT-001.

| Risk Level | Agent Authority |
|------------|----------------|
| Low | Autonomous |
| Medium | Human Review |
| High | Human Approval Required |
| Critical | Human Decision Required |

This provides a future routing model for Rai and Hermes.

---

## 4. Add Change Log Standard

Add to KS-STD-001.

```yaml
Change Log:
  - Version
  - Date
  - Author
  - Summary
```

Without this, version numbers will become difficult to interpret over time.

---

## 5. Improve KS-IDX-001 Onboarding

Add a Start Here section.

```text
Start Here

1. Read KS-IDX-001
2. Read KS-POL-001
3. Use KS-TPL-001
4. Operate from KS-OPS-001
5. Govern AI using KS-AGT-001
```

This makes onboarding significantly easier.

---

# Document Readiness Assessment

| Document | Readiness |
|-----------|-----------|
| KS-IDX-001 | 95% |
| KS-STD-001 | 90% |
| KS-POL-001 | 95% |
| KS-TPL-001 | 85% |
| KS-OPS-001 | 90% |
| KS-AGT-001 | 95% |

---

# Deployment Assessment

The framework is now mature enough to support:

- Linear governance projects
- Hermes skills
- Rai governance rules
- Delivery playbooks
- Client onboarding
- Club onboarding
- Internal delivery operations

---

# Recommended Next Priority

The next major body of work should be legal and governance support documents rather than further refinement of the framework.

## Recommended Documents

### KS-LGL-001
KOHD Master Services Agreement

### KS-LGL-002
KOHD Statement of Work Template

### KS-LGL-003
KOHD Data Processing Agreement

### KS-LGL-004
KOHD AI & Automation Governance Policy

### KS-LGL-005
KOHD Club Governance & Committee Authority Policy

---

# Final Conclusion

The governance framework is approaching production readiness.

The highest-value next step is not further governance refinement but creation of the supporting legal and compliance document suite.

These legal documents will have a greater impact on KOHD's long-term operational risk profile than further adjustments to the governance framework itself.


---



# Source: KOHD_AI_Augmented_Delivery_Model(1).md

# KOHD AI-Augmented Delivery Model

## Strategic Positioning

KOHD should position itself as an AI-Augmented Delivery Organisation with Human Accountability.

Clients are not purchasing access to AI systems. They are purchasing outcomes, governance, expertise, implementation capability, quality assurance, accountability, continuity, and support.

Artificial intelligence, automation, and agent-based systems form part of KOHD's internal delivery engine and are used to accelerate delivery while maintaining quality and governance standards.

---

# Delivery Model Statement

## Recommended KS-POL-001 Addition

### Delivery Model

KOHD combines human expertise, structured governance processes, automation, and AI-assisted execution to deliver services efficiently, consistently, and at scale.

Our delivery model is designed to accelerate outcomes while maintaining appropriate oversight, quality assurance, and accountability.

Responsibility for quality, decisions, approvals, security, compliance, and client outcomes remains with KOHD's delivery organisation.

Where automation and AI-assisted execution are used, they operate within defined governance controls and are subject to human oversight where appropriate.

Clients engage KOHD for the outcomes, expertise, governance, and continuity of service provided by the wider delivery organisation, rather than for access to any individual technology, platform, or tool.

---

# Recommended KS-OPS-001 Addition

## Delivery Transparency

KOHD may utilise a combination of human specialists, automation, and AI-assisted execution throughout the delivery lifecycle.

Client communications should focus on:

- Outcomes achieved
- Decisions required
- Risks identified
- Quality assurance activities
- Governance checkpoints

Client communications should not focus on the specific implementation method, model, platform, or internal tooling used unless there is a business, contractual, or compliance requirement to do so.

The delivery organisation remains accountable for all outputs regardless of how work is executed internally.

---

# Commercial Positioning

The following statement should be standardised across:

- Proposals
- Statements of Work
- Client Onboarding Packs
- Service Descriptions
- Commercial Presentations
- Sales Material

## Standard Positioning Statement

KOHD combines specialist expertise, structured delivery governance, and AI-accelerated execution to deliver outcomes faster while maintaining human accountability for decisions, quality, and client success.

---

# Client Perception Strategy

## Avoid

The following language should generally be avoided in client-facing communication:

- "The AI generated this"
- "Hermes built this"
- "The agent decided"
- "The AI analysed this"
- "ChatGPT created this"

## Prefer

Use language such as:

- "The KOHD team reviewed"
- "The delivery team recommends"
- "The solution architecture review concluded"
- "The implementation team completed"
- "The project team identified"

The accountability always remains with KOHD.

---

# Governance Checkpoints

Delivery speed should not be artificially slowed.

Instead, delivery should include visible governance stages.

Example:

Work Complete
↓
QA Review
↓
Architecture Review
↓
Release Approval
↓
Client Release

The client sees governance and quality assurance rather than internal execution methods.

---

# Delivery Lifecycle States

Recommended client-facing delivery states:

- Analysing
- Designing
- Building
- Validating
- Approving
- Deploying
- Hypercare

These states provide transparency while reinforcing a professional delivery process.

---

# Revenue Protection Principle

KOHD should avoid positioning services around effort or hours.

Avoid:

- Hours worked
- AI usage
- Development time

Prefer:

- Outcomes
- Capabilities
- Deliverables
- Business Value
- Managed Services
- Governance

Clients purchase outcomes, not the number of hours required to achieve them.

---

# Core Strategic Principle

The client can buy access to AI tools.

What they cannot easily buy is:

- Governance
- Accountability
- Experience
- Execution
- Delivery Capability
- Quality Assurance
- Continuity of Service
- Managed Outcomes

These are the areas where KOHD creates and retains commercial value.

---

# Final Position

KOHD is not an AI company delivering projects.

KOHD is a delivery organisation that uses AI, automation, governance, and specialist expertise to deliver better outcomes faster while maintaining human accountability.

The technology remains part of the operating model.

The outcome remains the product.


---


# KOHD Commercial & Delivery Lifecycle

## Lifecycle

Enquiry → Qualification → Discovery → Solution Design → Proposal → Quote Acceptance → Contracting → Project Initiation → Delivery → Acceptance → Hypercare → Operational Support → Renewal

## Proposed Controlled Document

KS-COM-001 — Commercial & Delivery Lifecycle

Purpose:
- Define document routing from enquiry through delivery and support.
- Define ownership, approvals, and governance checkpoints.
- Connect commercial, legal, delivery, and operational processes.

---

# KOHD Marketing Positioning

## Club OS Four Pillars

1. Member Experience
2. Sustainable Revenue
3. Reduced Volunteer Burden
4. Protecting Club Heritage

### Core Narrative

"If the walls could talk, what stories would they tell?"

KOHD helps clubs preserve their history, grow their community, increase revenue, and reduce the burden on volunteers.

---

## Business OS Four Pillars

1. Operational Efficiency
2. Revenue Growth
3. Business Intelligence
4. Organisational Continuity

### Core Narrative

"Your business should remember everything, not just the people who work there."

KOHD helps organisations improve operational efficiency, accelerate revenue growth, strengthen decision-making, and protect organisational knowledge.

---

## Parent Brand Statement

KOHD helps organisations capture, organise, automate, and grow what matters most.

---

## Standard Commercial Positioning

KOHD combines specialist expertise, structured delivery governance, and AI-accelerated execution to deliver outcomes faster while maintaining human accountability for decisions, quality, and client success.
