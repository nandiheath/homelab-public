# Agent Guide

## Session protocol

1. Read this guide and `PROJECT_STATUS.md`; then inspect the parent milestone and child task before changing files.
2. Planning creates one milestone first; every spawned task must reference that milestone and appear in its checklist. A future reminder remains a planned milestone, not a loose task. When work needs production topology or cross-repository setup, read `~/workspace/agent-workspace/knowledge/library/kb-20260803-homelab-cross-repository.md` when available; repository-local contracts remain execution authority and private topology must stay out of this repository.
3. Claim only one dependency-ready task by moving it from `tasks/planned/` to `tasks/running/`, setting `Status: running`, and recording yourself as its sole owner.
4. Work in a dedicated worktree. A task's `Owned paths` must be disjoint from every task in `tasks/running/`.
5. Run the focused proof in the task. Record observed output for every acceptance criterion in its completion handoff.
6. Do not merge, delete, or check off task files. The serial rollup owner integrates children, updates the milestone, runs milestone-level verification, updates `PROJECT_STATUS.md`, and removes successful contracts. A milestone is not done merely because its child tasks passed.
7. Apply `skills/contribution-workflow/SKILL.md` to every change. Complete a Conventional Commit and a pull request with its required description before landing work.

## Repository map

- `argocd/` — recursive public source tree; each render unit is native Helm (`Chart.yaml` plus `values.yaml`) or Kustomize (`kustomization.yaml`).
- `artifacts/` — committed output mirroring source-relative paths; source changes that affect it must update it.
- `homelab argocd render` — Hermit-managed recursive renderer; it rejects ambiguous source markers and rewrites only the selected generated output.
- `scripts/validate.sh` — authoritative offline validation: actionlint, shellcheck, and kubeconform.
- `ansible/` — host bootstrap and maintenance playbooks. These target real hosts when run.
- `scripts/bootstrap.sh` — applies to a live Kubernetes cluster and reads 1Password credentials; never run without explicit user authorization.
- `scripts/validate-repository-graph.sh` — cross-repository check; requires the private repository and its denylist.
- `tasks/` — path-owned multi-agent work contracts; see `tasks/README.md`.

## Commands

```bash
source bin/activate-hermit
homelab argocd render --all
./scripts/validate.sh
```

Rendering uses local tools plus explicitly declared Helm/Kustomize dependencies and writes generated files under `artifacts/`; it does not contact a cluster. Run it in the task worktree and never run it concurrently against the same worktree. CI starts from a clean checkout, renders only source units changed by the triggering commit range, validates before commit-back, and rejects source-only revisions.

For a focused render, use `homelab argocd render --path argocd/<scope>/<name> --output artifacts/<scope>/<name>`. It atomically replaces that output directory.

## Safety gates

- Never use `kubectl`, run Ansible playbooks against non-fixture inventory, execute `scripts/bootstrap.sh`, apply manifests, deploy, publish, or mutate remote infrastructure without explicit user authorization in this conversation.
- Do not read, add, print, or commit `credentials/`, `config/.env`, Terraform state, or other ignored secrets.
- Preserve the public/private boundary. Cross-repository validation requires the private repository only when explicitly authorized and available.
- Keep home-network addresses, hostnames, topology, and firewall policy in the private repository and global knowledge reference. Public documentation, inventory examples, fixtures, and tests must use documentation-safe values and generic identities.
- Do not change generated artifacts by hand when `homelab argocd render` can produce them.
- Do not claim overlapping paths or edit another active task's owned paths.
