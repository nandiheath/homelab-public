---
name: contribution-workflow
description: Prepare every repository change for review with Conventional Commits and a complete pull request.
---

# Contribution workflow

Apply this skill to every repository change, including documentation, configuration, generated artifacts, and code.

1. Verify the changed behavior with the repository's relevant command. For manifest changes, run `./scripts/validate.sh` in the task worktree.
2. Commit the completed, scoped change before opening review. Use Conventional Commits:
   - `feat:` for a user-visible capability
   - `fix:` for a defect correction
   - `docs:` for documentation or agent-workflow changes
   - `chore:` for maintenance with no product behavior change
   - Include an optional, concise scope when it makes the affected subsystem clearer: `fix(render): preserve empty documents`.
3. Push the branch and create a pull request. Never land a change by directly pushing to `main`.
4. Write a PR description that contains:
   - **Summary** — what changed and why.
   - **Validation** — exact commands run and observed outcomes.
   - **Risk and rollout** — operational impact, generated-artifact impact, or `None` when applicable.
   - **Follow-ups** — remaining work, or `None`.
5. Keep unrelated pre-existing work out of the commit and PR. State it explicitly when it blocks a clean change.
6. Leave no staged, unstaged, or untracked files. Run `agent-workspace repo-handoff validate --root . --pr <URL>` after pushing; handoff is invalid unless the exact local commit matches its upstream and the pull-request URL is reviewable.

Blocked or incomplete work that is coherent enough to preserve uses a draft pull request. Never transfer a dirty checkout to the next session. For a task-lifecycle change, the serial rollup owner creates or updates the PR after integration validation. Implementation agents record their observed proof and delivery URL in the task handoff; they do not bypass the rollup process.
