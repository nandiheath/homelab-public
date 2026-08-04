# 6. Bootstrap private Cilium

**Applies to:** initial bootstrap or destructive rebuild only. **Not a routine cluster-upgrade step.**

## Overview

Install the private, inventory-derived Cilium artifact from the controller so nodes, CoreDNS, cluster networking, and DNS become healthy. The bootstrap uses a deliberately temporary Hubble configuration that step 7 must replace.

## Procedure

1. Require the exact step 5 boundary: three expected K3s nodes at the final version, each NotReady solely because the CNI is absent; three healthy voting etcd members; no Applications, PVCs, cert-manager API, default CNI, kube-proxy, packaged Traefik, or ServiceLB.
2. Re-run the public/private artifact proof. The private artifact may differ from public Cilium source only by the exact inventory-derived API endpoint substitutions and Pod CIDR substitution documented in the operations runbook.
3. Obtain fresh exact authorization:

   ```text
   BOOTSTRAP NETWORK <cluster-id>
   ```

4. Run from the controller:

   ```bash
   ansible-playbook -i "$INVENTORY" ansible/playbooks/bootstrap_network.yaml \
     -e "kubeconfig=$CONTROLLER_KUBECONFIG" \
     -e "controller_kubectl=$CONTROLLER_KUBECTL" \
     -e "private_cilium_artifact=$PRIVATE_CILIUM" \
     -e "{\"operation_guard_confirmation\":\"BOOTSTRAP NETWORK ${CLUSTER_ID}\"}"
   ```

5. Let the playbook create mode-restricted temporary copies, omit only the Hubble cert-manager `Certificate`, change only `hubble-disable-tls` from `"false"` to `"true"`, prove that transformation, apply it, and remove the temporary directory in `always`. Never hand-edit the committed final artifact.
6. Require the Cilium and Cilium Envoy DaemonSets, both Cilium operator replicas, all nodes, and CoreDNS to roll out. Require `cilium-dbg status` to return `OK` from every agent.
7. Require the immutable BusyBox probe to resolve the Kubernetes service through the declared cluster DNS. Confirm the uniquely named probe is removed even on failure.
8. Reconfirm zero PVCs and zero Applications when the Application API exists; an absent Application CRD is valid at this boundary.
9. Record non-secret Cilium, node, CoreDNS, DNS-probe, Application, PVC, and cleanup evidence.

## Temporary unsafe boundary

Hubble traffic is plaintext and the Hubble server Certificate is absent. Do not expose or use Hubble, do not commit the temporary ConfigMap as desired state, and do not call the cluster complete. Proceed directly to step 7 under a separate authorization. Step 7 installs cert-manager and lets Argo self-heal restore the unchanged TLS-enabled Cilium artifact.
