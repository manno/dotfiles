# .github — automation overview

## Neovim plugin bump workflow

Weekly scheduled workflow (`bump-nvim-plugins.yml`) that pins lazy.nvim plugins
to exact release commit SHAs, runs an agentic security analysis per plugin, and
opens a pull request.

### Three-job pipeline

```
detect → analyze (matrix) → pr
```

**Job 1 `detect`** — `go run .github/scripts/bump-nvim-plugins.go`

Scans all Lua files under `dot_config/nvim/lua/plugins/` plus
`dot_config/nvim/lua/plugins.lua`. For each plugin spec with an
`'owner/repo'` slug it fetches the latest GitHub Release, resolves the tag
to a commit SHA, and updates `commit = "sha"` in place. Outputs
`.github/bump/matrix.json` (updatable plugins) and
`.github/bump/unpinnable.json` (bare dependency strings that need manual
conversion). Sets step outputs `has_updates` and `matrix`.

**Job 2 `analyze`** — `node .github/scripts/analyze-plugin.mjs`

One job per plugin via `strategy.matrix`, `max-parallel: 3`. Uses the
z.ai GLM API (`glm-4.7`, OpenAI-compatible) with iterative tool calling to
examine the actual diff. Tools call `gh api` for file lists, diffs, file
content, and commit details — no repository is cloned. Produces
`{slug_safe}-analysis.md` with a `CLEAN` / `WARN` / `BLOCK` verdict.

Token budget: `glm-4.7` has a 200k context, so the script keeps the full
transcript for the whole audit. Because history is append-only, the message
prefix stays stable and repeat context bills at z.ai's cached input rate
($0.11/M vs $0.60/M).

**Job 3 `pr`** — shell

Downloads all artifacts, builds the PR body (update table + unpinnable list
+ security reports), commits the Lua changes to
`bump/nvim-plugins-{date}`, and creates or updates the PR via `gh pr
create` / `gh pr edit`. Uses `git checkout -B` + `git push -f` so
re-running the job on an existing branch always succeeds.

### Permissions required

```yaml
permissions:
  contents: write       # commit and push the bump branch
  pull-requests: write  # create / edit PR
```

`GITHUB_TOKEN` is auto-provided by Actions and covers the GitHub API and
`gh` CLI uses. Inference needs one manually-added repository secret:

| Secret | Where to get it |
|--------|-----------------|
| `ZAI_API_KEY` | <https://z.ai/manage-apikey/apikey-list> |

Add it under *Settings → Secrets and variables → Actions*. Inference moved
off GitHub Models when that service was retired on 2026-07-30; the
`models: read` permission and its Copilot-subscription requirement are gone.

### Local testing

```bash
# copy and fill in credentials
cp .github/scripts/.envrc.example .envrc && direnv allow

# run detect + one analysis, then restore files
bash .github/scripts/test-bump.sh

# target a specific plugin
bash .github/scripts/test-bump.sh folke/snacks.nvim
```

### Known issues / limits

- Turn budget, not context, is the binding limit: a large plugin reaches only
  ~30k of the 200k window. `maxIterations` is 20, and on the final turn the
  tools are withdrawn and the model is told to conclude, so a slow
  investigation still yields a verdict (noting what it did not reach) rather
  than the "iteration limit" fallback. `CHUNK_SIZE` (8000 chars per tool
  result) and `maxIterations` are the knobs — raising either costs tokens.
  Both are enforced client-side; z.ai has no say in them. Raising them far
  is counterproductive: history is never pruned, so every turn re-bills the
  whole transcript and cost grows with the square of the content fetched.
- **Unpinnable plugins**: bare dependency strings (e.g.
  `dependencies = { "nvim-lua/plenary.nvim" }`) cannot be pinned
  automatically. Convert them to full spec tables; see the PR body for
  instructions.
- Rate limiting (429): `max-parallel: 3` in the workflow and exponential
  backoff in the script (up to 10 retries, starting at 10 s, capped at
  10 min) handle burst traffic from simultaneous jobs. z.ai enforces
  per-plan concurrency limits — drop `max-parallel` if 429s persist.

- Cost on `glm-4.7` ($0.60/M input, $2.20/M output), measured: a one-file
  update runs ~$0.003 (3.9k tokens); a large release like
  `codecompanion.nvim` v19.22.0 runs ~$0.08 (132k tokens). A 6-plugin bump
  PR lands well under $0.50.

### Key files

| File | Purpose |
|------|---------|
| `.github/workflows/bump-nvim-plugins.yml` | Workflow definition |
| `.github/scripts/bump-nvim-plugins.go` | Job 1: detect + update SHAs |
| `.github/scripts/analyze-plugin.mjs` | Job 2: agentic security analysis |
| `.github/scripts/test-bump.sh` | Local end-to-end test |
| `.github/scripts/plugin-bump-design.md` | Full design document |
| `.github/scripts/.envrc.example` | Credentials template |
| `.github/bump/` | Runtime output (matrix, analyses) — not committed |
