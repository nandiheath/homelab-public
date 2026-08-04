# 8. Verify final acceptance

**Applies to:** initial bootstrap, destructive rebuild, and cluster upgrade. This step is read-only except for explicitly approved, self-cleaning smoke probes.

## Overview

Prove the cluster is usable, desired state owns it, temporary bootstrap compromises are gone, storage and applications are healthy, and no credentials or lifecycle tokens leaked.

## Procedure

1. Record the exact public and private repository revisions, inventory cluster identity, controller tool versions, and maintenance route. Do not record private endpoints, node identities, host keys, or credentials in public files.
2. Require exactly three expected Ready nodes at the approved uniform K3s version and Pod CIDRs. Require exactly three healthy voting embedded-etcd members at the approved version, with no learners, stale members, or version skew.
3. Require the Kubernetes API, Cilium and Cilium Envoy DaemonSets, both Cilium operator replicas, CoreDNS, and cluster DNS to be healthy. Run only the immutable uniquely named DNS probe and require its cleanup.
4. Prove Cilium matches the unchanged final private artifact. Require Hubble TLS enabled, the Hubble Certificate and TLS secret present, and no production resource containing a public example API endpoint or Pod CIDR.
5. Require Argo CD, External Secrets, 1Password Connect, cert-manager, Longhorn, CloudNativePG, ingress, public root, and private root to be Synced and Healthy. Require no legacy Argo owner.
6. For a clean bootstrap/rebuild, require exactly the expected newly created Bound PVC count from the current runbook and clean/empty application smoke-test results. For an in-place upgrade, compare Applications and PVCs with the captured preflight inventory and require no unintended loss or replacement.
7. Require Longhorn's reviewed node-drain policy and confirm no backup target or recurring backup job was introduced by this sequence.
8. Check the controller and nodes for temporary credential files. Check process arguments, systemd units, logs, and Ansible fact cache for token or resolved-secret residue without printing any matching secret.
9. Re-run offline repository validation and render checks. Ensure generated artifacts are unchanged unless their reviewed source changed.
10. Record criterion-level non-secret evidence in the active task handoff. Only the serial rollup owner may update project status and remove a completed task after integration validation.

## Failure handling

A degraded controller, unsynced Application, missing PVC, wrong version, Hubble TLS disabled, residue, or public-example value is not an acceptable partial success. Stop, preserve non-secret evidence, and repair through the owning playbook or GitOps source. Do not hide the failure with manual live patches.

## Expected boundary

The cluster is healthy end to end, final desired state has replaced every temporary bootstrap state, credentials and tokens remain contained, and the task has observable acceptance evidence suitable for serial rollup.
