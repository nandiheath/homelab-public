# HLP-013 — Kernel runtime correction

- Status: running
- Owner: KernelCorrection
- Depends on: HLP-011

## Owned paths

- `ansible/playbooks/kernel_upgrade.yaml`
- `ansible/playbooks/reboot.yaml`
- `ansible/roles/raspi_kernel/`
- `tasks/planned/HLP-013-kernel-runtime-correction.md`

## Goal

Make the documented guarded kernel command perform the complete exact-package serial activation transaction.

## Acceptance criteria

- Direct exact authorization works without a nonexistent parent context.
- Package audit/check commands execute correctly; package, boot-capacity, retained-fallback, and K3s-absence gates fail closed.
- Each host reboots serially and verifies exact kernel, cleared reboot marker, boot files, fallback, and K3s absence before advancing.

## Verification

- Focused Ansible lint and localhost fixtures.

## Completion handoff

- Summary:
- Files changed:
- Observed verification:
- Follow-ups:
