# 7. Bootstrap GitOps

**Applies to:** recovery or bootstrap after the required 1Password Connect Secrets have been seeded. The repository script does not seed those credentials. **Not a routine K3s-upgrade step.**

## Overview

Bootstrap the complete Istio ambient data plane before Argo CD, keep the
`argocd` and `istio-system` namespaces outside ambient mode, then let GitOps
reconcile the complete public and private desired state. This step resolves the
temporary plaintext Hubble boundary from step 6.

> **Publication gate:** both root Applications track `main`. The reviewed public
> and private changes must be merged into `main`, and the root source paths must
> exist there, before live execution. A local feature branch is not sufficient.
> `--force-conflicts` transfers server-side apply field ownership only; it does
> not publish Git revisions or make a missing Argo CD source path available.

## Procedure

1. Require healthy API, Cilium, nodes, CoreDNS, and DNS from step 6. For a clean
   bootstrap, require zero PVCs and zero Applications if the CRD exists. For
   recovery of the documented partial bootstrap, preserve the observed
   resources and use the same staged script; do not reset or manually patch
   workloads.
2. Confirm both reviewed changes are merged into `main`, fetch both remotes, and
   prove representative files exist at the exact revisions the roots will use:

   ```bash
   git fetch origin main
   git -C "$PRIVATE_REPOSITORY" fetch origin main
   git cat-file -e \
     origin/main:artifacts/infrastructure/core-infrastructure-aoa/application_argocd.yml
   git -C "$PRIVATE_REPOSITORY" cat-file -e \
     origin/main:artifacts/application/private-aoa/application_cilium.yml
   ```

   All four commands must succeed. Re-run public validation, private
   validation/rendering, and the cross-repository graph check afterward.
3. Require the existing `Secret/1password/op-credentials` and
   `Secret/external-secrets/onepassword-connect-token` by name without reading
   their data. If either is absent, stop: `scripts/bootstrap.sh` does not create
   those Secrets or read files under `credentials/1password/`.
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
   to every bootstrap `kubectl apply --server-side` call. It is not a recovery
   mechanism for an unpublished root revision or missing Git path.
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
both roots can load their published `main` source paths. Bootstrap does not wait
for child Application health. Successful script output is therefore only the
bootstrap boundary, not final acceptance; continue immediately with step 8.

To remove only the manifests installed directly by bootstrap, in reverse order:

```bash
./scripts/prune.sh --reset \
  --kubeconfig="$CONTROLLER_KUBECONFIG" \
  --kubectl="$CONTROLLER_KUBECTL" \
  --private-repository="$PRIVATE_REPOSITORY"
```

`--reset` is mandatory. The prune transaction removes Application finalizers
before deleting the roots so it does not cascade into GitOps-managed workloads.
