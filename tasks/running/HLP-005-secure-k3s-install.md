# HLP-005 — Secure K3s install

- Status: running
- Owner: SecureK3sInstall
- Depends on: HLP-001, HLP-002

## Owned paths

- `ansible/playbooks/install.yaml`
- `ansible/roles/k3s_server/`
- `ansible/roles/k3s_agent/`
- `tasks/planned/HLP-005-secure-k3s-install.md`

## Goal

Install the pinned initial K3s release with checksum verification, secret-safe tokens, and serialized embedded-etcd membership.

## Implementation

Validate the pinned installer and arm64 binary checksums for `k3s_install_version`. Use no-log token handling and root-only 0600 token files with `--token-file` or `K3S_TOKEN_FILE`; delete legacy exposed token settings and assert no service/process/fact-cache exposure. Install initial server then join members one at a time, confirming exact identity, learner promotion, and member count after each join. Export the controller kubeconfig only after three healthy members.

## Acceptance criteria

- The installer and binary fail closed on checksum mismatch.
- No K3s token appears in process arguments, rendered units, or cached facts.
- The only successful install path forms exactly three healthy voting members.

## Verification

- Localhost sentineled install/token fixtures and Ansible syntax/lint checks.

## Blockers

- HLP-001 and HLP-002 must be rolled up.

## Completion handoff

- Summary:
- Files changed:
- Observed verification:
- Follow-ups:
