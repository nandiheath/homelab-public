# HLP-001 — Operation guard

- Status: running
- Owner: OperationGuard
- Depends on: none

## Owned paths

- `ansible.cfg`
- `ansible/inventory.example.yml`
- `ansible/roles/operation_guard/`
- `tasks/planned/HLP-001-operation-guard.md`

## Goal

Fail closed before lifecycle mutation unless the typed, exact authorization and controller/inventory safety gates pass.

## Implementation

Implement reusable `operation_guard` validation for exact string confirmations, cluster identity, source/target versions, required inventory shape, controller tool versions, host-key checking, and mode/ownership of kubeconfig or temporary credentials. Mutating imported playbooks accept only validated parent operation context; direct entry points still require their literal.

## Acceptance criteria

- Exact literals from the approved lifecycle plan are the only accepted confirmations.
- Missing, boolean, stale-cluster, wrong-source, wrong-target, or mismatched confirmation stops before privilege escalation, remote mutation, or delegated mutation.
- Host-key checking and controller-local sensitive-file modes fail closed.

## Verification

- Focused localhost fixture tests for every rejected confirmation and each accepted operation.

## Blockers

- None.

## Completion handoff

- Summary:
- Files changed:
- Observed verification:
- Follow-ups:
