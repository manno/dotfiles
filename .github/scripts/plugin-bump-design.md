# Neovim Plugin Bump — Design

Automated weekly workflow that pins Neovim plugins to their latest release
commit SHA, performs an agentic security analysis per plugin, and opens a PR.

## Goals

- Pin every lazy.nvim plugin spec to an exact `commit = "sha"` field
- Compare against the latest **GitHub Release** tag (not HEAD)
- Security-review each update using a model that can explore the full diff
- Keep secrets minimal: `GITHUB_TOKEN` (auto-provided) plus a single
  inference key, `ZAI_API_KEY`

## Non-goals

- CVE scanning (OSV/Trivy): useless for Lua plugins
- Pinning bare dependency strings (requires manual Lua refactor first)

---

## Architecture: three-job workflow

```
┌─────────────┐      matrix JSON      ┌──────────────────────┐
│  1. detect  │ ──────────────────▶  │  2. analyze (matrix)  │
│  (Go)       │                       │  one job per plugin   │
└──────┬──────┘                       └──────────┬───────────┘
       │ updated lua files                        │ {slug}-analysis.md
       │ (artifact)                               │ (artifact)
       └──────────────────┬───────────────────────┘
                          ▼
                   ┌─────────────┐
                   │   3. pr     │
                   │  (shell)    │
                   └─────────────┘
```

### Job 1 — detect (Go)

`go run .github/scripts/bump-nvim-plugins.go`

Responsibilities:
- Discover all `*.lua` files under `dot_config/nvim/lua/plugins/`
  plus `dot_config/nvim/lua/plugins.lua`
- Parse every `'owner/repo'` plugin spec
- For each plugin: call GitHub Releases API → resolve tag to commit SHA
- Compare against existing `commit = "sha"` field (or "unpinned")
- Update `commit = "sha"` in the Lua files in place
- Output a JSON matrix for Job 2:
  ```json
  [{"slug":"folke/snacks.nvim","owner":"folke","repo":"snacks.nvim",
    "old_sha":"abc123","new_sha":"def456","tag":"v2.31.0"}, ...]
  ```
- Upload updated Lua files + matrix JSON as artifacts

No model calls. No PR body. Stays lean.

### Job 2 — analyze (matrix, one job per plugin)

Triggered by the matrix JSON from Job 1.

Each job runs `node .github/scripts/analyze-plugin.mjs` (Node.js ESM, no npm dependencies).

#### Implementation

- Uses Node's built-in `fetch` (Node 20) to call the **z.ai GLM API**
  (`https://api.z.ai/api/paas/v4/chat/completions`, model `glm-4.7`),
  which is OpenAI-compatible at the chat-completions level
- Tool calls are executed via the `gh` CLI (pre-installed on Actions runners)
- No npm install step required
- The conversation must open with a **user** turn. GLM rejects a system-only
  message array with error 1214 (`messages parameter is illegal`) where
  gpt-4o accepted one — the main compatibility gap found when migrating.
- Budget is 20 iterations. On the final turn the tool definitions are
  withheld so the model must answer in prose, guaranteeing a verdict even
  when it has not finished exploring.
- `temperature` is 0.2 (GLM defaults to 1.0) so the same diff yields the
  same verdict across runs. `max_tokens` is 16384 — GLM's `thinking` mode
  is on by default and its reasoning tokens count against that budget.
- GLM intermittently returns an assistant turn with neither content nor
  tool calls. Such a turn is dropped and retried rather than ending the
  audit; without this the run reports a spurious `WARN`.

#### Tools available to the model

The model autonomously decides which tools to call:

- `list_changed_files` → `gh api /repos/{owner}/{repo}/compare/{old}...{new}`
- `get_file_diff(filename)` → same compare endpoint, extracts per-file patch
- `get_file_content(path)` → `gh api /repos/{owner}/{repo}/contents/{path}?ref={sha}`
- `get_commit_details(sha)` → `gh api /repos/{owner}/{repo}/commits/{sha}`

#### Security prompt (per plugin)

Focus areas:
- Shell execution: `vim.fn.system()`, `io.popen()`, `os.execute()`, `jobstart()`
- New network calls or changed remote endpoints
- Credential, token, or environment variable handling
- File writes outside `~/.config` or `~/.local`
- Obfuscated code: base64/hex literals, dynamic `require()`, `loadstring()`
- New autocommands on broad events (`BufWritePost`, `VimEnter`, etc.)

Verdicts: `CLEAN` | `WARN` (must cite file+line) | `BLOCK` (must cite file+line)

Output: `{slug_safe}-analysis.md` uploaded as artifact.

### Job 3 — pr

Runs after all matrix jobs complete (with `if: always()` to tolerate partial
analyze failures).

- Downloads updated Lua files artifact (from Job 1)
- Downloads all `*-analysis.md` artifacts (from Job 2)
- Commits the Lua changes to a `bump/nvim-plugins-{date}` branch
- Builds PR body: summary table + unpinnable list + per-plugin analysis sections
- Creates or updates the PR via `gh pr create` / `gh pr edit`

---

## File layout

```
.github/
  scripts/
    bump-nvim-plugins.go    # Job 1: detect + update
    analyze-plugin.mjs      # Job 2: agentic security analysis
    test-bump.sh            # local end-to-end test
    plugin-bump-design.md   # this file
    .envrc.example          # credentials template
  workflows/
    bump-nvim-plugins.yml
```

---

## Secrets

| Secret | Source | Required for |
|--------|--------|--------------|
| `GITHUB_TOKEN` | Auto-provided by Actions | GitHub API (releases, diffs, file content), `gh pr create` |
| `ZAI_API_KEY` | Repository secret (manual) | z.ai GLM API — inference for Job 2 |

Inference moved to z.ai when **GitHub Models was retired on 2026-07-30**; the
`models: read` permission and the Copilot subscription it required are both
gone. `GITHUB_TOKEN` still covers every GitHub API call, including the four
`gh api` tools the model drives during analysis — no repository is cloned.

`ZAI_API_KEY` is the one manually-managed secret. Create a key at
<https://z.ai/manage-apikey/apikey-list> and add it under
*Settings → Secrets and variables → Actions*.

---

## Lua file pinning

lazy.nvim spec versioning: `commit = "sha"` field on each plugin table.

```lua
-- before
{ "folke/snacks.nvim", priority = 1000, opts = { ... } }

-- after
{ "folke/snacks.nvim", commit = "e6fd58c8", priority = 1000, opts = { ... } }
```

Bare dependency strings (e.g. `dependencies = { "nvim-lua/plenary.nvim" }`)
cannot be pinned without converting to full spec objects. The PR body
lists these and shows how to convert them.

---

## Limitations / future work

- First run pins all plugins to their current latest release; no diff
  available until the second run
- Plugins without GitHub Releases fall back to most recent tag
- `nvim-treesitter` parser downloads are not pinned by this system
- Bare dependency strings require a one-time manual conversion
