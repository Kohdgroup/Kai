# Linear -> Metrics Pipeline Specification

## Goal
Define a controlled, auditable pipeline that extracts approved Linear data into a metrics store suitable for Grafana.

## Source data
- issues
- projects
- cycles / sprints
- milestones
- labels and workflow states
- cost/token metadata embedded in issue bodies or structured fields
- worker roster counts and assignments

## Required outputs
- active work rollups
- sprint load rollups
- work-in-hand totals
- cost/token/labour totals
- portfolio value indicators
- blocker / risk / readiness summaries
- worker counts by role/team/project

## Cadence
- recommended refresh: every 15-30 minutes for active work and sprint load
- daily snapshot for portfolio value summaries
- on-demand refresh after change-control windows

## Validation
- compare counts vs Linear before publish
- detect missing projects/cycles/issue states
- alert on sync failures or schema drift

## Access control
- publish aggregated metrics only
- hide issue-level details from founder dashboards
- keep operator drill-down in a separate view

## Notes
- The metrics store is the read model
- Linear remains the system of record
- worker counts should be treated as a first-class business metric
