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
GitHub Models API (`openai/gpt-4o`, OpenAI-compatible) with iterative tool
calling to examine the actual diff. Tools call `gh api` for file lists,
diffs, file content, and commit details. Produces
`{slug_safe}-analysis.md` with a `CLEAN` / `WARN` / `BLOCK` verdict.

Token budget: GitHub Models caps requests at 8000 tokens. The script prunes
old assistant+tool message pairs from history after each iteration, keeping
only the two most recent pairs plus the system prompt. This allows analysing
large plugins without hitting the limit.

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
  models: read          # GitHub Models API (requires Copilot subscription)
```

No extra secrets. `GITHUB_TOKEN` is auto-provided by Actions and covers all
three uses (GitHub API, Models API, `gh` CLI).

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

- GitHub Models caps gpt-4o request bodies at **8000 tokens**. Large plugins
  with many changed files may still fail if a single diff is enormous.
  `KEEP_PAIRS` in `analyze-plugin.mjs` controls how many message pairs are
  retained; lower it to 1 if errors persist.
- **Unpinnable plugins**: bare dependency strings (e.g.
  `dependencies = { "nvim-lua/plenary.nvim" }`) cannot be pinned
  automatically. Convert them to full spec tables; see the PR body for
  instructions.
- Rate limiting (429): `max-parallel: 3` in the workflow and exponential
  backoff in the script (up to 5 retries, starting at 10 s) handle burst
  traffic from simultaneous jobs.

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
