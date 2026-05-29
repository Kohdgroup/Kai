# Founders Dashboard Metric Architecture

Source of truth: KS-2811 and its metric-schema child issues.

## Recommended shape
- Linear is the source of truth for execution
- A metrics store receives safe aggregates
- Grafana is the founder/operator surface
- Founder view is read-only and aggregated
- Operator view is detailed and drillable

## Metric families
- active work / sprint load / work-in-hand
- cost / token / labour rollups
- portfolio value / business impact
- blockers / risks / readiness
- change-control state

## Operating rules
- Keep issue-level detail out of founder views
- Sync on a defined cadence
- Track estimate and actual separately
- Keep the data model auditable
