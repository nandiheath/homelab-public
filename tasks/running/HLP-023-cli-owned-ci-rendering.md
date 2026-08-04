# HLP-023 — Adopt CLI-owned CI rendering

- Status: ready-for-rollup
- Owner: Main
- Milestone: HLP-M005
- Depends on: none

## Owned paths

- `.github/workflows/render.yaml`
- `Makefile`
- `README.md`
- `bin/hermit.hcl`
- `bin/homelab`
- `bin/.homelab-*.pkg`
- `tasks/planned/HLP-023-cli-owned-ci-rendering.md`
- `tasks/running/HLP-023-cli-owned-ci-rendering.md`
- `tasks/milestones/planned/HLP-M005-ci-render-workflow.md`
- `tasks/milestones/running/HLP-M005-ci-render-workflow.md`
- `PROJECT_STATUS.md`

## Goal

Reduce the public render workflow to the released CLI's CI mode while retaining exact changed-source and artifact-only commit behavior.

## Implementation

1. Pin the released CLI, replace workflow-side change detection and Git scripts with `--ci` and `--commit-and-push` invocations separated by repository validation, and update operator documentation.

## Acceptance criteria

- [x] The workflow contains no custom changed-source loop or Git commit/push script.
- [x] Source changes and deletions update only their matching artifact directories.
- [x] No-change and generated-only runs create no additional commit.

## Verification

- `make render && git diff --exit-code -- artifacts/` — full local output remains stable.
- `make validate` — repository validation passes.
- Pull-request source and generated-only workflow runs — the first commits only real artifact drift and the follow-up is a no-op.

## Blockers

- None

## Completion handoff

- Summary: Pinned `homelab-0.3.2` and reduced the public workflow to CLI-owned changed-source rendering and explicit artifact commit/push calls, retaining lifecycle and manifest validation between them.
- Files changed: `.github/workflows/render.yaml`; `PROJECT_STATUS.md`; `README.md`; `bin/homelab`; `bin/.homelab-0.3.2.pkg`; task contracts.
- Observed verification: `make render` preserved `artifacts/`; `make validate` passed 50 Ansible files, lifecycle fixtures, and 352 rendered resources with 245 valid, 0 invalid, 0 errors, and 107 schema skips. Pull-request run `30881674044` rendered a changed Cilium source and pushed bot artifact commit `a09dd3084c8c1183e9a158745ef05d9fd4b1a807`; cleanup run `30881904983` pushed the inverse artifact commit. Generated-only workflow-dispatch run `30882148108` succeeded at head `0f3e97def2b12436289fe98d997afa596e179ec5` without changing the branch head.
- Follow-ups: None.
