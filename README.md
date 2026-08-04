# Homelab public GitOps

This repository is the public, reproducible half of a Kubernetes homelab. It declares infrastructure with Kustomize, renders the declarations into committed artifacts, and lets Argo CD reconcile that desired state in the cluster. Private applications and credential material remain outside this repository.

## System model

```mermaid
flowchart LR
  M[argocd/infrastructure] --> R[homelab argocd render]
  R --> A[artifacts/infrastructure]
  A --> G[Argo CD]
  G --> K[K3s cluster]
  P[private GitOps repository] --> G
  S[1Password Connect] --> E[External Secrets]
  E --> K
```

The infrastructure root creates Argo CD Applications for Argo CD, Cilium, External Secrets, 1Password Connect, Istio, cert-manager, Longhorn, CloudNativePG, Grafana, MetalLB, namespaces, and the private repository boundary. Bootstrap brings up the networking and GitOps prerequisites before Argo CD owns steady-state reconciliation.

## Repository layout

| Path | Purpose |
| --- | --- |
| `argocd/infrastructure/` | Kustomize source for public cluster infrastructure. |
| `artifacts/infrastructure/` | Committed, rendered Kubernetes manifests consumed by GitOps. Do not edit manually. |
| `Makefile` | Local wrapper for the pinned `homelab argocd render` command and repository validation. |
| `scripts/validate.sh` | Local validation: actionlint, shellcheck, and kubeconform. |
| `scripts/bootstrap.sh` | Legacy live-cluster bootstrap helper. It needs local credentials and mutates a cluster. |
| `ansible/` | K3s node provisioning, upgrades, recovery, and GitOps bootstrap playbooks. |
| `docs/bootstrap/` | Numbered agent guide for initial host bootstrap, destructive rebuild, final acceptance, and guarded upgrades. |
| `docs/operations-runbook.md` | Guard-railed operating procedures and explicit operational placeholders. |
| `tasks/` | Path-owned work contracts for concurrent agents. |
| `AGENTS.md` | Repository agent protocol and safety gates. |
| `skills/contribution-workflow/` | Required Conventional Commit and pull-request workflow. |

## Local validation

Install the pinned Hermit tools, then validate in a worktree:

```bash
source bin/activate-hermit
make render
make validate
```

Rendering rewrites `artifacts/` locally and validation does not apply anything to a cluster. Review source changes locally; pull-request CI renders only affected source directories and records any artifact delta as a separate generated commit.

## Operations

The [numbered bootstrap guide](docs/bootstrap/README.md) selects the safe initial-build, destructive-rebuild, or upgrade route. The [operations runbook](docs/operations-runbook.md) remains the exact authority for guarded K3s lifecycle and GitOps bootstrap commands. These procedures are deliberately not routine developer commands: they require approved maintenance windows, private inventory or credential manifests, and explicit authorization before they can mutate live infrastructure.

## Contribution

Read `AGENTS.md` before making changes. Every change follows `skills/contribution-workflow/SKILL.md`: verify the scoped behavior, create a Conventional Commit, push a branch, and land through a pull request with Summary, Validation, Risk and rollout, and Follow-ups.
