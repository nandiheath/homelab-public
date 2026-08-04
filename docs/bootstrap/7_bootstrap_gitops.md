# 7. Bootstrap GitOps

**Applies to:** initial bootstrap, destructive rebuild, or recovery of an absent GitOps control plane. **Not a routine K3s-upgrade step.**

## Overview

Bootstrap Argo CD and its credential providers from the controller, then let GitOps reconcile the complete public and private desired state. This step resolves the temporary plaintext Hubble boundary from step 6.

## Procedure

1. Require healthy API, Cilium, nodes, CoreDNS, and DNS from step 6; zero PVCs; zero Applications if the CRD exists; and no pre-existing cert-manager or conflicting GitOps ownership.
2. Confirm both repositories are on the reviewed revisions used to render the private artifacts. Re-run public validation, private validation/rendering, and the cross-repository graph check.
3. Through the approved 1Password environment boundary, provide the required 1Password Connect and GitHub App credential-manifest content to the playbook environment. Use secret references, not resolved values. Never print, log, persist, or paste the manifests into arguments, Git, or task evidence.
4. Obtain fresh exact authorization:

   ```text
   BOOTSTRAP <cluster-id>
   ```

5. Run only from the controller:

   ```bash
   op run -- ansible-playbook -i "$INVENTORY" ansible/playbooks/bootstrap_gitops.yml \
     -e "kubeconfig=$CONTROLLER_KUBECONFIG" \
     -e "controller_kubectl=$CONTROLLER_KUBECTL" \
     -e "{\"operation_guard_confirmation\":\"BOOTSTRAP ${CLUSTER_ID}\"}"
   ```

6. Let the playbook create mode-`0600` temporary credential files immediately before no-log application and remove them in `always`. Do not replace this with shell interpolation or long-lived files.
7. Preserve bootstrap ordering: Argo CD, External Secrets, 1Password Connect, temporary credentials, repository credentials, public root, then private root. This playbook must not install or change K3s.
8. Wait for cert-manager and Argo self-heal. Require Cilium to match the unchanged final private artifact, `hubble-disable-tls` to return to `"false"`, and the omitted Hubble Certificate and resulting TLS material to exist.
9. If reconciliation fails before Hubble TLS is restored, keep Hubble unexposed, preserve the exact evidence, remove any temporary credential residue, and stop. Do not manually patch the live ConfigMap as a substitute for GitOps ownership.
10. Continue to step 8 only after public and private root Applications are reconciled and no temporary controller credential files remain.

## Expected boundary

Argo CD owns the full desired state; credential providers and cert-manager are available; Cilium is self-healed to TLS-enabled Hubble; and temporary bootstrap credentials are absent. Application health, storage, smoke tests, and final residue checks remain for step 8.
