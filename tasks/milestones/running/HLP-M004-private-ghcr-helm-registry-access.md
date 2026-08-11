# HLP-M004 - Private GHCR Helm registry access

- Status: running
- Owner: Main

## Goal

Prepare public Argo CD desired state for authenticated read-only OCI Helm access to the private homelab-services chart repository without applying manifests or contacting a cluster.

## Tasks

- [ ] HLP-020 - Add Argo GHCR chart credentials

## Acceptance criteria

- The bootstrap source and committed rendered artifact define a separate Argo repository Secret sourced from the existing `onepassword` ClusterSecretStore, with Helm OCI metadata, username, and password fields, without exposing resolved secret values.
- The private AppProject allowlist includes the exact GHCR Helm repository URL.
- Offline rendering and repository validation pass; no bootstrap, kubectl, Argo CD, apply, or remote infrastructure operation is performed.

## Verification

- Focused `homelab argocd render --path argocd/infrastructure/bootstrap --output artifacts/infrastructure/bootstrap`.
- `./scripts/validate.sh` and `agent-workspace repo-tasks validate --root .`.
- Source and artifact inspection confirms Secret metadata/data keys, ExternalSecret references, and AppProject source allowlist without printing resolved credentials.

## Blockers

- None observed.

## Completion handoff


- Tasks rolled up:
- Observed milestone verification:
- Project status updated:
- Follow-ups:
