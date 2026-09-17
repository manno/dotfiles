---
name: pandoc-md-to-pptx
description: Convert a markdown slide deck (reveal.js/reveal-md style, with `---` slide separators and `##` headings) to an editable .pptx with pandoc, for import into Google Slides or PowerPoint. Use when the user asks to export/convert a markdown presentation to pptx/PowerPoint/Google Slides and wants editable text (not slide images).
user-invocable: true
---

# pandoc-md-to-pptx

Convert a markdown presentation directly to `.pptx` with **editable text** (real text runs, not rasterized slide images) using pandoc's native slide-show writer.

## When to use

- "convert this presentation.md to pptx"
- "can I import this into Google Slides?" (and the deck is markdown, not already a PDF)
- "export the reveal.js deck as PowerPoint, but I want to still be able to edit the text"

Prefer this over any PDF/image based route (e.g. reveal-md `--print` + Keynote drag-in) whenever the user wants editable slides — that path only produces one image per slide.

## Prerequisites

```bash
which pandoc || brew install pandoc   # one-time
```

## Conversion

Pandoc understands reveal.js/reveal-md style decks natively: `---` on its own line is a horizontal rule, which pandoc's slide writers treat as an explicit slide break, and headings at or above `--slide-level` start new slides too.

```bash
pandoc presentation.md -t pptx -o presentation.pptx --slide-level=2
```

- `--slide-level=2` means `##` headings start a new slide (title slides use `#`). Match this to the deck's actual heading convention — if the deck uses `#` for section headers instead, use `--slide-level=1`.
- Run this from the deck's directory so any relative image paths in the markdown resolve correctly.
- Output is a genuine OOXML `.pptx` with editable text runs — verified previously by inspecting `ppt/slides/slideN.xml` inside the zip and confirming `<a:t>` text nodes (not embedded images).

## What carries over vs. what doesn't

| Carries over | Does not carry over |
|---|---|
| Heading text, bullets, nested lists, bold/italic | Custom CSS theme (`css:` front-matter key) — pptx has no CSS |
| Speaker notes (`Note:` lines) → real PPTX speaker notes | `revealOptions` (width/height/transitions/etc.) |
| Basic slide breaks from `---` and headings | Custom HTML/`<div>`/`data-state` styling in the markdown |

Tell the user up front: the result will look plain (default pptx theme) and will need restyling in Slides/PowerPoint — only the content structure transfers.

## Import into Google Slides

1. Upload `presentation.pptx` to Google Drive.
2. Open it — Drive auto-opens `.pptx` files in Google Slides, or right-click → **Open with → Google Slides**.
3. Optionally **File → Save as Google Slides** to convert it to a native Slides file (otherwise it stays a pptx-backed file editable in Slides).

## Verify before handing off

- Slide count sanity check: `unzip -l presentation.pptx | grep -c 'ppt/slides/slide[0-9]*\.xml$'`
- Confirm text is real (not images): `unzip -p presentation.pptx ppt/slides/slide1.xml | grep -o '<a:t>[^<]*</a:t>'` should print actual slide text.
- If the deck mixes `---` separators with headings at the same conceptual boundary, double-check for unexpected blank/duplicate slide breaks (a `---` immediately followed by a `##` heading can each count as a break) — inspect a couple of slides in PowerPoint/Slides after import and drop empty ones if present.

## Gotchas

- YAML front matter written for reveal-md (`css:`, `revealOptions:`, `separator:`, etc.) is either ignored or only partially used by pandoc — `title:`/`author:`/`date:` metadata does become the title slide, but presentation-only keys are silently dropped. No need to strip them first; just don't expect them to have any effect.
- This is one-way and lossy for styling — don't present it as a full-fidelity export. Set that expectation with the user before they open it.
- If the user instead wants a visual/pixel-perfect copy (not editable), point them to the reveal-md PDF export + Keynote/LibreOffice image-import path instead (see the `reveal-md-presentation` skill).
