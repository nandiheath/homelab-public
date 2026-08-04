# 5. Install K3s

**Applies to:** initial bootstrap or destructive rebuild only. **Do not use this step for an in-place cluster upgrade; use step 9.**

## Overview

Create the clean three-server K3s cluster directly at the inventory-declared final version with embedded etcd. The install deliberately has no CNI, kube-proxy, packaged network policy, Traefik, or ServiceLB; step 6 supplies Cilium.

## Procedure

1. Require the step 2 preflight, the exact pinned kernel from step 4, and complete absence of prior K3s, etcd, CNI, Longhorn, token, and controller-kubeconfig state.
2. Confirm private inventory declares the final K3s version, installer checksum, ARM64 binary checksum, embedded-etcd version, node names, API endpoint, Pod CIDR, Service CIDR, and cluster DNS. Do not pass free-form server arguments.
3. Obtain the current exact authorization. For the current runbook contract it is:

   ```text
   INSTALL K3S v1.36.2+k3s1 ON <cluster-id>
   ```

4. Run the guarded install:

   ```bash
   ansible-playbook -i "$INVENTORY" ansible/playbooks/install.yaml \
     -e "kubeconfig=$CONTROLLER_KUBECONFIG" \
     -e "{\"operation_guard_confirmation\":\"INSTALL K3S v1.36.2+k3s1 ON ${CLUSTER_ID}\"}"
   ```

5. Let the playbook install the initial server, validate it, then join each secondary server serially. Do not manually copy or place tokens in command arguments. Tokens may exist only in root-owned mode-`0600` files.
6. After each join, require the expected node identity, learner promotion, healthy voting-member count, and exact K3s/etcd versions. No learner, stale member, or version skew may remain.
7. Export the controller kubeconfig only after all three voting members are healthy. Require it to be controller-owned mode `0600` and to contain only the approved endpoints.
8. Verify every server uses the inventory-declared cluster/service/DNS ranges and has Flannel, kube-proxy, the K3s network-policy controller, Traefik, and ServiceLB disabled.
9. Confirm every node is `NotReady` only with `KubeletNotReady`/`NetworkPluginNotReady`; CoreDNS may remain pending. Any Ready node, active default CNI, unexpected Pod CIDR, or packaged component is a hard stop.
10. Record non-secret version, membership, argument-shape, file-mode, and pre-CNI evidence. Install authorization does not authorize Cilium.

## Expected boundary

Three voting embedded-etcd servers run the final K3s version, but the nodes are intentionally NotReady because no CNI exists. This is expected only until step 6; do not install a temporary or default CNI to hide it.
