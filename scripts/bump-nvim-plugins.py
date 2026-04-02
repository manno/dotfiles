#!/usr/bin/env python3
"""
bump-nvim-plugins.py

Scans Neovim plugin config files for lazy.nvim plugin specs, checks each
plugin's latest GitHub release, and updates commit = "sha" pins. Calls
Claude to analyze changes and writes .github/pr-body.md for the PR.

Usage:
  GITHUB_TOKEN=... ANTHROPIC_API_KEY=... python scripts/bump-nvim-plugins.py

Required env vars:
  GITHUB_TOKEN       GitHub token with repo read access
  ANTHROPIC_API_KEY  Anthropic API key
"""

import json
import os
import re
import sys
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional
import urllib.error
import urllib.request

try:
    import anthropic
except ImportError:
    print("Error: anthropic package not installed. Run: pip install anthropic", file=sys.stderr)
    sys.exit(1)

# ── Configuration ──────────────────────────────────────────────────────────────

REPO_ROOT = Path(__file__).parent.parent

LUA_PLUGIN_FILES = [
    "dot_config/nvim/lua/plugins.lua",
    "dot_config/nvim/lua/plugins/assistance.lua",
    "dot_config/nvim/lua/plugins/completion.lua",
    "dot_config/nvim/lua/plugins/completion-copilot.lua",
    "dot_config/nvim/lua/plugins/completion-minuet.lua",
]

GITHUB_TOKEN = os.environ.get("GITHUB_TOKEN", "")
ANTHROPIC_API_KEY = os.environ.get("ANTHROPIC_API_KEY", "")

# Matches GitHub slugs: 'owner/repo' or "owner/repo"
SLUG_RE = re.compile(r"""['"]([A-Za-z0-9][A-Za-z0-9_.-]*/[A-Za-z0-9][A-Za-z0-9_.-]*)['"]""")


# ── Data structures ────────────────────────────────────────────────────────────

@dataclass
class PluginSpec:
    slug: str
    owner: str
    repo: str
    filepath: Path
    pos: int               # character position of slug in file
    current_commit: Optional[str] = None
    is_pinnable: bool = True  # False for bare strings in dependency arrays


@dataclass
class PluginUpdate:
    spec: PluginSpec
    new_sha: str
    tag: str
    release_notes: str
    commits: list[str] = field(default_factory=list)


# ── GitHub API ─────────────────────────────────────────────────────────────────

def gh_get(path: str) -> Optional[dict | list]:
    url = f"https://api.github.com{path}"
    req = urllib.request.Request(url)
    req.add_header("Authorization", f"Bearer {GITHUB_TOKEN}")
    req.add_header("Accept", "application/vnd.github+json")
    req.add_header("X-GitHub-Api-Version", "2022-11-28")
    req.add_header("User-Agent", "bump-nvim-plugins/1.0")
    try:
        with urllib.request.urlopen(req, timeout=20) as resp:
            return json.loads(resp.read())
    except urllib.error.HTTPError as e:
        if e.code in (404, 451):
            return None
        body = e.read().decode(errors="replace")
        print(f"  GitHub API {e.code} for {path}: {body[:120]}", file=sys.stderr)
        raise


def resolve_tag_sha(owner: str, repo: str, tag: str) -> Optional[str]:
    """Resolve a tag name to a commit SHA, dereferencing annotated tags."""
    ref = gh_get(f"/repos/{owner}/{repo}/git/ref/tags/{tag}")
    if not ref:
        return None
    obj = ref.get("object", {})
    if obj.get("type") == "tag":
        # Annotated tag: dereference the tag object to its commit
        tag_obj = gh_get(f"/repos/{owner}/{repo}/git/tags/{obj['sha']}")
        if tag_obj:
            return tag_obj.get("object", {}).get("sha")
    return obj.get("sha")


def get_latest_release(owner: str, repo: str) -> tuple[Optional[str], Optional[str], str]:
    """
    Return (commit_sha, tag_name, release_notes).
    Tries GitHub Releases first, falls back to the most recent tag.
    Skips pre-releases.
    """
    release = gh_get(f"/repos/{owner}/{repo}/releases/latest")
    if release and isinstance(release, dict) and not release.get("prerelease"):
        tag = release["tag_name"]
        sha = resolve_tag_sha(owner, repo, tag)
        if sha:
            return sha, tag, release.get("body") or ""

    # No formal release — try most recent tag
    tags = gh_get(f"/repos/{owner}/{repo}/tags?per_page=1")
    if tags and isinstance(tags, list) and tags:
        tag = tags[0]["name"]
        sha = resolve_tag_sha(owner, repo, tag)
        if sha:
            return sha, tag, ""

    return None, None, ""


def get_commits_between(owner: str, repo: str, old_sha: str, new_sha: str) -> list[str]:
    """One-line commit messages between two SHAs (up to 30)."""
    data = gh_get(f"/repos/{owner}/{repo}/compare/{old_sha}...{new_sha}")
    if not data or not isinstance(data, dict):
        return []
    return [
        f"- {c['sha'][:8]} {c['commit']['message'].splitlines()[0]}"
        for c in data.get("commits", [])[:30]
    ]


# ── Lua parsing ────────────────────────────────────────────────────────────────

def find_enclosing_brace(content: str, pos: int) -> tuple[int, int]:
    """
    Find the { ... } block that immediately encloses the position pos.
    Scans backward for the opening {, then forward for the matching }.
    Returns (start, end) or (-1, -1).
    """
    # Scan backward: find the first { where only whitespace/newlines sit between it and pos
    start = -1
    for i in range(pos - 1, max(0, pos - 300), -1):
        ch = content[i]
        if ch == '{':
            start = i
            break
        elif ch not in ' \t\n,':
            # Non-whitespace before the { — stop
            break

    if start == -1:
        return -1, -1

    # Scan forward: find the matching } by tracking brace depth
    depth = 0
    for i in range(start, min(len(content), start + 8000)):
        if content[i] == '{':
            depth += 1
        elif content[i] == '}':
            depth -= 1
            if depth == 0:
                return start, i

    return start, -1


def is_pinnable_spec(content: str, pos: int, brace_start: int) -> bool:
    """
    True if the slug at pos is the first element of a table spec (pinnable),
    False if it's a bare string element inside an assignment like `dependencies = { ... }`.

    Heuristic: look at what precedes the opening {.
    If the char before { (ignoring whitespace) is `=`, this is an assignment value.
    """
    if brace_start == -1:
        return False

    # Check that only whitespace separates { from the slug
    between = content[brace_start + 1:pos]
    if not re.match(r'^\s*$', between):
        return False

    # Check what precedes the {
    before = content[:brace_start].rstrip()
    if not before:
        return True

    last_char = before[-1]
    # `= {` means this { opens an assignment value (dependencies, opts, etc.)
    # But `== {`, `>= {`, `<= {`, `~= {` are comparisons — very unlikely in this context
    if last_char == '=' and (len(before) < 2 or before[-2] not in ('=', '!', '<', '>', '~')):
        return False

    return True


def find_current_commit(content: str, brace_start: int, brace_end: int) -> Optional[str]:
    """Find commit = "sha" within a plugin spec block."""
    if brace_start == -1 or brace_end == -1:
        return None
    block = content[brace_start:brace_end + 1]
    m = re.search(r"""commit\s*=\s*['"]([a-f0-9]{7,40})['"]""", block)
    return m.group(1) if m else None


def parse_all_plugins(lua_files: list[str]) -> list[PluginSpec]:
    """
    Parse all plugin specs from the given Lua files.
    Returns one PluginSpec per (slug, filepath) combination so that
    the same plugin in multiple files (e.g. blink.cmp) gets updated everywhere.
    """
    results: list[PluginSpec] = []
    seen_in_file: set[tuple[Path, str]] = set()

    for rel_path in lua_files:
        filepath = REPO_ROOT / rel_path
        if not filepath.exists():
            print(f"Warning: {rel_path} not found, skipping", file=sys.stderr)
            continue

        content = filepath.read_text()

        for m in SLUG_RE.finditer(content):
            slug = m.group(1)
            key = (filepath, slug)
            if key in seen_in_file:
                continue
            seen_in_file.add(key)

            # Skip strings that are values for non-plugin keys (import=, cmd=, event=, ft=, etc.)
            before = content[max(0, m.start() - 30):m.start()]
            if re.search(r'\b(import|cmd|event|ft|cond|dir|section|pattern|adapter)\s*=\s*$', before.rstrip()):
                continue

            # Skip commented-out lines
            line_start = content.rfind('\n', 0, m.start()) + 1
            line_prefix = content[line_start:m.start()]
            if line_prefix.lstrip().startswith('--'):
                continue

            pos = m.start()
            brace_start, brace_end = find_enclosing_brace(content, pos)
            pinnable = is_pinnable_spec(content, pos, brace_start)
            current_commit = find_current_commit(content, brace_start, brace_end)

            owner, repo = slug.split("/", 1)
            results.append(PluginSpec(
                slug=slug,
                owner=owner,
                repo=repo,
                filepath=filepath,
                pos=pos,
                current_commit=current_commit,
                is_pinnable=pinnable,
            ))

    return results


# ── File modification ──────────────────────────────────────────────────────────

def update_commit_in_file(filepath: Path, slug: str, new_sha: str) -> bool:
    """
    Add or update `commit = "sha"` for a plugin spec in a Lua file.
    Returns True if the file was modified.
    """
    content = filepath.read_text()

    # Find the slug in this file
    m = None
    for match in SLUG_RE.finditer(content):
        if match.group(1) == slug:
            m = match
            break
    if not m:
        return False

    pos = m.start()
    brace_start, brace_end = find_enclosing_brace(content, pos)
    if brace_start == -1 or brace_end == -1:
        print(f"  Warning: could not find table bounds for {slug} in {filepath.name}", file=sys.stderr)
        return False

    block = content[brace_start:brace_end + 1]

    if re.search(r"""commit\s*=\s*['"][a-f0-9]+['"]""", block):
        # Replace existing commit SHA (handles both ' and " delimiters)
        new_block = re.sub(
            r"""(commit\s*=\s*)['"][a-f0-9]+['"]""",
            f'\\1"{new_sha}"',
            block,
        )
        new_content = content[:brace_start] + new_block + content[brace_end + 1:]
    else:
        # Add commit field after the slug string
        slug_end = m.end()
        eol = content.find('\n', slug_end)

        if eol == -1:
            eol = len(content)

        line_after_slug = content[slug_end:eol]

        # Determine if this is a single-line spec: { 'owner/repo' } or { 'owner/repo', ... }
        single_line = '}' in line_after_slug

        if single_line:
            # Insert before the closing }
            close = content.rfind('}', slug_end, eol + 1)
            insert_str = f', commit = "{new_sha}"'
            new_content = content[:close] + insert_str + content[close:]
        else:
            # Multi-line spec: insert a new line after the slug line
            line_start = content.rfind('\n', 0, pos) + 1
            slug_line = content[line_start:eol]
            indent = ' ' * (len(slug_line) - len(slug_line.lstrip()))
            new_line = f'\n{indent}commit = "{new_sha}",'
            new_content = content[:eol] + new_line + content[eol:]

    if new_content == content:
        return False

    filepath.write_text(new_content)
    return True


# ── Claude analysis ────────────────────────────────────────────────────────────

def analyze_with_claude(updates: list[PluginUpdate]) -> str:
    """Generate a change analysis for all plugin updates using Claude."""
    client = anthropic.Anthropic(api_key=ANTHROPIC_API_KEY)

    sections = []
    for u in updates:
        lines = [f"### {u.spec.slug}  ({u.tag})"]
        lines.append(f"Commits: {u.spec.current_commit or 'unpinned'} → {u.new_sha}")
        if u.release_notes.strip():
            lines.append(f"Release notes:\n{u.release_notes[:800].strip()}")
        if u.commits:
            lines.append("Recent commits:\n" + "\n".join(u.commits[:15]))
        sections.append("\n".join(lines))

    prompt = (
        f"You are reviewing {len(updates)} Neovim plugin update(s) before they are merged into a dotfiles repository.\n\n"
        "For each plugin below, write a concise 2–3 sentence summary covering:\n"
        "1. What changed (new features, bug fixes, breaking changes)\n"
        "2. Anything worth attention before merging: new runtime dependencies, "
        "changed keybindings, API changes, or unusual commit patterns\n\n"
        "Be direct and skip boilerplate. If there are no notes or commits available, say so briefly.\n\n"
        + "\n\n---\n\n".join(sections)
    )

    msg = client.messages.create(
        model="claude-opus-4-6",
        max_tokens=2048,
        messages=[{"role": "user", "content": prompt}],
    )
    return msg.content[0].text


# ── PR body ────────────────────────────────────────────────────────────────────

def build_pr_body(
    updates: list[PluginUpdate],
    analysis: str,
    unpinnable: list[PluginSpec],
) -> str:
    lines = ["## Neovim Plugin Bumps\n"]

    lines.append("| Plugin | Old | New | Release |")
    lines.append("|--------|-----|-----|---------|")
    for u in updates:
        old = f"`{u.spec.current_commit[:8]}`" if u.spec.current_commit else "*unpinned*"
        gh = f"https://github.com/{u.spec.owner}/{u.spec.repo}"
        compare = (
            f" ([compare]({gh}/compare/{u.spec.current_commit}...{u.new_sha}))"
            if u.spec.current_commit else ""
        )
        tag_link = f"[{u.tag}]({gh}/releases/tag/{u.tag})" if u.tag else "–"
        lines.append(
            f"| [{u.spec.slug}]({gh}) | {old} | `{u.new_sha[:8]}`{compare} | {tag_link} |"
        )

    lines.append("\n## Change Analysis\n")
    lines.append(analysis)

    if unpinnable:
        lines.append("\n<details>")
        lines.append("<summary>Plugins that need manual conversion to full spec before they can be pinned</summary>\n")
        lines.append("These plugins appear as bare strings inside `dependencies = { ... }` arrays.")
        lines.append("Convert them to full spec objects to enable commit pinning:\n")
        lines.append("```lua")
        lines.append("-- Before:")
        lines.append('dependencies = { "owner/repo" }')
        lines.append("-- After:")
        lines.append('dependencies = { { "owner/repo", commit = "sha" } }')
        lines.append("```\n")
        lines.append("Affected plugins:")
        seen: set[str] = set()
        for spec in unpinnable:
            if spec.slug not in seen:
                lines.append(f"- `{spec.slug}`")
                seen.add(spec.slug)
        lines.append("</details>")

    return "\n".join(lines)


# ── Main ───────────────────────────────────────────────────────────────────────

def set_output(key: str, value: str) -> None:
    github_output = os.environ.get("GITHUB_OUTPUT")
    if github_output:
        with open(github_output, "a") as f:
            f.write(f"{key}={value}\n")
    else:
        print(f"[output] {key}={value}")


def main() -> None:
    if not GITHUB_TOKEN:
        print("Error: GITHUB_TOKEN not set", file=sys.stderr)
        sys.exit(1)
    if not ANTHROPIC_API_KEY:
        print("Error: ANTHROPIC_API_KEY not set", file=sys.stderr)
        sys.exit(1)

    print("Parsing plugin specs from Lua files...")
    all_specs = parse_all_plugins(LUA_PLUGIN_FILES)
    print(f"Found {len(all_specs)} plugin spec entries across all files")

    # Deduplicate slugs for GitHub API calls (check once, update all files)
    unique_slugs: dict[str, list[PluginSpec]] = {}
    for spec in all_specs:
        unique_slugs.setdefault(spec.slug, []).append(spec)

    updates: list[PluginUpdate] = []
    unpinnable: list[PluginSpec] = []
    no_release: list[str] = []

    print(f"\nChecking {len(unique_slugs)} unique plugins against GitHub releases...\n")

    for slug, specs in sorted(unique_slugs.items()):
        pinnable_specs = [s for s in specs if s.is_pinnable]

        if not pinnable_specs:
            unpinnable.extend(specs)
            print(f"  {slug:<45} bare dependency string, skipping")
            continue

        # Use the first pinnable spec for current_commit reference
        representative = pinnable_specs[0]
        print(f"  {slug:<45}", end=" ", flush=True)

        new_sha, tag, notes = get_latest_release(representative.owner, representative.repo)

        if not new_sha:
            print("no release found")
            no_release.append(slug)
            continue

        # Collect current commits across all pinnable specs for this slug
        # (they should all be the same, but handle divergence gracefully)
        current_commits = {s.current_commit for s in pinnable_specs if s.current_commit}
        current_commit = current_commits.pop() if len(current_commits) == 1 else (
            pinnable_specs[0].current_commit
        )

        if current_commit and current_commit == new_sha:
            print(f"up to date  ({tag})")
            continue

        commits: list[str] = []
        if current_commit:
            commits = get_commits_between(representative.owner, representative.repo, current_commit, new_sha)

        status = f"{'unpinned' if not current_commit else current_commit[:8]} → {new_sha[:8]}  ({tag})"
        print(status)

        updates.append(PluginUpdate(
            spec=PluginSpec(
                slug=representative.slug,
                owner=representative.owner,
                repo=representative.repo,
                filepath=representative.filepath,
                pos=representative.pos,
                current_commit=current_commit,
                is_pinnable=True,
            ),
            new_sha=new_sha,
            tag=tag,
            release_notes=notes,
            commits=commits,
        ))

    if not updates:
        print("\nAll pinned plugins are up to date.")
        set_output("has_updates", "false")
        return

    print(f"\nAnalyzing {len(updates)} update(s) with Claude...")
    analysis = analyze_with_claude(updates)

    print("\nUpdating Lua files...")
    for u in updates:
        # Update all files that contain this slug as a pinnable spec
        for spec in unique_slugs.get(u.spec.slug, []):
            if not spec.is_pinnable:
                continue
            ok = update_commit_in_file(spec.filepath, u.spec.slug, u.new_sha)
            rel = spec.filepath.relative_to(REPO_ROOT)
            print(f"  {u.spec.slug} in {rel}: {'updated' if ok else 'FAILED'}")

    pr_body = build_pr_body(updates, analysis, unpinnable)
    date = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    pr_title = f"chore: bump neovim plugins ({date})"

    out_dir = REPO_ROOT / ".github"
    out_dir.mkdir(exist_ok=True)
    (out_dir / "pr-body.md").write_text(pr_body)

    set_output("has_updates", "true")
    set_output("pr_title", pr_title)
    print(f"\nDone. {len(updates)} plugin(s) updated. PR body written to .github/pr-body.md")


if __name__ == "__main__":
    main()
