# HLP-029 — Fix OMP config path resolution

- Status: ready-for-rollup
- Owner: Main
- Milestone: HLP-M012
- Depends on: none

## Owned paths

- `ansible/roles/omp_codex/**`
- `tests/ansible_omp_codex/**`
- `tasks/planned/HLP-029-fix-omp-config-path.md`
- `tasks/running/HLP-029-fix-omp-config-path.md`
- `tasks/milestones/planned/HLP-M012-fix-omp-config-path.md`
- `tasks/milestones/running/HLP-M012-fix-omp-config-path.md`

## Goal

Fix the first-install failure caused by passing an absolute `PI_CONFIG_DIR` to OMP, which resolves that value beneath HOME and leaves the reviewed token path absent.

## Implementation

1. Pass `.omp` to OMP processes while continuing to manage files through the reviewed absolute state-directory paths.
2. Remove only the deterministic incorrectly nested config directories produced by the defective absolute-path invocation.
3. Add focused fixtures that fail on absolute `PI_CONFIG_DIR` use and missing cleanup.

## Acceptance criteria

- [x] Broker and gateway token commands resolve to the reviewed managed paths under each dedicated service HOME.
- [x] The role removes only the known incorrectly nested config directories and retains all hardened identity, mode, listener, firewall, and mutation-authorization invariants.
- [x] Focused and repository validation pass without exposing token values.

## Verification

- `tests/ansible_omp_codex/run-fixtures.sh` — corrected path and cleanup assertions pass; weakened variants fail.
- `./scripts/validate-ansible.sh` — production-profile lint, syntax, and fixtures pass.
- `./scripts/validate.sh` — complete public validation passes.

## Blockers

- None

## Completion handoff

- Summary: OMP now receives the supported HOME-relative `.omp` config directory while Ansible retains absolute managed paths; the role removes the exact nested trees created by the defective absolute-path invocation.
- Files changed: `ansible/roles/omp_codex/{defaults,tasks,templates}/`, `tests/ansible_omp_codex/`, and this task/milestone contract.
- Observed verification: The focused suite accepted the corrected relative path, removed credential-shaped nested fixtures, retained the gateway credential wrapper, and rejected 20 weakened variants. `ansible-lint` passed with zero failures/warnings across 63 files; lifecycle fixtures and entrypoints passed; complete manifest validation reported 371 resources, 260 valid, 0 invalid, 0 errors, and 111 skipped. No token value was printed.
- Follow-ups: Merge the reviewed correction before rerunning the guarded live role. The failed first attempt created only pre-service host files/users plus one incorrectly nested generated broker token; the corrected role removes that tree before creating reviewed broker/gateway tokens.
