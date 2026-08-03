# Project status

_Last observed: 2026-08-03_

## Current state

- Public GitOps desired state lives in `manifests/infrastructure/`; committed render output lives in `artifacts/infrastructure/`.
- The repository contains Ansible playbooks for host operations and a Kubernetes bootstrap script. They are operational surfaces, not routine validation.
- No agent task is active. New work begins as a path-owned document in `tasks/planned/`.

## Observed validation

- `./scripts/validate.sh` completed successfully on 2026-08-02: shell and workflow linting passed; the infrastructure renderer completed; kubeconform reported 350 resources, 243 valid, 0 invalid, 0 errors, and 107 skipped schemas.
- GitHub Actions runs the same command in `.github/workflows/render.yaml` with read-only repository permissions and no deployment step.
- K3s installs now export a controller-local, mode-restricted kubeconfig only after the first server API is ready; `fetch_kubeconfig.yaml` reuses that export path and reset removes it once. Static lint and syntax checks, plus GitHub Actions rendering validation, passed on 2026-08-03. Live recovery then succeeded twice against `server[0]`: the exported `homelab` context targets `https://10.43.2.1:6443` and listed all three Ready control-plane nodes.

## Rollup protocol

Only the serial rollup owner integrates ready tasks, runs repository validation, updates this file, and removes rolled-up task documents. See `AGENTS.md` and `tasks/README.md`.

## Known follow-ups

- Cross-repository graph validation is available via `scripts/validate-repository-graph.sh`, but was not run because it requires an explicit path to the private repository and its denylist.
