---
name: mermaid-chart
description: Create a Mermaid diagram with an mmdc validation feedback loop — draft, validate syntax with mmdc, fix errors, repeat until clean. Use when the user asks to create, draw, or diagram something as a Mermaid chart.
user-invocable: true
---

# mermaid-chart

Create a Mermaid diagram and validate it with `mmdc` before presenting it. Never show a chart that hasn't passed validation.

## When to use

- "create a mermaid chart of X"
- "draw a diagram of X"
- "make a flowchart / sequence diagram / ER diagram / class diagram for X"
- After explaining a system architecture: "can you visualise that?"

## Process

### 1. Choose diagram type

Pick the right Mermaid type for the content:
- `flowchart TD/LR` — pipelines, build stages, decision trees, data flows
- `sequenceDiagram` — API calls, protocol handshakes, request/response flows
- `classDiagram` — type hierarchies, interfaces, struct relationships
- `erDiagram` — database schemas
- `gitGraph` — branch/merge history
- `stateDiagram-v2` — state machines, lifecycle stages
- `pie` — proportional data

### 2. Draft the diagram

Write the diagram in full. Avoid syntax pitfalls:
- Node labels with special characters (`×`, `→`, `→`, `★`, `–`) must be inside quotes: `["label with → arrow"]`
- Long labels: use `\n` for line breaks inside node labels
- Subgraph IDs must not contain spaces; use `["Display Name"]` for the display label: `subgraph FOO["My Label"]`
- `&` shorthand (`A --> B & C`) is valid but test it — some mmdc versions reject it in edge labels
- Don't use emoji in node IDs, only in quoted labels
- `-.->` is dashed arrow, `-->` solid, `==>` thick
- Edge labels go inside `|"label"|` — quote them if they contain spaces or special chars: `A -.->|"COPY src"| B`

### 3. Validate with mmdc

Write the diagram to a temp file and run mmdc:

```bash
cat > /tmp/diagram-check.mmd << 'MMDEOF'
<diagram content>
MMDEOF

PUPPETEER_EXECUTABLE_PATH="$(which google-chrome || which chromium || echo '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome')" \
  mmdc -i /tmp/diagram-check.mmd -o /tmp/diagram-check.svg 2>&1
```

**Interpret the output:**
- No output / exit 0 → syntax valid, SVG generated
- `Error: Parse error` → fix the offending line (mmdc usually prints the line/token)
- Chrome not found error → set `PUPPETEER_EXECUTABLE_PATH` to the path of an installed Chromium-based browser
- `Could not find Chrome` with no system Chrome → try `mmdc -i ... -o ... --puppeteerConfigFile /dev/null` as a fallback, or note that the user needs to install Chrome

### 4. Fix and re-validate

If mmdc reports errors, fix the diagram and re-run. Common fixes:
- Wrap node labels in quotes if they contain special chars
- Replace `×`, `→`, `★` with plain ASCII (`x`, `->`, `*`)
- Split a long `subgraph` label onto the ID line using the `["..."]` form
- Remove unsupported syntax for the chosen diagram type

Repeat until mmdc exits cleanly.

### 5. Output

Present the validated diagram in a fenced `mermaid` code block. Note the diagram type at the top of your response. Do not explain what mmdc did — just present the diagram.

If the user asked to save it to a file, write the `.mmd` file (diagram source only, no fences).

## Environment notes

- `mmdc` — install via `npm install -g @mermaid-js/mermaid-cli` (see https://github.com/mermaid-js/mermaid-cli)
- Always set `PUPPETEER_EXECUTABLE_PATH` to an installed Chromium-based browser — the bundled Puppeteer cache may not match what's installed
- On macOS: `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome`
- On Linux: typically `$(which google-chrome)` or `$(which chromium)`
- Temp files: use `/tmp/diagram-check.mmd` and `/tmp/diagram-check.svg`; clean up after if the user didn't ask to save
