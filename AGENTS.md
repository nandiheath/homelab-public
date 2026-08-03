# Agent Guide

## Session protocol

1. Read this guide and `PROJECT_STATUS.md`; then inspect the task document before changing files.
2. When work needs production topology or cross-repository setup, read `~/workspace/agent-workspace/knowledge/library/kb-20260803-homelab-cross-repository.md` when available. Treat repository-local tasks as execution authority, and never copy private topology into this public repository.
3. Claim only one dependency-ready task by moving it from `tasks/planned/` to `tasks/running/`, setting `Status: running`, and recording yourself as its sole owner.
4. Work in a dedicated worktree. A task's `Owned paths` must be disjoint from every task in `tasks/running/`.
5. Run the focused proof in the task. Record observed output for every acceptance criterion in its completion handoff.
6. Do not merge or delete task files. The serial rollup owner does that after integration verification, updates `PROJECT_STATUS.md`, and removes successful task documents.
7. Apply `skills/contribution-workflow/SKILL.md` to every change. Complete a Conventional Commit and a pull request with its required description before landing work.

## Repository map

- `argocd/infrastructure/` — kustomize source for the cluster's public desired state.
- `artifacts/infrastructure/` — committed render output; source changes that affect it must update it.
- `homelab render` — local renderer provided by the Hermit-managed `homelab` CLI. It rewrites `artifacts/`.
- `scripts/validate.sh` — authoritative offline validation: actionlint, shellcheck, render, and kubeconform.
- `ansible/` — host bootstrap and maintenance playbooks. These target real hosts when run.
- `scripts/bootstrap.sh` — applies to a live Kubernetes cluster and reads 1Password credentials; never run without explicit user authorization.
- `scripts/validate-repository-graph.sh` — cross-repository check; requires the private repository and its denylist.
- `tasks/` — path-owned multi-agent work contracts; see `tasks/README.md`.

## Commands

```bash
source bin/activate-hermit
./scripts/validate.sh
```

`./scripts/validate.sh` uses only local tooling and writes generated files under `artifacts/`; it does not contact a cluster. Run it in the task worktree, inspect and include intended generated changes, and never run it concurrently against the same worktree.

For a focused render, use `homelab render --path argocd/infrastructure/<name> --output artifacts/infrastructure/<name>`. It rewrites that output directory.

## Safety gates

- Never use `kubectl`, run Ansible playbooks against non-fixture inventory, execute `scripts/bootstrap.sh`, apply manifests, deploy, publish, or mutate remote infrastructure without explicit user authorization in this conversation.
- Do not read, add, print, or commit `credentials/`, `config/.env`, Terraform state, or other ignored secrets.
- Preserve the public/private boundary. Cross-repository validation requires the private repository only when explicitly authorized and available.
- Keep home-network addresses, hostnames, topology, and firewall policy in the private repository and global knowledge reference. Public documentation, inventory examples, fixtures, and tests must use documentation-safe values and generic identities.
- Do not change generated artifacts by hand when `homelab render` can produce them.
- Do not claim overlapping paths or edit another active task's owned paths.
