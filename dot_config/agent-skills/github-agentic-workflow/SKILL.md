---
name: github-agentic-workflow
description: Author or modify a GitHub agentic workflow (gh-aw). Use when the user asks to create, modify, or debug a gh-aw workflow, or when adding a `.github/workflows/*.md` agentic workflow source. Codifies common traps and best practices.
user-invocable: true
---

# github-agentic-workflow

Create or modify a gh-aw (GitHub Agentic Workflow).

## Install

Install the gh-aw CLI as a gh extension:

```sh
gh extension install github/gh-aw
```

Or via the install script:

```sh
curl -sL https://raw.githubusercontent.com/github/gh-aw/main/install-gh-aw.sh | bash
```

Reference: https://github.github.com/gh-aw/setup/quick-start/

## Required references

- `GUIDE.md` (in this skill's directory) — full frontmatter reference, trigger types, tools, context variables `${{ }}`, security model, common patterns, and examples. Read it when authoring a new workflow from scratch.
- `~/co/gh-aw` — gh-aw source for behavior and config questions (don't WebFetch raw.githubusercontent.com). Clone it blobless to avoid pulling the full history of a large repo:
  ```sh
  git clone --filter=blob:none https://github.com/github/gh-aw ~/co/gh-aw
  ```
- Existing workflows in the repo's `.github/workflows/` — working examples to copy from.
- Your org's GHA standards doc if one exists — check for action allowlists, pinning rules, and secret-handling policy.

## Process

1. **Resolve the goal.** What should the workflow do? Triggers (cron, dispatch, issue), inputs, side effects (commit, PR, issue, release).

2. **Check org conventions.** If the repo has a GHA standards doc, read it for action allowlists, pinning rules, and secret-handling policy. Otherwise default to SHA-pinned actions and `permissions: read-all` on agent jobs.

3. **Pick a working example** from the existing workflows in the repo — copy the structure rather than authoring from scratch. The repo's existing workflows already encode local conventions.

4. **Author the `.github/workflows/<name>.md`** (gh-aw source) following the example. Include:
   - `on:` triggers — for scheduled runs prefer `schedule:` + `workflow_dispatch:` so manual reruns work
   - `permissions:` — minimum required; default to `read-all` on agent jobs
   - `safe-outputs:` — declare what the agent is allowed to produce (issues, PRs, comments). The CLI input shape: `safeoutputs release_metadata .` wants the bare inputs object on stdin, not the `{workflow_name, inputs}` envelope.
   - `tools:` — the actions/CLIs the agent may invoke
   - Prompt body — terse, names exact files/URLs, expected output shape

5. **Compile** with `gh aw compile` (or via the Makefile target if the repo has one) — produces the `.lock.yml` next to the source. Both files get committed; never edit the lock by hand.

6. **Validate pinning.** For each `uses:` line in the compiled `.lock.yml`, verify it is pinned to a commit SHA (not a mutable tag). If the org has an action allowlist, cross-check against it.

7. **Test pre-merge** via `workflow_dispatch` from a branch — never test a cron workflow by waiting for the cron. Permissions and secrets behave the same in dispatch mode.

## Common traps (from prior sessions)

- **Issues must be enabled on the target repo** — workflows that create issues fail silently otherwise. Enable issues for PoC repos.
- **Compile is required** — editing only the `.md` and pushing won't run; the `.lock.yml` is what GitHub Actions actually executes. CI compile-check is worth wiring up to catch this.
- **Agent feedback loops before dispatch** — when the agent picks inputs for a downstream workflow, give it a wrapper/tool to validate the choice (e.g. a script that checks "does this version exist?") before triggering. Saves wasted runs.
- **Agent job must be read-only** — `permissions:` on the agent job cannot include any write scope (`issues: write`, `pull-requests: write`, `actions: write` are all blocked). All writes go through `safe-outputs`, which uses the gh-aw GitHub App token. Use `permissions: read-all` as the default.
- **`dispatch-workflow` resolves by file basename, `.yaml` not supported** — the compiler checks for `<name>.md`, `<name>.lock.yml`, `<name>.yml` only. Files with `.yaml` extension are invisible to the validator. Rename standard workflow files to `.yml` if they need to be dispatch targets. At runtime the file is dispatched by filename (e.g., `auto-update-go.yml`), NOT the workflow's `name:` display field.
- **`safeoutputs` subcommand naming** — hyphens in the workflow name become underscores in the CLI subcommand: `"cve-response.lock"` in the `workflows:` list → `safeoutputs cve_response_lock`. Dots also become underscores. Send a bare inputs object on stdin: `jq -nc '{issue_url: $url}' | safeoutputs cve_response_lock`.
- **`workflow_run` trigger needs branch restriction** — `gh aw compile` warns (and may error in strict mode) if `workflow_run` has no `branches:` filter. Always add `branches: [main]` (or whatever the default branch is).
- **`dispatch-workflow` skips local validation for cross-repo targets** — if `target-repo:` is set to a different repo, the compiler skips local file existence checks. Safe to use for dispatching into repos you don't have locally.

## When the workflow fails

- Pull the run log first: `gh run view <id> --log-failed`
- Check against [gh-aw troubleshooting](https://github.github.com/gh-aw/troubleshooting/common-issues/) and the gh-aw issues tracker
- The compile step is the most common source of surprises — re-compile locally and diff the `.lock.yml`

## Key gh-aw behaviors

- **`**stop**` keyword** — writing `**stop**` in the agent instructions halts execution at that point. Always use it for validation failures and permission denials.
- **Context variables** use `${{ github.* }}` syntax (e.g. `${{ github.event.issue.number }}`, `${{ github.actor }}`). See GUIDE.md for the full variable table.
- **Safe outputs** — the agent never directly modifies the repo. All writes (PRs, issues, comments) go through `safe-outputs:` in frontmatter, executed by a separate job with write permissions.

## Standing rules

- Match the existing workflow style in the repo — don't introduce a new pattern unless asked.
