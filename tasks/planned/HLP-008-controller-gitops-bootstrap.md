# HLP-008 — Controller GitOps bootstrap

- Status: planned
- Owner: unassigned
- Depends on: HLP-001, HLP-007

## Owned paths

- `ansible/playbooks/bootstrap_gitops.yml`
- `tasks/planned/HLP-008-controller-gitops-bootstrap.md`

## Goal

Bootstrap GitOps only after the final bare-cluster roll using controller-local kubectl and ephemeral credentials.

## Implementation

Remove the install playbook import. Delegate every kubectl operation to localhost using pinned kubectl and controller kubeconfig. Generate required 1Password Connect and Argo GitHub App credential manifests as mode-0600 controller-temporary files immediately before no-log apply; validate metadata only and delete them in an always path. Preserve controller order: Cilium, Argo CD, External Secrets, 1Password Connect, temporary credentials, repository credentials, public root, then private root.

## Acceptance criteria

- Bootstrap cannot reinstall or change K3s.
- No plaintext secret or rendered artifact is copied to a Pi; temporary files are removed on success, failure, or interruption.
- Wrong authorization stops before any delegated apply.

## Verification

- Localhost sentineled fixture for ordering, authorization, and always cleanup.

## Blockers

- HLP-001 and HLP-007 must be rolled up.

## Completion handoff

- Summary:
- Files changed:
- Observed verification:
- Follow-ups:
