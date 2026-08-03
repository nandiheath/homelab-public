# HLP-004 — Raspberry Pi kernel maintenance

- Status: planned
- Owner: unassigned
- Depends on: HLP-001, HLP-002

## Owned paths

- `ansible/playbooks/kernel_upgrade.yaml`
- `ansible/playbooks/reboot.yaml`
- `ansible/roles/raspi_kernel/`
- `tasks/planned/HLP-004-raspi-kernel-maintenance.md`

## Goal

Activate only the approved Raspberry Pi kernel package release through safe serial reboot modes.

## Implementation

Validate Ubuntu arm64 Raspberry Pi identity, package/boot integrity, target package state, retained prior kernel, and boot capacity. Install only exact kernel packages. Support cluster-present shared maintenance and cluster-absent proof of K3s absence. Reboot one host at a time; require SSH recovery, exact kernel release, cleared marker, expected boot files, retained fallback, and continued K3s absence.

## Acceptance criteria

- No dist-upgrade, generic latest, autoremove, firmware, bootloader, or OS-release upgrade occurs.
- Cluster-absent mode refuses hosts with K3s state.
- Node non-return stops before another reboot.

## Verification

- Localhost fixture cases for package, capacity, and cluster-mode guards.

## Blockers

- HLP-001 and HLP-002 must be rolled up.

## Completion handoff

- Summary:
- Files changed:
- Observed verification:
- Follow-ups:
