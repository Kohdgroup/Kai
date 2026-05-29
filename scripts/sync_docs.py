#!/usr/bin/env python3
"""Sync KOHD docs snapshots into the GitHub docs repo."""

from __future__ import annotations

import argparse, json, os, shutil, subprocess, textwrap
from pathlib import Path

SKILL_GROUPS = {'cxo','sales','marketing','qa','backend','frontend','devops','design','hub','failure','lead','shared','other'}

def render_master_index(root: Path) -> None:
    lines = [
        '# Kai Documentation Overview', '',
        '| Section | Purpose | Key contents |',
        '|---|---|---|',
        '| `01-linear` | Linear planning, sprint templates, guest-user planning, and issue/cost tracking | guest roster, planning standard, sprint templates, issue outputs, alert issues |',
        '| `02-governance` | Autonomous delivery governance and planning control-plane docs | Laura Scrum Master spec, project evaluation, milestone trees, model routing |',
        '| `03-workers` | Worker roster and role mapping artifacts | worker registry, matrices, board mappings, advisory board |',
        '| `04-projects` | Project-level entry points and overviews | project summary landing pages |',
        '| `05-nas` | NAS, SMB, and storage operations docs | setup guides, runbooks, reports, deployment checklists |',
        '| `06-skills` | Snapshots of the skill library, grouped by domain | domain folders of SKILL.md files |',
        '| `07-archives` | Scratch outputs and historical artifacts | volume exports, temporary notes, archival files |',
        '', 'Start here by section:',
        '- `01-linear/INDEX.md`', '- `02-governance/INDEX.md`', '- `03-workers/INDEX.md`', '- `04-projects/README.md`', '- `05-nas/INDEX.md`', '- `06-skills/INDEX.md`', '- `07-archives/`',
    ]
    (root / 'docs' / 'README.md').write_text('\n'.join(lines) + '\n')

def rebuild_skills(root: Path, source: Path) -> None:
    skills_root = root / 'docs' / '06-skills'
    if skills_root.exists():
        for p in list(skills_root.iterdir()):
            if p.name == 'INDEX.md':
                continue
            if p.is_dir(): shutil.rmtree(p)
            else: p.unlink()
    else:
        skills_root.mkdir(parents=True)
    counts, examples = {}, {}
    for src in source.rglob("SKILL.md"):
        rel = src.relative_to(source)
        if "webdav-ingested" in rel.parts:
            idx = rel.parts.index("webdav-ingested")
            skill_name = rel.parts[idx + 1]
            domain = skill_name.split("-")[0]
            if domain not in SKILL_GROUPS: domain = "other"
            dst = skills_root / domain / skill_name / "SKILL.md"
        elif "shared" in rel.parts:
            skill_name = rel.parts[-2]
            domain = "shared"
            dst = skills_root / domain / skill_name / "SKILL.md"
        else:
            continue
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst)
        counts[domain] = counts.get(domain, 0) + 1
        examples.setdefault(domain, []).append(dst.relative_to(skills_root).as_posix())
    lines = ["# Skills Library Snapshot", "", "Domain-split snapshots of SKILL.md files imported into the docs repo.", "", "| Domain | Count | Example paths |", "|---|---:|---|"]
    for dom in sorted(counts):
        ex = ", ".join(f"`{x}`" for x in examples[dom][:3])
        lines.append(f"| `{dom}` | {counts[dom]} | {ex} |")
    lines.append("")
    lines.append("The files live under `docs/06-skills/<domain>/<skill>/SKILL.md`.")
    (skills_root / "INDEX.md").write_text("\n".join(lines) + "\n")
    for dom in sorted(counts):
        domdir = skills_root / dom
        lines = [f"# {dom.title()} Skills", "", f"Count: {counts[dom]}", "", "Files:"]
        for x in sorted(examples[dom]): lines.append(f"- `{x}`")
        (domdir / "INDEX.md").write_text("\n".join(lines) + "\n")

def rebuild_sections(root: Path, source: Path) -> None:
    mapping = {
        '01-linear': ['linear_guest_user_plan.md','linear_global_planning_standard.md','linear_guest_user_plan.json','linear_guest_invites_and_cycle.json','linear_worker_stage_mapping.json','linear_sprint_issue_creates.json','linear_sprint_totals.json','slack_token_alert_issue.json','sprint_templates_index.md','aardvark_sprint_template.md','ecopuk_sprint_template.md'],
        '02-governance': ['scrum_master_linear_autonomous.md','laura_live_project_evaluation.md','live_project_milestone_plan.md','full_milestone_trees.md','kohd_ai_routing_automation_plan.md','ai_capability_automation_lead.md','model_routing_matrix.md','linear_team_views_matrix.md','linear_model_routing_view.md','worker_matrix.md','cd_delivery_dashboards_and_initiatives.json','cd_delivery_dashboards_and_initiatives_2.json'],
        '03-workers': ['workers.json','worker_matrix.json','skill_assignments.json','board_skill_assignments.json','advisory_board.json'],
        '04-projects': ['README.md'],
        '05-nas': ['smb_manager_state.json','reports/nas-inventory.json','reports/smb-inbox-report.json','docs/KS-2803-Verify-SMB-Inbox-Setup.md','docs/KS-2803-Implementation-Summary.md','docs/KS-2803-Three-Share-Architecture.md','docs/KS-2803-Setup-Checklist.md','docs/DSM-Shared-Folder-Setup.md','docs/KS-2803-SMB-Inbox-Management-Complete.md','docs/Kohd-Kai-Hub1-SMB-Setup.md','docs/Synology-Native-SMB-Setup.md','docs/KOHD-NAS-SMB-DEPLOYMENT.md','docs/KOHD-NAS-network-config.md','docs/SMB-share-setup.md','docs/NAS-volume-configuration.md','docs/KS-2794-runbook.md'],
        '07-archives': ['volumes/kohd/active/project-2026-q2.md','volumes/kohd/active/test-skill.md'],
    }
    for section, items in mapping.items():
        secdir = root / 'docs' / section
        secdir.mkdir(parents=True, exist_ok=True)
        for p in list(secdir.iterdir()):
            if p.name == "INDEX.md": continue
            if p.is_dir(): shutil.rmtree(p)
            else: p.unlink()
        for item in items:
            sp = source / item
            if not sp.exists(): continue
            dp = secdir / Path(item).name
            dp.parent.mkdir(parents=True, exist_ok=True)
            if sp.suffix == ".json":
                try: dp.write_text(json.dumps(json.loads(sp.read_text()), indent=2) + "\n")
                except Exception: shutil.copy2(sp, dp)
            else:
                shutil.copy2(sp, dp)
        lines = [f"# {section}", "", "Files:"]
        for item in items: lines.append(f"- `{Path(item).name}`")
        (secdir / "INDEX.md").write_text("\n".join(lines) + "\n")
    (root / "docs" / "04-projects" / "README.md").write_text("# Projects\n\nProject-level entry points and overviews.\n")

def git_commit_push(root: Path, commit: bool, push: bool) -> None:
    subprocess.run(["git", "add", "README.md", "docs", "scripts/sync_docs.py", "scripts/sync_and_push.sh"], cwd=root, check=True)
    if commit:
        subprocess.run(["git", "commit", "-m", "Improve docs indexing and skill domain split"], cwd=root, check=True)
    if push:
        env = os.environ.copy()
        env["GIT_SSH_COMMAND"] = "ssh -i /root/.ssh/kohd_github_ed25519 -o IdentitiesOnly=yes"
        subprocess.run(["git", "push", "origin", "main"], cwd=root, check=True, env=env)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--source", default="/app/data/hermes")
    ap.add_argument("--repo", default=".")
    ap.add_argument("--commit", action="store_true")
    ap.add_argument("--push", action="store_true")
    args = ap.parse_args()
    root = Path(args.repo)
    source = Path(args.source)
    render_master_index(root)
    rebuild_sections(root, source)
    rebuild_skills(root, source)
    if args.commit or args.push:
        git_commit_push(root, args.commit, args.push)

if __name__ == "__main__":
    main()
