# 3. Reset an existing cluster

**Applies to:** destructive rebuild only. **Not an initial-host or routine cluster-upgrade step.** Skip this step for pristine hosts with no K3s or Kubernetes state.

## Overview

Destroy the existing K3s runtime and all Kubernetes application data while preserving Ubuntu, SSH access, host identity, networking, boot firmware, and the retained fallback kernel.

## Procedure

1. Complete step 2. Require a healthy, identity-matched three-server source cluster and record the read-only preflight report: K3s and etcd versions, voting members, nodes, Applications, PVCs, kernel state, and host-preservation hashes.
2. Explicitly decide whether a backup-free reset is acceptable. This repository has no approved backup/restore contract; the playbook creates no backup, snapshot, token export, or recovery bundle. If recovery is required, stop until separate backup/DR work is approved.
3. Obtain this fresh exact authorization in the current conversation:

   ```text
   RESET <cluster-id> AND DESTROY ALL KUBERNETES DATA
   ```

4. Run only the guarded playbook:

   ```bash
   ansible-playbook -i "$INVENTORY" ansible/playbooks/reset.yaml \
     -e "kubeconfig=$CONTROLLER_KUBECONFIG" \
     -e "controller_kubectl=$CONTROLLER_KUBECTL" \
     -e "{\"operation_guard_confirmation\":\"RESET ${CLUSTER_ID} AND DESTROY ALL KUBERNETES DATA\"}"
   ```

5. Let the playbook remove agents first, secondary servers serially, and the initial server last. Do not interrupt a healthy transaction.
6. If a partial wipe occurs, diagnose the exact failed member and resume the guarded reset until all cluster state is absent. Never attempt to rejoin a partly deleted member or restore stale etcd state.
7. Verify every host still has the approved hostname, OS, SSH key, network identity, boot firmware, and fallback kernel. Require K3s services, processes, uninstall scripts, data directories, embedded etcd, CNI state, Longhorn state, TCP 6443 listeners, tokens, and controller kubeconfig to be absent.
8. Record non-secret completion evidence. The reset authorization is consumed and does not authorize step 4 or 5.

## Expected boundary

All three preserved hosts are reachable through strict SSH and contain no cluster state. The procedure is intentionally irreversible and backup-free. The next mutation is the separately authorized pinned-kernel activation in step 4.
