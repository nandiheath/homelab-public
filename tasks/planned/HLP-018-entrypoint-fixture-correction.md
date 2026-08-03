# HLP-018 — Entrypoint fixture correction

- Status: planned
- Owner: unassigned
- Depends on: HLP-013, HLP-014, HLP-015, HLP-016, HLP-017

## Owned paths

- `scripts/validate-ansible.sh`
- `tests/ansible_lifecycle/`
- `.github/workflows/render.yaml`
- `tasks/planned/HLP-018-entrypoint-fixture-correction.md`

## Goal

Prove actual mutating entrypoints, not only the shared role, stop before sentineled remote/delegated mutation and accepted fixtures reach the expected transaction.

## Acceptance criteria

- Every entrypoint rejects missing, boolean, stale-cluster, wrong-source, wrong-target, and wrong confirmation before its sentinel.
- Accepted reset proves no backup inputs; accepted upgrades prove only both approved boundaries.
- Fixtures cover kernel reboot sequence, install membership/token boundary, upgrade cordon failure behavior, network ordering, and GitOps always cleanup fully offline.

## Verification

- `. ./bin/activate-hermit && ./scripts/validate-ansible.sh`

## Completion handoff

- Summary:
- Files changed:
- Observed verification:
- Follow-ups:
