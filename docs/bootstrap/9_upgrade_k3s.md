# 9. Upgrade K3s

**Applies to:** cluster upgrade only. **Do not use this step for initial bootstrap or destructive rebuild.** Those routes install the final version directly in step 5.

## Overview

Move a healthy existing cluster across one explicitly reviewed source-to-target K3s bridge, one server at a time, while preserving etcd quorum, workloads, PVCs, Cilium, and GitOps ownership.

## Current disabled boundary

`operation_guard_upgrade_paths` is empty by default. Therefore no in-place K3s upgrade is currently authorized, even though `ansible/playbooks/upgrade.yaml` exists. This fail-closed choice is deliberate: do not add an ad-hoc variable, bypass the guard, or reuse the direct-install confirmation.

Before this step can run, a reviewed change must declare exactly one approved source-to-target mapping, both K3s release records and ARM64 checksums, expected embedded-etcd versions, compatible Cilium artifacts, and passing fixture/entrypoint proof. If that contract is absent, stop and use no upgrade command.

## Procedure after a path is approved

1. Complete step 2 and capture a non-secret baseline of nodes, three voting etcd members, K3s/etcd versions, Cilium, Applications, PVCs, PDBs, storage health, and controller revisions.
2. Require a uniform source version exactly matching the approved mapping. Require healthy API, etcd quorum, all nodes, Cilium, GitOps, storage, and workloads. Reject learners, stale members, version skew, unavailable PDB budget, or desired-state drift.
3. Set the reviewed versions from private inventory; never infer them from a release channel:

   ```bash
   export K3S_SOURCE="<approved-source-version>"
   export K3S_TARGET="<approved-target-version>"
   ```

4. Obtain fresh exact authorization:

   ```text
   UPGRADE <cluster-id> FROM <approved-source-version> TO <approved-target-version>
   ```

5. Run the guarded playbook:

   ```bash
   ansible-playbook -i "$INVENTORY" ansible/playbooks/upgrade.yaml \
     -e "kubeconfig=$CONTROLLER_KUBECONFIG" \
     -e "controller_kubectl=$CONTROLLER_KUBECTL" \
     -e "upgrade_source_version=$K3S_SOURCE" \
     -e "upgrade_target_version=$K3S_TARGET" \
     -e "{\"operation_guard_confirmation\":\"UPGRADE ${CLUSTER_ID} FROM ${K3S_SOURCE} TO ${K3S_TARGET}\"}"
   ```

6. Let the playbook drain and upgrade secondary servers serially, then the initial server last. Do not bypass eviction or PDBs, manually reorder members, or upgrade more than one server at a time.
7. After every node, require strict SSH recovery, Ready state, expected target K3s and etcd version, healthy quorum/member count, Cilium health, and successful uncordon before continuing.
8. Require the final uniform target cluster proof, then run step 8. Compare Applications and PVCs with the baseline and require no unintended deletion or replacement.

## Expected boundary

All three servers run the approved target K3s/etcd versions with healthy quorum and no skew; Cilium, GitOps, storage, applications, and PVCs are preserved. Kernel maintenance, GitOps bootstrap, and destructive reset remain separate authorization boundaries.
