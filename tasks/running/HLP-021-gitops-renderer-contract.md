# HLP-021 — Adopt shared GitOps renderer contract

- Status: ready-for-rollup
- Owner: Main
- Milestone: HLP-M004
- Depends on: none

## Owned paths

- `.github/workflows/render.yaml`
- `AGENTS.md`
- `README.md`
- `Makefile`
- `argocd/`
- `artifacts/`
- `bin/.homelab-*.pkg`
- `scripts/validate.sh`
- `scripts/create_app.sh`
- `tasks/milestones/running/HLP-M004-gitops-renderer-contract.md`
- `tasks/running/HLP-021-gitops-renderer-contract.md`

## Goal

Make the public repository use the shared recursive renderer and CI drift contract while retaining ownership of reusable infrastructure sources.

## Implementation

1. Pin the compatible released `homelab` CLI.
2. Render recursively from `argocd/` into the matching `artifacts/` paths.
3. Validate rendered resources and align trusted-branch artifact commit-back with explicit first-run failure.
4. Preserve Cilium and other reusable infrastructure as public source inputs.

## Acceptance criteria

- [x] `make render` discovers every public source unit recursively and renders it through automatic native marker detection.
- [x] All generated output exists below the matching `artifacts/` relative path and is deterministic.
- [x] CI cannot push from pull requests, validates before commit-back, commits only artifact drift on trusted branches, dispatches validation for the generated commit, and fails the original drift run.
- [x] Full public repository validation passes without infrastructure access.

## Verification

- `make render && ./scripts/validate.sh && make render` — every source renders, validation passes, and the second render is clean.
- Renderer CLI test suite — Helm, Kustomize, invalid-layout, deletion, and commit restrictions pass.

## Blockers

- None.

## Completion handoff

- Summary: Pinned `homelab 0.4.0`, adopted recursive native Helm/Kustomize discovery at the existing `argocd/` root, removed the public application-source generator, documented the private/public ownership boundary, and added validation-before-commit CI with trusted-branch dispatch and first-run failure.
- Files changed: `.github/workflows/render.yaml`; `AGENTS.md`; `README.md`; `bin/.homelab-0.3.2.pkg`; `bin/.homelab-0.4.0.pkg`; `bin/homelab`; `scripts/create_app.sh`; `scripts/validate.sh`; task and milestone contracts.
- Observed verification: `make render` succeeded with `homelab 0.4.0`; `make validate` passed Ansible lint, syntax, lifecycle fixtures, actionlint, shellcheck, and kubeconform (`352` resources, `245` valid, `0` invalid, `0` errors, `107` skipped schemas). Two complete renders produced the same `352` files and SHA-256 tree digest `d245985e0ceff210e1e700fb0fe0a58148a76417d146a1aa70a7edf6d1b10e09`. The shared CLI suite passed in all three Go packages, including engine selection, ambiguous/incomplete rejection, stale deletion, artifact-only commit, and fail-after-push behavior. Cross-repository graph validation passed.
- Follow-ups: Serial rollup should update `PROJECT_STATUS.md`, remove the completed task and milestone contracts, and land through the required pull request.
