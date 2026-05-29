# Automated Stale-Doc Detection & Duplication Spec

Status: Draft
System of record: Linear
Publishing surface: GitHub docs repo
Related Linear issue: RELGOV-9

## Goal
Detect stale documentation, duplicate documentation, and conflicting versions across KOHD repos so Linear remains the source of truth and GitHub stays aligned.

## Scope
In scope:
- GitHub docs repo
- any KOHD repo that publishes operational docs
- generated markdown, policy docs, runbooks, templates, indexes, and decision logs

Out of scope:
- ephemeral scratch notes
- user-private drafts not intended for publication
- intentionally duplicated mirror docs when allowlisted

## Detection Inputs
Each doc should ideally carry metadata:
- source issue key
- source project
- source milestone or sprint
- owner
- last verified date
- review date / expiry date
- doc type
- allow-duplicate flag when duplication is intentional

Supplementary signals:
- git commit age
- last modified time
- file path changes
- Linear status changes
- repo sync timestamps

## Stale-Doc Heuristics
Flag as stale if one or more are true:
- missing owner
- missing source issue/project reference for governed docs
- missing last verified date on governance or operational docs
- review date has passed
- linked Linear issue is closed and the doc still asserts active status
- doc references a project or milestone that no longer exists or has been superseded
- repo sync lag exceeds the allowed cadence

Severity:
- Low: metadata missing but content still plausible
- Medium: review date exceeded or source issue missing
- High: stale decision/status content, obsolete procedure, or broken links

## Duplication Heuristics
Flag as duplicated if one or more are true:
- identical or near-identical content across two or more docs
- same title with different paths and no allowlist
- same topic, different version, no canonical doc designated
- conflicting instructions across repos
- mirrored docs without a declared mirror relationship

Similarity signals:
- exact text match
- title normalization match
- path similarity
- content similarity above a configured threshold

Default actions:
- exact duplicate: recommend archive or canonical merge
- near duplicate: recommend review and canonical selection
- intentional mirror: suppress if allowlisted

## Output Actions
For each finding, emit:
- doc path
- finding type: stale or duplicate
- severity
- reason
- recommended action: update, archive, merge, or review
- owner if known
- related Linear issue/project if known

Preferred Linear handling:
- create or comment on a governance issue
- attach findings as structured bullet list
- label as stale-doc or duplicate-doc where applicable

## Workflow
1. Scan docs on a schedule or on push.
2. Compare against metadata template and repo history.
3. Detect stale or duplicate candidates.
4. Apply allowlist rules.
5. Send findings to Linear.
6. Human reviews high-severity items.
7. Archive or update docs after approval.

## Allowlist Cases
Allow duplicates when they are:
- published mirrors for another repo
- generated indexes with intentional overlap
- template variants that are expected to share structure

## Review Cadence
- High-risk governance docs: regular review cycle
- Operational runbooks: shorter review cycle
- Stable reference docs: longer review cycle

## Success Criteria
- stale docs are discovered before they mislead delivery
- duplicate docs are identified before they diverge
- Linear remains the authoritative decision layer
- GitHub remains a clean, readable publication surface
