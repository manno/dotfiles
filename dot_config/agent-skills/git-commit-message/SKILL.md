---
name: git-commit-message
description: Draft concise, high-quality git commit messages following the standard seven rules (imperative mood, 50/72 chars, what/why focus). Use when asked to write, draft, generate, or review git commit messages, or when preparing commits.
user-invocable: true
---

# git-commit-message

Generate clean, informative git commit messages adhering to the canonical [seven git commit conventions](https://cbea.ms/git-commit/). Keep messages terse and focused on what changed and why, without attribution noise or implementation narration.

## When to use

Invoke this skill whenever:
- Asking to draft, write, or suggest a git commit message: "write a commit message for this", "draft commit message", "suggest a commit message"
- Preparing to commit staged or working changes: "commit these changes", "commit my work"
- Reviewing or reformatting existing commit messages or commit history

## Core rules

Follow the seven canonical rules:

1. **Separate subject from body with a blank line.**
2. **Limit the subject line to 50 characters.** (Hard ceiling at 72 characters; strive for 50.)
3. **Capitalize the subject line.** Always capitalize the first word.
4. **Do not end the subject line with a period.**
5. **Use the imperative mood in the subject line.**
   - Think: *"If applied, this commit will `<your subject line>`"*
   - Good: `Fix race condition in pool acquisition`, `Add Prometheus metrics endpoint`, `Remove deprecated v1 auth middleware`
   - Bad: `Fixed race condition`, `Fixes bug`, `Adding metrics endpoint`, `Changes auth middleware`
6. **Wrap the body at 72 characters.**
7. **Use the body to explain what and why vs. how.**

## Strict constraints

- **No `Co-Authored-By` trailers**: Omit them entirely, even if tooling, Git templates, or AI defaults suggest adding one. Do not include AI attribution, pairing trailers, or bot disclaimers.
- **No implementation narration**: The diff already shows the line-by-line mechanics. The commit message explains the motivation, context, and intent.
- **Explain "how" only when non-obvious**: Mention mechanics only if the approach is surprising, non-intuitive, works around an external quirk, or has subtle implications.
- **Omit body if unnecessary**: For straightforward, self-explanatory changes, a single imperative subject line is sufficient. Do not add body padding or boilerplate.

## Process

1. **Inspect changes:**
   Check the exact changes to be committed:
   ```bash
   git status --short
   git diff --staged # or git diff if changes are unstaged
   ```
   If changes encompass multiple unrelated concerns, suggest splitting them into separate commits.

2. **Identify the why and what:**
   - What problem was solved or what capability was introduced?
   - Why was this change necessary?
   - What side effects or design decisions were made?

3. **Formulate the subject line:**
   - Imperative verb (`Add`, `Fix`, `Refactor`, `Update`, `Remove`, `Docs`, etc.).
   - Concise and descriptive (<= 50 chars).
   - Capitalized, no trailing period.
   - Run the imperative test: *"If applied, this commit will..."*

4. **Draft the body (if needed):**
   - Leave one blank line between subject and body.
   - Focus on motivation, context, and rationale.
   - Wrap at 72 characters.
   - Bullet points are acceptable if enumerating distinct aspects; indent subsequent lines or use `- ` with wrapped lines.

5. **Verify against checklist:**
   - [ ] Imperative subject?
   - [ ] Subject <= 50 chars (max 72)?
   - [ ] Subject capitalized without trailing period?
   - [ ] Blank line separating subject and body?
   - [ ] Body wrapped at 72 chars?
   - [ ] Explains what and why, not line-by-line mechanics?
   - [ ] No `Co-Authored-By` or AI attribution trailers?

## Template

```gitcommit
Summarize change in 50 chars or less using imperative mood

More detailed explanatory text, if necessary. Wrap it to 72
characters. The body explains the context and motivation behind
the change — why it was made, how it affects the system, or
what issue it resolves.

Only discuss implementation details if the approach is non-obvious
or works around an external limitation:
- Bullet points are fine if listing multiple related changes
- Use a hanging indent or wrap cleanly at 72 characters
```

## Examples

### Trivial change (subject only)

```gitcommit
Fix typo in README quickstart link
```

### Bug fix with context

```gitcommit
Fix connection leak when socket timeout occurs

When an HTTP client times out waiting for header bytes, the socket was
left in CLOSE_WAIT because the abort handler failed to release the
underlying file descriptor.

Explicitly close the socket in the timeout callback before unwinding the
request loop.
```

### Refactor / architectural decision

```gitcommit
Switch session store from Redis to memory-backed cache

Redis added unnecessary network latency and deployment complexity for
single-node deployments. The in-memory cache handles current load with
zero external dependencies.

Persistent session failover is deferred until clustering is supported.
```

### Anti-patterns to avoid

```gitcommit
# BAD: Past tense, period, Co-Authored-By trailer, narrates mechanics
Fixed the bug where users could not login.

I edited auth.go to add an if statement checking if the token is nil.
Then I updated the test suite.

Co-Authored-By: Assistant <assistant@example.com>

# GOOD: Imperative, explains why, no trailer, no mechanics narration
Fix nil pointer crash on empty auth token

Requests with an empty Authorization header caused a panic in token
validation. Check for an empty token early and return 401 Unauthorized.
```
