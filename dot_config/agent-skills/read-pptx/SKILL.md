---
name: read-pptx
description: Read and extract content from a PowerPoint (.pptx/.ppt) file — slide text, speaker notes, tables, and embedded images. Use when the user asks to read, summarize, extract from, or answer questions about a .pptx/.ppt presentation file.
user-invocable: true
---

# read-pptx

Extract structured content from a PowerPoint file so it can be summarized or queried, without opening PowerPoint/Keynote.

## When to use

- "read this pptx and summarize it"
- "what does slide 5 say?"
- "extract the speaker notes from this deck"
- "pull the text/tables out of this presentation"
- User attaches or references a `.pptx`/`.ppt` file

## Process

### 1. Confirm the file and format

- `.pptx` (OOXML, zip-based) — handle directly with `python-pptx`.
- `.ppt` (legacy binary format) — not supported by `python-pptx`. Tell the user you need a `.pptx` file (no converter is available in this environment).

### 2. Set up python-pptx in a venv

`pip install python-pptx` fails on macOS with externally-managed-environment errors. Use a venv instead:

```bash
python3 -m venv /tmp/pptx-venv
/tmp/pptx-venv/bin/pip install -q python-pptx
```

### 3. Extract text content with python-pptx

```bash
/tmp/pptx-venv/bin/python3 - "$FILE" << 'PYEOF'
import sys
from pptx import Presentation
from pptx.util import Emu

path = sys.argv[1] if len(sys.argv) > 1 else "FILE_PATH"
prs = Presentation(path)

for i, slide in enumerate(prs.slides, 1):
    print(f"\n=== Slide {i} ===")
    for shape in slide.shapes:
        if shape.has_text_frame:
            text = "\n".join(p.text for p in shape.text_frame.paragraphs if p.text)
            if text.strip():
                print(text)
        if shape.has_table:
            print("[table]")
            for row in shape.table.rows:
                print(" | ".join(cell.text for cell in row.cells))
        if shape.shape_type == 13:  # PICTURE
            print(f"[image: {shape.name}]")
    if slide.has_notes_slide and slide.notes_slide.notes_text_frame.text.strip():
        print("--- notes ---")
        print(slide.notes_slide.notes_text_frame.text)
PYEOF
```

Replace `FILE_PATH` / pass the real path as the script argument. This prints slide text, table contents, notes, and flags embedded images by name — enough for most summarization/Q&A tasks.

### 4. When embedded images matter

Text extraction loses chart/diagram/image content. Extract embedded images directly instead and view them with the `view` tool:

```python
for i, slide in enumerate(prs.slides, 1):
    for shape in slide.shapes:
        if shape.shape_type == 13:
            img = shape.image
            with open(f"/tmp/slide{i}_{shape.shape_id}.{img.ext}", "wb") as f:
                f.write(img.blob)
```

### 5. Report

Summarize per-slide or thematically as the user requested. Cite slide numbers when referencing specific content. Note any slides that were image-only / had no extractable text — flag them so the user knows content may be missing.

## Environment notes

- `python-pptx` is not installed by default. Check first with `/tmp/pptx-venv/bin/python3 -c "import pptx"` (or plain `python3 -c "import pptx"` if a venv already exists). Create the venv per step 2 rather than running a bare `pip install`.
- Clean up temp files under `/tmp` (including the venv) after the task unless the user asked to keep them.
