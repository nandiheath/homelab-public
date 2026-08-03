# HLP-016 — Reset preservation correction

- Status: running
- Owner: ResetCorrection
- Depends on: HLP-011

## Owned paths

- `ansible/playbooks/reset.yaml`
- `ansible/roles/k3s_reset/`
- `tasks/planned/HLP-016-reset-preservation-correction.md`

## Goal

Make backup-free reset revalidate exact live identity/etcd state and prove all preserved host state after each wipe.

## Acceptance criteria

- Preflight proves three healthy voting current members and exact hosts immediately before accepting confirmation; non-secret report includes required facts.
- Post-wipe recomputes and compares users, SSH files/keys, network config/address identity, boot firmware, hostname, OS, and kernel.
- Cluster-owned service/process/script/config/datastore/CNI/Longhorn/API/kubeconfig absence is proven; partial failure touches no remaining host.

## Verification

- Focused Ansible lint and sentineled reset fixtures without backup variables.

## Completion handoff

- Summary:
- Files changed:
- Observed verification:
- Follow-ups:
