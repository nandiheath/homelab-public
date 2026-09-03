# HLP-M012 — Fix OMP service config path resolution

- Status: running
- Owner: Main

## Goal

Make the guarded Raspberry Pi OMP role use OMP's HOME-relative `PI_CONFIG_DIR` contract while retaining absolute managed file paths and removing artifacts created by the defective absolute-path invocation.

## Tasks

- [ ] HLP-029 — Fix OMP config path resolution

## Acceptance criteria

- [ ] A first live install creates broker and gateway tokens at the reviewed absolute managed paths, removes the incorrectly nested config directories, and converges the hardened services without exposing credential values.
- [ ] Offline fixtures reproduce the absolute-path failure and prove the corrected HOME-relative invocation and cleanup contract.

## Verification

- Scenario or command: focused OMP fixtures, production-profile Ansible syntax/lint, public repository validation, then the separately authorized guarded live rerun.
- Expected observation: offline checks pass; the live role converges with exact token ownership/modes and active broker, gateway, and firewall services.

## Blockers

- None

## Completion handoff

- Tasks rolled up:
- Observed milestone verification:
- Project status updated:
- Follow-ups:
