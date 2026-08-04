# HLP-021 — Install pinned Ansible collections in CI

- Status: ready-for-rollup
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

- Summary: Installed the pinned Ansible collection in CI and made canonical rendering deterministic across controller Bash 3.2 and GitHub Actions Bash 5.
- Files changed: `.github/workflows/render.yaml`; `argocd/infrastructure/argocd/values.yaml`; `artifacts/infrastructure/argocd/configmap_argocd-rbac-cm.yml`; `scripts/render.sh`; `scripts/validate.sh`; `tasks/milestones/running/HLP-M003-guarded-cluster-lifecycle.md`; `tasks/running/HLP-021-install-ci-ansible-collections.md`.
- Observed verification: Pinned collection installation completed; `./scripts/validate-ansible.sh` passed 50 linted files plus lifecycle and entrypoint fixtures; two consecutive `./scripts/validate.sh` runs rendered 352 resources with 245 valid, 0 invalid, and 0 errors; GitHub Actions `Render and validate` passed on PR #7 after resolving both failures.
- Follow-ups: None.
