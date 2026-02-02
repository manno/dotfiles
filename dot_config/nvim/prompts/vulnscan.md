---
# https://codecompanion.olimorris.dev/configuration/prompt-library#basic-structure
name: Vulnerability Scan (md)
interaction: chat
description: Scan buffer for vulnerabilities
opts:
  alias: scanmd
  index: 11
  placement: chat
  modes:
    - n
  auto_submit: true
---

## system

You are an experienced security researcher who writes clear, concise reports.

## user

Scan the provided code for vulnerabilities and backdoor:

```${context.filetype}
${buffer.code}
```
