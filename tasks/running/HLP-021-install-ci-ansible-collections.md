# HLP-021 — Install pinned Ansible collections in CI

- Status: running
- Owner: Main
- Milestone: HLP-M003
- Depends on: none

## Owned paths

- `.github/workflows/render.yaml`
- `tasks/planned/HLP-021-install-ci-ansible-collections.md`
- `tasks/running/HLP-021-install-ci-ansible-collections.md`

## Goal

Make the authoritative GitHub Actions lifecycle validation resolve every pinned Ansible collection declared by the repository.

## Implementation

Install `ansible/collections/requirements.yml` with `ansible-galaxy` after the pinned Ansible tools are installed and before `validate-ansible.sh` runs.

## Acceptance criteria

- GitHub Actions installs `ansible.posix` at the repository-pinned version.
- `validate-ansible.sh` resolves `ansible.posix.sysctl` in a clean runner.
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
