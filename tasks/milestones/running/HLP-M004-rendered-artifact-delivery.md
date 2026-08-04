# HLP-M004 — Rendered artifact delivery

- Status: running
- Owner: Main

## Goal

Make the released `homelab` CLI the only manifest renderer and have CI commit only artifacts affected by changed source directories.

## Tasks

- [ ] HLP-022 — Adopt homelab rendered-artifact delivery

## Acceptance criteria

- [ ] Public and private repositories use the same released `homelab argocd render` command and no legacy render script remains.
- [ ] Pull-request CI starts from a clean checkout, renders only changed source directories, and commits resulting artifact changes as a separate commit.
- [ ] A second run with only the generated commit is a clean no-op.
- [ ] Local validation and both repository workflows pass without credentials or infrastructure mutation.

## Verification

- `source ./bin/activate-hermit && ./scripts/validate-ansible.sh && ./scripts/validate.sh`
- Exercise the pull-request workflow with a source-only change and observe its generated follow-up commit.
- Re-run the workflow at the generated commit and observe no render commit.

## Completion handoff

- Tasks rolled up:
- Observed milestone verification:
- Project status updated:
- Follow-ups:
