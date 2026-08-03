# HLP-017 — Bootstrap completion correction

- Status: running
- Owner: BootstrapCorrection
- Depends on: HLP-011

## Owned paths

- `ansible/playbooks/bootstrap_network.yaml`
- `ansible/playbooks/bootstrap_gitops.yml`
- `tasks/planned/HLP-017-bootstrap-completion-correction.md`

## Goal

Make controller network and GitOps bootstrap enforce full artifact, ordering, health, and ephemeral 1Password credential contracts.

## Acceptance criteria

- Network bootstrap validates exact five endpoint differences and waits for all nodes, API, and Cilium.
- GitOps resolves credential content only through controller environment/1Password boundary, validates Secret metadata without values, applies in required order, waits for repo credentials and both roots, and always removes temporary files.
- No command runs on or copies plaintext/artifacts to a Pi; GitOps never installs K3s.

## Verification

- Focused Ansible lint and controller sentinels covering ordering and failure cleanup.

## Completion handoff

- Summary:
- Files changed:
- Observed verification:
- Follow-ups:
