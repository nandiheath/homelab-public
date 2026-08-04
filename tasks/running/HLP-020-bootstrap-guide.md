# HLP-020 - Numbered cluster bootstrap guide

- Status: ready-for-rollup
- Owner: Main
- Milestone: HLP-M003
- Depends on: none

## Owned paths

- `docs/bootstrap/`
- `README.md`
- `tasks/planned/HLP-020-bootstrap-guide.md`
- `tasks/running/HLP-020-bootstrap-guide.md`

## Goal

Provide a concise numbered guide that a future agent can follow to bootstrap the complete three-node K3s cluster and distinguish bootstrap-only work from reusable upgrade procedures.

## Implementation

Add a bootstrap index and numbered step documents covering Raspberry Pi installation, controller and private-input preparation, destructive rebuild boundaries, pinned kernel activation, direct K3s installation, temporary private Cilium bootstrap, GitOps reconciliation, final acceptance, and future K3s upgrades. Identify temporary or intentionally unsafe states and name the later step that resolves each one.

## Acceptance criteria

- Every bootstrap stage has a numbered Markdown guide with a short overview and actionable agent procedure.
- Every guide labels whether it applies to initial bootstrap, destructive rebuild, routine cluster upgrade, or a combination.
- Temporary or currently disabled choices are explicit, with the resolving future step named.
- Root documentation links to the bootstrap index.
- Repository validation passes without infrastructure access or mutation.

## Verification

- `./scripts/validate.sh`
- Link and sequence inspection from `docs/bootstrap/README.md`

## Blockers

None.

## Completion handoff

- Summary: Added a numbered initial-host, rebuild, and upgrade guide with explicit authorization gates, expected intermediate states, failure handling, and the future step that resolves each temporary compromise.
- Files changed: `README.md`; `docs/bootstrap/README.md`; `docs/bootstrap/1_install_raspberry_pi.md` through `docs/bootstrap/9_upgrade_k3s.md`; `tasks/running/HLP-020-bootstrap-guide.md`.
- Observed verification: `./scripts/validate.sh` rendered 352 resources with 245 valid, 0 invalid, 0 errors, and 107 skipped schemas; the repository Markdown link checker reported all local links valid; `./scripts/validate-repository-graph.sh ../homelab-private` reported the rendered repository graph valid. No infrastructure was contacted or mutated.
- Follow-ups: The live HLP-005 GitOps/TLS acceptance boundary remains separately authorized work. In-place K3s upgrade remains fail-closed until a reviewed inventory path, release checksums, compatibility evidence, and fixtures are added.
