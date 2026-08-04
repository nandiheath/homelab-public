# HLP-022 — Adopt homelab rendered-artifact delivery

- Status: running
- Owner: Main
- Milestone: HLP-M004
- Depends on: none

## Owned paths

- `.github/workflows/render.yaml`
- `AGENTS.md`
- `README.md`
- `docs/bootstrap/2_prepare_controller.md`
- `docs/operations-runbook.md`
- `bin/hermit.hcl`
- `bin/homelab`
- `bin/.homelab-*.pkg`
- `scripts/render.sh`
- `scripts/validate.sh`
- `tasks/running/HLP-022-rendered-artifact-delivery.md`
- `tasks/milestones/running/HLP-M004-rendered-artifact-delivery.md`

## Goal

Use the released `homelab` CLI as the sole renderer and make pull-request CI commit only artifacts associated with changed source directories.

## Implementation

Install the pinned CLI through Hermit, delete the legacy renderer, invoke `homelab argocd render` from validation and documentation, and change CI to reject a dirty checkout before rendering. Determine changed direct children under the Argo CD source root, render or delete only their corresponding output directories, validate the repository, and commit artifact changes to the pull-request branch as a distinct generated commit. A generated-only follow-up run must perform no render and create no commit.

## Acceptance criteria

- No tracked callsite references `scripts/render.sh`.
- Local validation uses the pinned released `homelab argocd render` command.
- Pull-request CI fails if the checkout is dirty before rendering.
- Pull-request CI renders only changed source directories and handles deleted source directories.
- Artifact changes are committed separately; a generated-only follow-up run is a no-op.
- The workflow retains credential-free validation and does not deploy.

## Verification

- `source ./bin/activate-hermit && ./scripts/validate-ansible.sh && ./scripts/validate.sh`
- `git diff --exit-code -- artifacts/` after a full local render.
- Exercise the pull-request workflow with a source-only change and inspect both runs.

## Blockers

None.

## Completion handoff

- Summary:
- Files changed:
- Observed verification:
- Follow-ups:
