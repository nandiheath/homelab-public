# HLP-021 — Install pinned Ansible collections in CI

- Status: running
- Owner: Main
- Milestone: HLP-M003
- Depends on: none

## Owned paths

- `.github/workflows/render.yaml`
- `argocd/infrastructure/argocd/values.yaml`
- `scripts/render.sh`
- `scripts/validate.sh`
- `tasks/planned/HLP-021-install-ci-ansible-collections.md`
- `tasks/running/HLP-021-install-ci-ansible-collections.md`

## Goal

Make the authoritative GitHub Actions lifecycle validation resolve every pinned Ansible collection declared by the repository.

## Implementation

Install `ansible/collections/requirements.yml` with `ansible-galaxy` before `validate-ansible.sh`. Make authoritative validation use canonical public identifiers, validate the Argo RBAC GitHub username, and keep placeholder replacement compatible with controller Bash 3.2 and GitHub Actions Bash 5 so both render the same artifact.

## Acceptance criteria

- GitHub Actions installs `ansible.posix` at the repository-pinned version.
- `validate-ansible.sh` resolves `ansible.posix.sysctl` in a clean runner.
- A clean default render preserves the canonical unquoted Argo RBAC GitHub username.
- The full pull-request validation check passes.

## Verification

- `ansible-galaxy collection install -r ansible/collections/requirements.yml -p ansible/collections`
- `./scripts/validate-ansible.sh`
- GitHub Actions `Render and validate`

## Blockers

None.

## Completion handoff

- Summary:
- Files changed:
- Observed verification:
- Follow-ups:
