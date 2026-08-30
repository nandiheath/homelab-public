# HLP-028 — Install the guarded Raspberry Pi OMP boundary

- Status: running
- Owner: Main
- Milestone: HLP-M011
- Depends on: none

## Owned paths

- `ansible/roles/omp_codex/`
- `ansible/playbooks/install_omp_codex.yaml`
- `tests/ansible_omp_codex/`
- `tasks/running/HLP-028-install-rpi-omp-boundary.md`
- `tasks/milestones/running/HLP-M011-secure-rpi-omp-boundary.md`

## Goal

Provide a reproducible, checksum-pinned, hardened OMP auth broker and authenticated gateway contract for exactly one privately selected ARM64 node without performing live installation or OAuth login.

## Implementation

1. Add a reusable role and playbook with exact architecture, version, checksum, listener, CIDR, authentication, and file-mode validation.
2. Install the reviewed OMP Linux ARM64 binary under a versioned path and manage separate broker and gateway system users, state directories, token bootstrap, and systemd units.
3. Keep the broker on loopback, bind the authenticated gateway only to an explicit private address, and install a dedicated nftables input rule that drops gateway traffic outside explicit source CIDRs.
4. Add hostile-input and rendered-unit fixtures covering the fail-closed boundary without contacting remote systems.

## Acceptance criteria

- [ ] Wrong architecture, version, checksum, listener, missing gateway authentication, broad ingress CIDR, unsafe state/token mode, and prohibited legacy bypass values fail before installation.
- [ ] The broker is loopback-only; the gateway never uses `--no-auth`; token generation and root-managed systemd credential propagation expose no credential value in source or task output; only a fixed-GID, read-only gateway bearer copy is available for exact host-file projection.
- [ ] Both units use separate unprivileged users, exact dependency ordering, restart policy, least-writable state, and the complete required systemd hardening set.
- [ ] Focused fixtures, Ansible syntax/lint validation, and repository validation pass offline.

## Verification

- `tests/ansible_omp_codex/run-fixtures.sh` — valid ARM64 inputs pass and each hostile input or weakened unit contract fails closed.
- `source bin/activate-hermit && ansible-playbook --syntax-check ansible/playbooks/install_omp_codex.yaml && ./scripts/validate-ansible.sh && ./scripts/validate.sh` — public validation reports zero failures without remote access.
- `agent-workspace repo-tasks validate --root .` — lifecycle contract is valid.

## Blockers

- None

## Completion handoff

- Summary:
- Files changed:
- Observed verification:
- Follow-ups:
- Delivery:
