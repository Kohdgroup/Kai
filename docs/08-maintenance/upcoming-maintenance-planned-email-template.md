# Upcoming Maintenance Planned — Email Template

Source of truth: Linear change request / change window

Use this as the base message for customer-facing maintenance notices. Replace all bracketed placeholders.

---

Subject: Upcoming maintenance planned for [service / domain]

Hello [first name / team],

We’re planning a routine maintenance window for [service / domain].
This work is intended to improve reliability, security, or performance and may briefly affect some parts of the experience.

Maintenance window
- Date: [day, month date, year]
- Time (UTC): [start]-[end]
- Time ([region 1]): [start]-[end]
- Time ([region 2]): [start]-[end]
- Expected impact duration: [typically under X minutes]

What to expect
The following actions may be briefly affected:
- [action 1]
- [action 2]
- [action 3]

What’s changing
- [short summary of the change]
- [dependency / upstream service]
- [why this maintenance is happening]

Do I need to do anything?
Usually, no.
If you are actively using the affected service during the window and hit an error, wait a few minutes and retry.
If the issue continues after the maintenance window, please contact [support contact / help channel].

Need help?
If you experience issues beyond the maintenance window, contact [support channel / email / Slack].

Thanks,
KOHD

---

## Internal notes
- Link this message to the Linear change request.
- Do not include secrets, credentials, or internal-only operational detail.
- If there is an affected-people list, keep it separate from the email body.
