# 2. Prepare the controller and private inputs

**Applies to:** initial bootstrap, destructive rebuild, and cluster upgrade. This is read-only preparation; it authorizes no mutation.

## Overview

Bind the public automation to the private inventory, strict SSH trust, controller tools, kubeconfig path, private Cilium artifact, and approved secret boundary. Every later phase must fail before mutation if this contract is incomplete.

## Procedure

1. Read `AGENTS.md`, `skills/k3s-lifecycle/SKILL.md`, [`../operations-runbook.md`](../operations-runbook.md), the private repository instructions, and the active path-owned task.
2. Reserve physical or serial recovery access. For each server, compare the private inventory pin and controller `known_hosts` entry with the public key and SHA256 fingerprint obtained from its trusted local console. Never establish trust from a network scan.
3. Set controller paths and the private cluster identity once:

   ```bash
   export PUBLIC_REPO="$HOME/workspace/homelab-public"
   export PRIVATE_REPO="$HOME/workspace/homelab-private"
   export INVENTORY="$PRIVATE_REPO/ansible/inventory/production/hosts.yml"
   export CLUSTER_ID="<private-inventory-cluster-id>"
   export CONTROLLER_KUBECONFIG="$HOME/.kube/$CLUSTER_ID"
   export CONTROLLER_KUBECTL="$PUBLIC_REPO/bin/kubectl"
   export PRIVATE_CILIUM="$PRIVATE_REPO/artifacts/infrastructure/cilium"
   cd "$PUBLIC_REPO"
   . ./bin/activate-hermit
   ```

4. Parse and validate without contacting infrastructure or resolving secrets:

   ```bash
   ansible-inventory -i "$INVENTORY" --list >/dev/null
   ./scripts/validate-ansible.sh
   homelab argocd render --all
   ./scripts/validate.sh
   cd "$PRIVATE_REPO"
   . ./bin/activate-hermit
   make render
   make validate
   "$PUBLIC_REPO/scripts/validate-repository-graph.sh" "$PRIVATE_REPO"
   ```

5. Return to the public repository and reactivate its Hermit environment. Record both repository revisions and controller tool versions in non-secret handoff evidence.
6. Prove the private Cilium artifact matches public source except for the inventory-derived API endpoint and Pod CIDR substitutions described by the operations runbook. A public example address in a production artifact is a hard stop.
7. Confirm the controller kubeconfig, 1Password service-account token file, and any temporary credential input are regular files owned by the controller user with mode `0600`. Exercise 1Password access without printing, logging, or persisting resolved values.
8. Run the applicable playbook's read-only preflight and capture only its approved non-secret node, kernel, K3s, etcd, Application, and PVC report.
9. Choose exactly one route from [`README.md`](README.md). Request phase authorization only after the matching preflight passes.

## Expected boundary

The controller has strict identity, reviewed inputs, immutable tool paths, and recovery access. No remote mutation has occurred. Any stale key, missing checksum, unclean revision, private/public render mismatch, wrong cluster identity, or unsafe file mode blocks every later step.
