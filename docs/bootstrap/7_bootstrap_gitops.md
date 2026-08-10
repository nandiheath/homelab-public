# 7. Bootstrap GitOps

**Applies to:** initial bootstrap, destructive rebuild, or recovery of an absent GitOps control plane. **Not a routine K3s-upgrade step.**

## Overview

Bootstrap the complete Istio ambient data plane before Argo CD, keep the
`argocd` and `istio-system` namespaces outside ambient mode, then let GitOps
reconcile the complete public and private desired state. This step resolves the
temporary plaintext Hubble boundary from step 6.

> **Stop before live execution:** the 2026-08-09 bootstrap failed because Argo
> CD was ambient-enrolled before `istiod` and `ztunnel` existed. The reviewed
> source fix must be published at the revision used by the public root before
> running the repaired script; otherwise `cluster-namespaces` can restore the
> unsafe label. Script review is not live-recovery authorization.

## Procedure

1. Require healthy API, Cilium, nodes, CoreDNS, and DNS from step 6. For a clean
   bootstrap, require zero PVCs and zero Applications if the CRD exists. For
   recovery of the documented partial bootstrap, preserve the observed
   resources and use the same staged script; do not reset or manually patch
   workloads.
2. Confirm both repositories are on the reviewed revisions used to render the
   public and private artifacts. Re-run public validation, private
   validation/rendering, and the cross-repository graph check.
3. If the two 1Password Connect Secrets do not already exist, place the Connect
   token and credentials JSON only in the ignored
   `credentials/1password/1password-token.txt` and
   `credentials/1password/1password-credentials.json` paths. The script reuses
   existing Secrets and never passes their values in process arguments.
4. Inspect the credential-free local plan:

   ```bash
   ./scripts/bootstrap.sh --dry-run \
     --private-repository="$PRIVATE_REPOSITORY"
   ```

5. Obtain fresh exact authorization:

   ```text
   BOOTSTRAP <cluster-id>
   ```

6. Run the repository script from the controller:

   ```bash
   ./scripts/bootstrap.sh \
     --kubeconfig="$CONTROLLER_KUBECONFIG" \
     --kubectl="$CONTROLLER_KUBECTL" \
     --private-repository="$PRIVATE_REPOSITORY" \
     --cluster-id="$CLUSTER_ID" \
     --authorize="BOOTSTRAP ${CLUSTER_ID}"
   ```

7. The script creates only unlabeled bootstrap namespaces first and removes any
   stale ambient labels from `argocd` and `istio-system`. It then applies and
   verifies, in order, Istio base, `istiod`, Istio CNI, and ztunnel. Only after
   ztunnel is rolled out does it apply and restart Argo CD.
8. The script applies cert-manager, External Secrets, 1Password Connect, the
   public root, private Cilium, the private root, and the private ownership root
   in dependency order. A failed prior 1Password health probe is replaced only
   after Connect is available.
9. Before success, every expected child Application—not only the app-of-apps
   root—must be Synced and Healthy. Cilium and Cilium Envoy must roll out,
   `hubble-disable-tls` must be `"false"`, the Hubble Certificate must be Ready,
   and both control-plane namespaces must remain outside ambient mode.
10. If any check fails, preserve the exact evidence and stop. Do not manually
    patch the live ConfigMap or re-add ambient labels as a substitute for GitOps
    ownership.

## Expected boundary

Istio is operational before Argo CD starts; Argo CD and Istio remain independent
of ambient redirection; GitOps owns the full desired state; Cilium is self-healed
to TLS-enabled Hubble; and no credential value appeared in a process argument.
Application storage, smoke tests, and final residue checks remain for step 8.
