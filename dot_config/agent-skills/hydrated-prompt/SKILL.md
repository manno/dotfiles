---
name: hydrated-prompt
description: Distill the current session's accumulated context (sources read, decisions made, open questions) into a self-contained briefing that bootstraps a fresh agent to continue the work. Use when the user asks to "create a hydrated prompt", "hand off to another agent", "compile what we've learned for the next agent", or similar. Output is a markdown file the next agent can load with @path.
user-invocable: true
---

# hydrated-prompt

A hydrated prompt is a self-contained briefing for a fresh agent — every absolute file path, URL, decision, and constraint the next agent needs, with no implicit context from this session.

## When to use

Invoke when the user asks (variants):
- "create a hydrated prompt for X"
- "hand this off to another agent"
- "write up what we've learned so far for the next agent"
- "compile a prompt so another session can continue"

Do NOT use as a generic session recap — a hydrated prompt is an actionable briefing, not a summary.

## Process

1. **Resolve the goal.** What should the next agent *do*? One sentence. If unclear, ask the user before writing.

2. **Pick the output path.** Default `PROMPT-<slug>.md` in the current working directory. If the repo has a `dev/` directory and it's gitignored, prefer `dev/PROMPT-<slug>.md`. Ask the user if the path isn't obvious.

3. **Gather context from this session only** — do not invent or pull from memory:
   - Absolute file paths read or modified (Read/Edit/Write tool calls)
   - URLs fetched (WebFetch, gh, WebSearch)
   - Commands run that produced load-bearing output
   - Decisions the user made (and the alternative that was rejected)
   - Constraints / non-goals the user named
   - Open questions or unknowns the session did not resolve

4. **Structure the markdown** with these sections, in this order. Skip a section when its content would be empty — don't pad:

   ```
   # Goal
   One paragraph: what the next agent should accomplish and why.

   # Context
   What's already established. Bullet form, terse, no narrative.

   # Sources
   Every file/URL the next agent needs, with a one-line annotation each:
   - `/abs/path/to/file.go` — what it contains, why it matters
   - https://... — what to look for there

   # Decisions made
   - Chose X over Y because Z (rejected: Y, because …)

   # Constraints
   - Hard rules the next agent must follow

   # Open questions
   - Things the session left undecided, with the options on the table

   # Suggested next steps
   1. First action, with the exact command/file if known
   2. …
   ```

5. **Write the file**, then tell the user the path and how to load it: `@<path>` in the next session.

## What to leave out

- Generic Claude Code instructions — the next agent already has them
- Conversation flow ("first we tried X, then Y") — the *result* matters, not the path to it
- Facts not actually established this session
- Padding sections — an empty "Open questions" is a sign you're done, not a section to invent

## Style

Match the repo's conventions where visible (commit style, naming). Default to terse — the next agent doesn't need persuading, just briefing.
