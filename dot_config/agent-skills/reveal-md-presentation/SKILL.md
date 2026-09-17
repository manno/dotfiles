---
name: reveal-md-presentation
description: Create and serve a reveal.js slide deck as a single markdown file using reveal-md (installed via Homebrew). Use when the user asks to create a presentation/slide deck/reveal.js deck, or to present a topic "with reveal.js or something". Covers front matter, theming, speaker notes, live preview, and PDF export.
user-invocable: true
---

# reveal-md-presentation

Author a reveal.js deck as one clean markdown file and drive it with the `reveal-md` CLI (already installed via Homebrew — do not `npm install` it).

## When to use

- "create a presentation for X" / "make me some slides on X"
- "I can present with reveal.js or something"
- "add speaker notes to the deck" / "theme this deck"
- "export/print the deck to PDF"

## Process

### 1. Lay out the deck

Put the deck in its own directory alongside any theme CSS, e.g. `docs/<name>/presentation.md`. Keep the CSS file in the **same directory** as the markdown — this matters (see gotcha #1 below).

Write **clean markdown only** — no inline HTML/`<div>`/`<span>` divider slides unless the user explicitly wants custom per-slide styling. Plain `#`/`##` headings plus front matter + a CSS theme goes a long way and is far easier to maintain.

Structure:
```markdown
---
title: My Deck Title
css: theme.css
revealOptions:
  width: 1600
  height: 900
  margin: 0.04
  minScale: 0.2
  maxScale: 2.0
  hash: true
  slideNumber: "c/t"
  transition: slide
  center: false
---

# My Deck Title

### Subtitle

Note: Speaker notes for the title slide.

---

## Section heading

- bullet one
- bullet two

Note: Notes for this slide.

---

## Next slide
...
```

- Horizontal slides: separate with a line containing only `---`.
- Vertical (sub-)slides: separate with `--`, and set `verticalSeparator` in front matter if you use them.
- **Speaker notes**: a line starting with `Note:` works natively with reveal-md (it configures `data-separator-notes` itself) — no `<aside class="notes">` needed. Only fall back to `<aside class="notes">` if the same markdown must also render correctly in plain reveal.js or pandoc (which don't recognize `Note:`).
- Keep each slide focused (a heading + a handful of bullets); split into more `---`-separated slides rather than cramming.

### 2. Preview while writing

```bash
cd docs/<name>          # cwd matters, see gotcha #1
reveal-md presentation.md --watch   # live-reload as you edit
```
Iterate on content with the browser open; reveal-md hot-reloads on save.

### 3. Theme with CSS (optional)

Reference a CSS file via the `css:` front-matter key (see example above). Reveal-md serves it at `/_assets/<file>.css` and injects the `<link>` client-side (a plain `curl` of `/` won't show it — that's expected, not a bug). Write CSS using reveal.js's CSS custom properties / class selectors (`.reveal h1`, `.reveal .slides section`, etc.) rather than fighting the framework.

If reusing an existing non-reveal-md HTML template/theme, don't try to port its JS (it likely calls `Reveal.initialize()` itself, which will clash with reveal-md's own init) — extract just the CSS.

### 4. Export for sharing

**Static site** (self-contained HTML/CSS/JS bundle):
```bash
reveal-md presentation.md --static _site
```

**PDF**:
```bash
reveal-md presentation.md --print presentation.pdf
```
If this fails with a Chrome/puppeteer spawn error, see gotcha #2 below.

**To PowerPoint/Google Slides** (image-per-slide only, not editable text — reveal.js decks have no native editable-slide export path):
1. Generate the PDF first (above).
2. Open Keynote, create a blank presentation, then drag the PDF into the slide navigator — it imports each page as an image slide.
3. `File → Export To → PowerPoint (.pptx)`, then upload the `.pptx` to Google Slides.
- CLI alternative: `soffice --headless --convert-to pptx presentation.pdf` (LibreOffice) — same image-per-slide result.
- If the user wants **editable text** instead of images and the deck is plain markdown with `---` separators, suggest `pandoc` directly on the markdown (pandoc understands reveal.js-style separators natively) rather than going through the rendered PDF.

### 5. Verify before handing off

- `grep -c '^---$' presentation.md` to sanity check slide count.
- Confirm the CSS actually loads: run reveal-md from the deck's own directory and curl the deck path (not `/`, which is a directory listing) — check for the theme's `<link>` and a couple of known CSS variable names.
- Tell the user the exact `cd`+`reveal-md` invocation to use, since cwd matters (gotcha #1).

## Gotchas (learned the hard way)

1. **`css:` front-matter path resolves relative to reveal-md's cwd, not the markdown file's directory.** Always `cd` into the deck's directory before running `reveal-md`, and keep the CSS file there too. Running from the repo root with `reveal-md docs/name/presentation.md --css docs/name/theme.css` will silently fail to load the theme (`ENOENT` on the bare filename) or serve a directory listing instead of the deck if you curl `/` instead of the actual file path.
2. **`--print` (PDF export) can fail with `spawn Unknown system error -88` on macOS.** Puppeteer-core's auto-downloaded "Chrome for Testing" binary is unsigned, and macOS blocks unsigned arm64 binaries at spawn; ad-hoc `codesign` on it also fails strict validation. Fix: point reveal-md at the user's existing signed system Chrome:
   ```bash
   reveal-md presentation.md --print presentation.pdf \
     --puppeteerChromiumExecutable "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
   ```
   (CLI flag is camelCase `--puppeteerChromiumExecutable`, read via yargs — not `--puppeteer-executable`.)
3. **`Note:` works with reveal-md specifically** (it sets `data-separator-notes` by default) but is not portable to plain reveal.js or pandoc — use `<aside class="notes">` if the markdown needs to work in those too.
4. **Don't fight front matter with inline HTML.** If the deck starts accumulating `<div class="...">`, `data-state="..."` divider comments, etc. to get a themed look, stop and move that styling into the CSS file instead — plain markdown + `css:` front matter is far easier to maintain and was explicitly preferred over hand-rolled HTML slides in past sessions.
5. `reveal-md --version` / `which reveal-md` should show the Homebrew Cellar path (e.g. `/opt/homebrew/Cellar/reveal-md/<ver>/...`) — don't `npm install -g reveal-md` alongside it.

## Environment notes

- `reveal-md` — Homebrew-installed (`brew install reveal-md`), don't reinstall via npm.
- For PDF export troubleshooting, `DEBUG=reveal-md reveal-md ... --print ...` gives verbose puppeteer logs.
- LibreOffice (`soffice`) — only needed for the optional PDF→PPTX conversion step.
