# HLP-M011 — Secure Raspberry Pi OMP boundary

- Status: ready-for-rollup
- Owner: Main

## Goal

Provide a reusable, fail-closed Ansible installation contract for a checksum-pinned ARM64 OMP auth broker and authenticated gateway on one privately selected K3s node, without performing host installation, OAuth login, cluster mutation, or secret retrieval.

## Tasks

- [x] HLP-028 — Install the guarded Raspberry Pi OMP boundary

## Acceptance criteria

- [x] The public role accepts only the reviewed OMP Linux ARM64 release, keeps the credential broker loopback-only, requires gateway bearer authentication, and restricts gateway ingress to explicit private CIDRs.
- [x] Broker and gateway run as separate unprivileged users with root-managed configuration, exact state-file modes, dependency ordering, and complete systemd hardening.
- [x] Focused hostile-input fixtures, public repository validation, private repository validation, and the public/private repository graph validation pass without contacting a host, OAuth provider, cluster, or secret store.

## Verification

- Scenario or command: run `tests/ansible_omp_codex/run-fixtures.sh`, `./scripts/validate-ansible.sh`, `./scripts/validate.sh`, private `make validate`, and `./scripts/validate-repository-graph.sh` after the private inventory contract is integrated.
- Expected observation: all validation is offline and reports zero failures; rendered units expose no secret values, broad listener, unauthenticated gateway mode, or missing hardening directive.

## Blockers

- None

## Completion handoff

- Tasks rolled up: HLP-028 via public pull request #55; private dependency HL-M019 via private pull requests #126 and #127.
- Observed milestone verification: Focused OMP fixtures accepted the bounded ARM64 contract and exact gateway-token rotation while rejecting 19 hostile or weakened contracts. `./scripts/validate-ansible.sh` reported zero failures and warnings across 62 files, then passed lifecycle and entrypoint fixtures. `./scripts/validate.sh` reported 371 resources, 260 valid, 0 invalid, 0 errors, and 111 schema-skipped. Private `make validate`, the integrated production-inventory syntax check, and the public/private graph validation passed offline.
- Project status updated: `PROJECT_STATUS.md` records the reusable guarded OMP boundary and explicitly distinguishes reviewed desired state from host installation, OAuth login, and deployment.
- Follow-ups: Host apply and Codex OAuth login require separate explicit authorization. WK-P003 service implementation, private Kubernetes deployment, and live acceptance remain separate tasks.
