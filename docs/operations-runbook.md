# Operations runbook

> **Safety boundary:** All procedures below can affect live hosts, the Kubernetes control plane, or credentials. Do not execute them without explicit authorization, an approved maintenance window, and an operator with the required private inventory and credentials. Never place private inventories, kubeconfigs, tokens, or exported secrets in this repository.

## Before any live operation

1. Record the change owner, maintenance window, scope, and rollback decision point in the incident or change record.
2. Confirm control-plane health, workload health, backups, and access from the approved operator environment. **Placeholder:** add the organization-approved health and backup commands here.
3. Confirm the target inventory, kubeconfig, and credential files are private, mode-restricted, and outside this repository.
4. Announce the maintenance window and identify the operator who may authorize rollback.

## Upgrade K3s

**Purpose:** move the cluster to the version declared by `k3s_version` in the private Ansible inventory. `ansible/playbooks/upgrade.yaml` upgrades servers serially, then agents; the role only updates nodes whose installed version is older than the requested version.

### Procedure

1. Choose the target K3s version and update it in the approved private inventory. Do not change the public example inventory to record a live target.
2. Review the planned inventory and maintenance scope. **Placeholder:** add the approved dry-run or preflight command for the private inventory.
3. Execute the upgrade playbook from an approved operator environment:

   ```bash
   ansible-playbook -i <private-inventory> ansible/playbooks/upgrade.yaml
   ```

4. After each serial server upgrade, verify the API and control-plane health before the playbook advances. After agent upgrades, verify workload scheduling and networking.
5. Record installed versions and health evidence. If health regresses, stop further upgrades and follow the approved rollback or recovery procedure. **Placeholder:** document the tested rollback version and procedure.

## Bootstrap a GitOps cluster

**Purpose:** provision K3s, install Cilium before dependent controllers, install Argo CD plus secret-controller prerequisites, apply operator-supplied credential manifests, and seed the public root Application.

### Preconditions

- Rendered public artifacts are current and `./scripts/validate.sh` has passed.
- A private inventory defines the intended server and agent hosts.
- The operator has two mode-restricted, external credential-manifest paths for 1Password Connect and Argo CD GitHub App credentials.
- The change is explicitly authorized. This is a cluster-mutating operation.

### Procedure

1. Confirm the private inventory and credential-manifest paths with the authorized operator; do not print their contents.
2. Run the only supported Ansible bootstrap path:

   ```bash
   ansible-playbook -i <private-inventory> ansible/playbooks/bootstrap_gitops.yml \
     -e bootstrap_connect_credentials_file=<restricted-connect-manifest> \
     -e bootstrap_github_app_credentials_file=<restricted-github-app-manifest>
   ```

3. Observe the built-in Cilium rollout check and Argo repository-credential wait. Then verify that Argo CD has reconciled the public root Application. **Placeholder:** add the approved post-bootstrap health dashboard and escalation path.
4. Do not use `scripts/bootstrap.sh` as a routine bootstrap path. It is a legacy helper that directly applies manifests and only creates bootstrap secrets when they are absent; it is not a safe credential-rotation mechanism.

## Rotate secrets

**Purpose:** rotate credentials stored in the approved secret system while preserving the public/private boundary. The public `ClusterSecretStore` reads a 1Password Connect token from `external-secrets/onepassword-connect-token`; the Argo CD GitHub App credentials are materialized by an `ExternalSecret` from the `github-app-credentials` item.

### Procedure

1. Identify the exact credential, dependent controllers, expiry, owner, and rollback credential in the change record. **Placeholder:** add the approved inventory of secret owners and rotation cadence.
2. Rotate the credential in the approved external secret system. Never add its value to Git, a task document, a PR, terminal output, or this runbook.
3. For a 1Password Connect authentication change, have the authorized operator update the private bootstrap credential manifest. For an Argo CD GitHub App change, update the source item and properties expected by `manifests/infrastructure/bootstrap/externalsecret-argocd.yaml`.
4. Use the approved controller reconciliation method and verify the resulting Kubernetes Secret plus every dependent workload or repository connection. **Placeholder:** document the approved reconcile command and expected status fields for this environment.
5. Retire the prior credential only after the new credential works and the rollback window closes. Record completion without recording secret values.

## Incident and recovery placeholders

The following must be completed with environment-specific, tested procedures before operational use:

- **Control-plane loss:** [placeholder: restore source, recovery owner, and tested command sequence]
- **etcd restore:** [placeholder: backup location, retention, encryption access, and restore drill evidence]
- **Node replacement:** [placeholder: hardware enrollment and inventory update procedure]
- **Argo CD reconciliation failure:** [placeholder: diagnostic steps and escalation path]
- **Secret-provider outage:** [placeholder: break-glass policy, approvers, and audit requirements]
