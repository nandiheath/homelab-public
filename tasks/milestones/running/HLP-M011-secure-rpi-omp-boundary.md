# HLP-M011 — Secure Raspberry Pi OMP boundary

- Status: running
- Owner: Main

## Goal

Provide a reusable, fail-closed Ansible installation contract for a checksum-pinned ARM64 OMP auth broker and authenticated gateway on one privately selected K3s node, without performing host installation, OAuth login, cluster mutation, or secret retrieval.

## Tasks

- [ ] HLP-028 — Install the guarded Raspberry Pi OMP boundary

## Acceptance criteria

- [ ] The public role accepts only the reviewed OMP Linux ARM64 release, keeps the credential broker loopback-only, requires gateway bearer authentication, and restricts gateway ingress to explicit private CIDRs.
- [ ] Broker and gateway run as separate unprivileged users with root-managed configuration, exact state-file modes, dependency ordering, and complete systemd hardening.
- [ ] Focused hostile-input fixtures, public repository validation, private repository validation, and the public/private repository graph validation pass without contacting a host, OAuth provider, cluster, or secret store.

## Verification

- Scenario or command: run `tests/ansible_omp_codex/run-fixtures.sh`, `./scripts/validate-ansible.sh`, `./scripts/validate.sh`, private `make validate`, and `./scripts/validate-repository-graph.sh` after the private inventory contract is integrated.
- Expected observation: all validation is offline and reports zero failures; rendered units expose no secret values, broad listener, unauthenticated gateway mode, or missing hardening directive.

## Blockers

- None

## Completion handoff

- Tasks rolled up:
- Observed milestone verification:
- Project status updated:
- Follow-ups:
