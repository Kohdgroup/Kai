# Cloudflare DNS Operating Model for kohd.io

## Source tickets
- KS-192 — Cloudflare DNS for kohd.io
- KS-2810 — DNS worker/spec for fully automated Cloudflare control of kohd.io
- KS-2825 — Cloudflare DNS change-control and Slack approval integration
- KS-2826 — Cloudflare DNS validation, rollback, and drift detection automation

## Operating model
1. Define desired DNS state in Linear.
2. Batch changes into weekly windows when possible.
3. Request Slack approval for risk-bearing changes.
4. Apply DNS changes through Cloudflare.
5. Validate propagation and health automatically.
6. Detect drift and alert or rollback automatically.
7. Keep provenance back to Linear.

## Safety rules
- no ad-hoc DNS edits outside the approved flow
- rollback must be available
- drift alerts must be actionable
- any change touching public ingress or TLS needs special care
- approvals should be grouped rather than one-off where possible

## Worker profile expectation
The DNS worker should be able to reason about:
- A/AAAA/CNAME/TXT/CAA/SRV records
- TTL and propagation timing
- Cloudflare account/zone models
- edge security and origin exposure
- TLS coordination
- automation, validation, and rollback
- Slack approvals and change windows

## End state
Fully automated Cloudflare DNS for kohd.io, with human approval only where the risk/impact warrants it.
