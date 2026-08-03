# HLP-014 — Install membership correction

- Status: running
- Owner: InstallCorrection
- Depends on: HLP-011

## Owned paths

- `ansible/playbooks/install.yaml`
- `ansible/roles/k3s_server/`
- `ansible/roles/k3s_agent/`
- `tasks/planned/HLP-014-install-membership-correction.md`

## Goal

Make clean install form and prove exactly three healthy voting embedded-etcd members without exposing tokens.

## Acceptance criteria

- Initial and joining servers install serially with pinned installer/binary checksums and root mode-0600 token files only.
- Each join proves exact node identity, learner promotion, healthy expected member count, and token absence from arguments/units/facts.
- Controller kubeconfig exports only after three healthy voting members; optional agents receive token files without plaintext exposure.

## Verification

- Focused Ansible lint and localhost/sentineled fixtures.

## Completion handoff

- Summary:
- Files changed:
- Observed verification:
- Follow-ups:
