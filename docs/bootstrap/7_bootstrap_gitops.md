# 7. Bootstrap GitOps

**Applies to:** initial bootstrap, destructive rebuild, or recovery of an absent GitOps control plane. **Not a routine K3s-upgrade step.**

## Overview

Bootstrap the complete Istio ambient data plane before Argo CD, keep the
`argocd` and `istio-system` namespaces outside ambient mode, then let GitOps
reconcile the complete public and private desired state. This step resolves the
temporary plaintext Hubble boundary from step 6.

> **Stop before live execution:** the 2026-08-09 bootstrap failed because Argo
> CD was ambient-enrolled before `istiod` and `ztunnel` existed. Publish the
> reviewed namespace and script fix at the revision used by the public root
> before running the repaired script; otherwise GitOps can restore the unsafe
> label.

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

5. Run the repository script from the controller:

   ```bash
   ./scripts/bootstrap.sh \
     --kubeconfig="$CONTROLLER_KUBECONFIG" \
     --kubectl="$CONTROLLER_KUBECTL" \
     --private-repository="$PRIVATE_REPOSITORY"
   ```

   Add `--force-conflicts` only when intentionally transferring server-side
   apply field ownership to the bootstrap transaction. The flag is forwarded
   to every bootstrap `kubectl apply --server-side` call.
6. The script creates only unlabeled bootstrap namespaces first and removes any
   stale ambient labels from `argocd` and `istio-system`. It then applies and
   verifies, in order, Istio base, `istiod`, Istio CNI, and ztunnel. Only after
   ztunnel is rolled out does it apply and restart Argo CD.
7. The script applies the private AppProject and seeds exactly two root
   Applications: public `core-infrastructure-aoa` and private `private-aoa`.
   It waits only for both Application objects to exist, removes the superseded
   root identities if present, and returns control to Argo CD. Child
   Applications, Cilium TLS restoration, storage, workloads, and smoke tests
   are GitOps reconciliation and step 8 acceptance, not bootstrap work.
8. If any bootstrap check fails, preserve the exact evidence and stop. Do not
   manually patch live workloads or re-add ambient labels as a substitute for
   GitOps ownership.

## Expected boundary

Istio is operational before Argo CD starts; Argo CD and Istio remain independent
of ambient redirection; `core-infrastructure-aoa` and `private-aoa` exist; and
Argo CD owns all subsequent reconciliation. Bootstrap does not wait for child
Application health.

To remove only the manifests installed directly by bootstrap, in reverse order:

```bash
./scripts/prune.sh --reset \
  --kubeconfig="$CONTROLLER_KUBECONFIG" \
  --kubectl="$CONTROLLER_KUBECTL" \
  --private-repository="$PRIVATE_REPOSITORY"
```

`--reset` is mandatory. The prune transaction removes Application finalizers
before deleting the roots so it does not cascade into GitOps-managed workloads.
