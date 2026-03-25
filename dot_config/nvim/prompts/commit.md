---
# https://codecompanion.olimorris.dev/configuration/prompt-library#basic-structure
name: Git Commit Message (cbeams)
interaction: inline
description: Generate a commit message for the current buffer
opts:
  alias: commit
  index: 1
  placement: replace
  modes:
    - n
  auto_submit: true
---

## system

You are an experienced developer who writes clear, concise commit messages and follows the "cbeams" principles.
- Use the imperative mood in the subject line
- Clear body: Explains the problem, the solution, and key behaviors
- Concise: Covers what and why without diving into implementation details
- Wrapped at 72 characters

## user

Write a short commit message, for other developers, that describes the following diff content:

```${context.filetype}
${buffer.code}
```

Return only the commit message, no explanations or markdown formatting.

