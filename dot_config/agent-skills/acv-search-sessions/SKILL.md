---
name: acv-search-sessions
description: >-
    Search past agent sessions and discussions (across Copilot, Claude, Gemini,
    agy) using the `acv` CLI. Use whenever the user asks what they did before,
    what was discussed previously, prior approaches to a problem, or to recall
    context from earlier sessions across any project on this machine.
user-invocable: true
---

# Searching prior agent sessions with `acv`

`acv` is a local CLI that indexes transcripts from multiple agent CLIs
(Copilot, Claude, Gemini, agy) on this machine. Use it to recall what
the user previously discussed, decided, or tried — across all projects.

## When to use

- "What did I work on last week / yesterday / in repo X?"
- "Have I discussed <topic> before?"
- "What was the previous approach to <problem>?"
- "Find prior sessions about <symbol/file/repo>."

Prefer `acv` over `session_store_sql` when the user wants free-text
search across *all* local agent sessions (not just Copilot's cloud
session store), or when looking at non-Copilot agents.

## Install

- Source: https://github.com/manno/agent-chat-viewer
- Releases: https://github.com/manno/agent-chat-viewer/releases

## Usage

Always run with `-no-tui` so output is plain text:

```sh
acv -no-tui -f 'PATTERN'
```

`-f` accepts glob-style wildcards (`*`, `?`). The pattern matches both
user and assistant messages.

### Useful flags

- `-f 'pattern'` — search for pattern across all sessions (required for search)
- `-regex` — treat `-f` pattern as a full regex (default is literal with `*` and `?` wildcards)
- `-agent <name>` — restrict to `copilot`, `claude`, `gemini`, or `agy`
- `-project <substr>` — restrict to a project (substring match on path)
- `-since <when>` / `-until <when>` — filter by session last-update time.
  Accepts `YYYY-MM-DD`, RFC3339, or a duration like `7d`, `24h`, `2w`
  (interpreted as "now minus that duration").
- `-limit N` — stop after N matches (avoids dumping huge result sets)
- `-json` — emit one JSON object per hit, no banners (implies `-no-tui`).
  Fields: `agent`, `project`, `session_id`, `path`, `date`, `role`, `time`, `snippet`.
- `-s` — include start time in listing
- `-files` — list agent artifact files (tool-results, logs) instead of messages
- `-memories` — list agent memory files instead of messages

`-no-tui` is also implied automatically when stdout is not a terminal, so
piping `acv -f ...` from a script works without it.

### Examples

Find every session mentioning a symbol:
```sh
acv -no-tui -f 'some-function'
```

Restrict to a specific agent and project:
```sh
acv -no-tui -agent copilot -project my-repo -f 'some-feature'
```

Wildcards:
```sh
acv -no-tui -f 'helm*chart'
```

Recent sessions only, with a hard cap, as JSON for downstream parsing:
```sh
acv -json -since 7d -limit 20 -f 'oauth'
```

Use a real regex:
```sh
acv -no-tui -regex -f 'foo(bar|baz)+'
```

## Reading the output

Each hit is a single matching message, formatted as:

```
[<agent>] <project> | <YYYY-MM-DD> | <USER|ASSISTANT> | <session-id>
  path: <full path to session file>
  ...snippet around the match (~100 chars on each side)...
----------------------------------------
```

To open the full session, pass the `path` to `acv`:

```sh
acv -no-tui /Users/.../session-state/<uuid>/events.jsonl
```

Or use the index from `acv -no-tui` (note: index is sort-order
dependent and can shift between runs — prefer the path).

## Tips

- Start with a broad pattern, then narrow with `-agent` / `-project`
  once you see which sessions are relevant.
- For Copilot-specific structured queries (token usage, tool calls,
  PR/issue refs, exact timestamps), prefer `session_store_sql` — it
  has richer schema. Use `acv` for free-text recall across agents.
- Always pass `-no-tui`; the default TUI mode is interactive and not
  usable from a non-interactive shell.
