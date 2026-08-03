# HLP-010 — Ansible lifecycle validation

- Status: running
- Owner: Main
- Depends on: HLP-003, HLP-004, HLP-005, HLP-006, HLP-007, HLP-008, HLP-009

## Owned paths

- `scripts/validate-ansible.sh`
- `tests/ansible_lifecycle/`
- `.github/workflows/`
- `tasks/planned/HLP-010-ansible-lifecycle-validation.md`

## Goal

Provide committed offline validation for lifecycle playbooks and guards.

## Implementation

Pin Ansible Core/lint versions, lint changed roles/playbooks, syntax-check all playbooks, validate task lifecycle, and run localhost fixture inventory matrix with sentineled remote and delegated mutations. Cover missing, boolean, wrong-cluster, wrong-source, and wrong-target confirmations across reset, kernel, install, network bootstrap, both upgrade boundaries, and GitOps bootstrap. Prove reset's exact confirmation reaches the reset role without snapshot/bundle/signer variables; prove only the two upgrade boundaries pass.

## Acceptance criteria

- The command is non-destructive and runs fully offline against fixtures.
- Rejected confirmations cannot reach any sentineled mutation.
- CI runs the same validation without deployment credentials.

## Verification

- `. ./bin/activate-hermit && ./scripts/validate-ansible.sh`

## Blockers

- All listed dependencies must be rolled up.

## Completion handoff

- Summary:
- Files changed:
- Observed verification:
- Follow-ups:
