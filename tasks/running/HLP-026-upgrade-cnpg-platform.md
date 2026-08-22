# HLP-026 — Upgrade CNPG and add Barman Cloud plugin sources

- Status: ready-for-rollup
- Owner: Main
- Milestone: HLP-M008
- Depends on: none

## Owned paths

- `argocd/infrastructure/cnpg/`
- `docs/cloudnativepg-platform.md`
- `tasks/running/HLP-026-upgrade-cnpg-platform.md`
- `tasks/milestones/running/HLP-M008-cnpg-hub-platform.md`

## Goal

Update the public infrastructure source from CloudNativePG 1.27.0 to 1.30.0 and add the reviewed Barman Cloud plugin 0.14.0 source without changing any PostgreSQL operand image or performing cluster reconciliation.

## Implementation

1. Replace the mutable CNPG 1.27 release source with the reviewed 1.30.0 release manifest.
2. Add the official Barman Cloud plugin 0.14.0 installation source and immutable digest/version assertions required by repository validation.
3. Record primary-source compatibility evidence for K3s 1.36 and linux/arm64 while keeping private topology out of public files.
4. Regenerate committed artifacts only through the repository renderer.

## Acceptance criteria

- [x] Source and generated artifacts identify CNPG 1.30.0 and Barman Cloud plugin 0.14.0 exactly.
- [x] Immutable source evidence is validated and no resolved secret or PostgreSQL operand image changes.
- [x] Public rendering and validation pass.

## Verification

- `source bin/activate-hermit && homelab argocd render --all && ./scripts/validate.sh` — render is deterministic and validation reports zero failures.
- `agent-workspace repo-tasks validate --root .` — lifecycle contract is valid.

## Blockers

- None

## Completion handoff

- Summary: Pinned the CNPG v1.30.0 release commit and added the Barman Cloud plugin v0.14.0 release asset with rendered source-integrity evidence; no operand image or cluster mutation was added.
- Files changed: `argocd/infrastructure/cnpg/kustomization.yaml`, `argocd/infrastructure/cnpg/source-integrity.yaml`, generated `artifacts/infrastructure/cnpg/`, `docs/cloudnativepg-platform.md`, and this task/milestone contract.
- Observed verification: `homelab argocd render --path argocd/infrastructure/cnpg --output artifacts/infrastructure/cnpg`, `homelab argocd render --all`, `./scripts/validate.sh` (370 resources, 260 valid, 0 invalid, 0 errors, 110 skipped), and `agent-workspace repo-tasks validate --root .` passed.
- Follow-ups: Review the exact 1.27.0-to-1.30.0 manifest diff, establish/restore-test current private CNPG backups, and obtain current-session authorization before reconciliation.
- Delivery: https://github.com/nandiheath/homelab-public/pull/49
