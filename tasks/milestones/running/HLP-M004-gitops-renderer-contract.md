# HLP-M004 — GitOps renderer contract

- Status: running
- Owner: Main

## Goal

Adopt the shared recursive Helm-or-Kustomize render contract so reusable infrastructure sources and deterministic artifacts remain public while both repositories use the released `homelab` renderer and identical CI drift handling.

## Tasks

- [ ] HLP-021 — Adopt shared GitOps renderer contract

## Acceptance criteria

- [ ] Source units under `argocd/` are discovered recursively from native `Chart.yaml` plus `values.yaml` or `kustomization.yaml` markers, with ambiguous layouts rejected.
- [ ] `artifacts/` mirrors each source unit's relative path and a second complete render is byte-stable.
- [ ] The public repository pins the released renderer, validates its generated resources, commits artifact-only drift on trusted branches, and fails the source-only workflow run.
- [ ] Reusable Cilium source remains public and contains no production-private values.

## Verification

- Scenario or command: run `make render`, `./scripts/validate.sh`, render again, and compare the artifact tree; exercise Helm, Kustomize, ambiguous, deleted-source, and artifact-only commit behavior in the renderer suite.
- Expected observation: both engines are selected automatically, invalid layouts fail closed, output is deterministic, validation passes, and only generated artifacts are eligible for commit-back.

## Blockers

- The compatible `homelab` CLI release must be published before the repository package pin is updated.

## Completion handoff

- Tasks rolled up:
- Observed milestone verification:
- Project status updated:
- Follow-ups:
