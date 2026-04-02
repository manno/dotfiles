// bump-nvim-plugins.go
//
// Scans Neovim plugin Lua files for lazy.nvim specs, checks each plugin's
// latest GitHub release, and updates commit = "sha" pins. Calls the Claude
// API for a security-focused review and writes .github/pr-body.md.
//
// Usage (from repo root):
//
//	GITHUB_TOKEN=... ANTHROPIC_API_KEY=... go run scripts/bump-nvim-plugins.go
package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
	"time"
)

// ── Types ─────────────────────────────────────────────────────────────────────

type pluginSpec struct {
	slug          string
	owner         string
	repo          string
	file          string
	pos           int // position of opening quote of slug in file
	slugEnd       int // position after closing quote
	currentCommit string
	pinnable      bool
}

type pluginUpdate struct {
	spec         pluginSpec
	newSHA       string
	tag          string
	releaseNotes string
	commits      []string
}

// ── GitHub API ────────────────────────────────────────────────────────────────

func ghGet(path string) (json.RawMessage, error) {
	req, err := http.NewRequest("GET", "https://api.github.com"+path, nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Authorization", "Bearer "+os.Getenv("GITHUB_TOKEN"))
	req.Header.Set("Accept", "application/vnd.github+json")
	req.Header.Set("X-GitHub-Api-Version", "2022-11-28")
	req.Header.Set("User-Agent", "bump-nvim-plugins/1.0")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	body, _ := io.ReadAll(resp.Body)
	if resp.StatusCode == 404 || resp.StatusCode == 451 {
		return nil, nil
	}
	if resp.StatusCode >= 400 {
		preview := body
		if len(preview) > 120 {
			preview = preview[:120]
		}
		return nil, fmt.Errorf("GitHub API %d for %s: %s", resp.StatusCode, path, preview)
	}
	return body, nil
}

func resolveTagSHA(owner, repo, tag string) (string, error) {
	data, err := ghGet(fmt.Sprintf("/repos/%s/%s/git/ref/tags/%s", owner, repo, tag))
	if err != nil || data == nil {
		return "", err
	}
	var ref struct {
		Object struct {
			Type string `json:"type"`
			SHA  string `json:"sha"`
		} `json:"object"`
	}
	if err := json.Unmarshal(data, &ref); err != nil {
		return "", err
	}
	if ref.Object.Type != "tag" {
		return ref.Object.SHA, nil
	}
	// Annotated tag — dereference to the commit it points to.
	tagData, err := ghGet(fmt.Sprintf("/repos/%s/%s/git/tags/%s", owner, repo, ref.Object.SHA))
	if err != nil || tagData == nil {
		return "", err
	}
	var tagObj struct {
		Object struct {
			SHA string `json:"sha"`
		} `json:"object"`
	}
	json.Unmarshal(tagData, &tagObj)
	return tagObj.Object.SHA, nil
}

// getLatestRelease returns (commitSHA, tagName, releaseNotes).
// Tries GitHub Releases first; falls back to the most recent tag.
func getLatestRelease(owner, repo string) (string, string, string, error) {
	data, err := ghGet(fmt.Sprintf("/repos/%s/%s/releases/latest", owner, repo))
	if err != nil {
		return "", "", "", err
	}
	if data != nil {
		var rel struct {
			TagName    string `json:"tag_name"`
			Body       string `json:"body"`
			PreRelease bool   `json:"prerelease"`
		}
		if json.Unmarshal(data, &rel) == nil && !rel.PreRelease && rel.TagName != "" {
			sha, err := resolveTagSHA(owner, repo, rel.TagName)
			return sha, rel.TagName, rel.Body, err
		}
	}
	// Fall back to most recent tag.
	tagsData, err := ghGet(fmt.Sprintf("/repos/%s/%s/tags?per_page=1", owner, repo))
	if err != nil || tagsData == nil {
		return "", "", "", err
	}
	var tags []struct {
		Name string `json:"name"`
	}
	if json.Unmarshal(tagsData, &tags) != nil || len(tags) == 0 {
		return "", "", "", nil
	}
	sha, err := resolveTagSHA(owner, repo, tags[0].Name)
	return sha, tags[0].Name, "", err
}

func getCommitsBetween(owner, repo, oldSHA, newSHA string) []string {
	data, _ := ghGet(fmt.Sprintf("/repos/%s/%s/compare/%s...%s", owner, repo, oldSHA, newSHA))
	if data == nil {
		return nil
	}
	var cmp struct {
		Commits []struct {
			SHA    string `json:"sha"`
			Commit struct{ Message string `json:"message"` } `json:"commit"`
		} `json:"commits"`
	}
	if json.Unmarshal(data, &cmp) != nil {
		return nil
	}
	lines := make([]string, 0, len(cmp.Commits))
	for i, c := range cmp.Commits {
		if i >= 30 {
			break
		}
		msg := c.Commit.Message
		if nl := strings.IndexByte(msg, '\n'); nl != -1 {
			msg = msg[:nl]
		}
		lines = append(lines, fmt.Sprintf("- %s %s", c.SHA[:8], msg))
	}
	return lines
}

// ── Lua parsing ───────────────────────────────────────────────────────────────

var (
	// Matches 'owner/repo' or "owner/repo"; capture group 1 is the slug.
	slugRE = regexp.MustCompile(`['"]([A-Za-z0-9][A-Za-z0-9_.\-]*/[A-Za-z0-9][A-Za-z0-9_.\-]*)['"]`)

	// Keys whose string values are not plugin slugs.
	nonPluginKeyRE = regexp.MustCompile(`\b(import|cmd|event|ft|cond|dir|section|pattern|adapter)\s*=\s*$`)

	// Existing commit pin inside a plugin spec.
	commitRE = regexp.MustCompile(`commit\s*=\s*['"]([a-f0-9]{7,40})['"]`)
)

// findEnclosingBrace returns the (start, end) indices of the { ... } table
// that immediately encloses the position pos.
func findEnclosingBrace(content string, pos int) (int, int) {
	start := -1
	lo := pos - 300
	if lo < 0 {
		lo = 0
	}
	for i := pos - 1; i >= lo; i-- {
		switch content[i] {
		case '{':
			start = i
			goto scan
		case ' ', '\t', '\n', ',':
			// keep scanning
		default:
			return -1, -1
		}
	}
scan:
	if start == -1 {
		return -1, -1
	}
	depth := 0
	hi := start + 8000
	if hi > len(content) {
		hi = len(content)
	}
	for i := start; i < hi; i++ {
		switch content[i] {
		case '{':
			depth++
		case '}':
			depth--
			if depth == 0 {
				return start, i
			}
		}
	}
	return start, -1
}

// isPinnableSpec returns true when the slug is the first element of a
// standalone table spec (not a value in an assignment like dependencies = { }).
func isPinnableSpec(content string, pos, braceStart int) bool {
	if braceStart == -1 {
		return false
	}
	// Only whitespace between { and slug.
	for _, ch := range content[braceStart+1 : pos] {
		if ch != ' ' && ch != '\t' && ch != '\n' {
			return false
		}
	}
	before := strings.TrimRight(content[:braceStart], " \t\n")
	if before == "" {
		return true
	}
	last := before[len(before)-1]
	if last != '=' {
		return true
	}
	// Distinguish assignment `=` from `==`, `>=`, `<=`, `~=`.
	if len(before) >= 2 {
		prev := before[len(before)-2]
		if prev == '=' || prev == '!' || prev == '<' || prev == '>' || prev == '~' {
			return true
		}
	}
	return false // `key = {` — assignment value
}

// discoverPluginFiles returns plugins.lua plus every *.lua under plugins/.
func discoverPluginFiles() ([]string, error) {
	var files []string
	main := filepath.Join("dot_config", "nvim", "lua", "plugins.lua")
	if _, err := os.Stat(main); err == nil {
		files = append(files, main)
	}
	glob, err := filepath.Glob(filepath.Join("dot_config", "nvim", "lua", "plugins", "*.lua"))
	if err != nil {
		return nil, err
	}
	sort.Strings(glob)
	return append(files, glob...), nil
}

func parsePlugins(luaFiles []string) []pluginSpec {
	type key struct {
		file, slug string
	}
	seen := map[key]bool{}
	var specs []pluginSpec

	for _, file := range luaFiles {
		raw, err := os.ReadFile(file)
		if err != nil {
			fmt.Fprintf(os.Stderr, "warning: cannot read %s: %v\n", file, err)
			continue
		}
		content := string(raw)

		for _, loc := range slugRE.FindAllStringSubmatchIndex(content, -1) {
			// loc[0]:loc[1] = full match, loc[2]:loc[3] = capture group (slug)
			slug := content[loc[2]:loc[3]]
			pos := loc[0]

			if seen[key{file, slug}] {
				continue
			}
			seen[key{file, slug}] = true

			// Skip values of known non-plugin keys.
			before := strings.TrimRight(content[max(0, pos-30):pos], " \t")
			if nonPluginKeyRE.MatchString(before) {
				continue
			}

			// Skip commented-out lines.
			lineStart := strings.LastIndex(content[:pos], "\n") + 1
			if strings.HasPrefix(strings.TrimLeft(content[lineStart:pos], " \t"), "--") {
				continue
			}

			braceStart, braceEnd := findEnclosingBrace(content, pos)
			currentCommit := ""
			if braceStart != -1 && braceEnd != -1 {
				if m := commitRE.FindStringSubmatch(content[braceStart : braceEnd+1]); m != nil {
					currentCommit = m[1]
				}
			}

			owner, repo, _ := strings.Cut(slug, "/")
			specs = append(specs, pluginSpec{
				slug:          slug,
				owner:         owner,
				repo:          repo,
				file:          file,
				pos:           pos,
				slugEnd:       loc[1],
				currentCommit: currentCommit,
				pinnable:      isPinnableSpec(content, pos, braceStart),
			})
		}
	}
	return specs
}

// ── File modification ─────────────────────────────────────────────────────────

func updateCommitInFile(file, slug, newSHA string) bool {
	raw, err := os.ReadFile(file)
	if err != nil {
		return false
	}
	content := string(raw)

	// Locate slug in this file.
	pos, slugEnd := -1, -1
	for _, loc := range slugRE.FindAllStringSubmatchIndex(content, -1) {
		if content[loc[2]:loc[3]] == slug {
			pos, slugEnd = loc[0], loc[1]
			break
		}
	}
	if pos == -1 {
		return false
	}

	braceStart, braceEnd := findEnclosingBrace(content, pos)
	if braceStart == -1 || braceEnd == -1 {
		fmt.Fprintf(os.Stderr, "  warning: cannot find table bounds for %s in %s\n", slug, file)
		return false
	}
	block := content[braceStart : braceEnd+1]

	var newContent string
	if commitRE.MatchString(block) {
		// Replace existing commit SHA.
		newBlock := commitRE.ReplaceAllString(block, fmt.Sprintf(`commit = "%s"`, newSHA))
		newContent = content[:braceStart] + newBlock + content[braceEnd+1:]
	} else {
		// Add commit field.
		eol := strings.IndexByte(content[slugEnd:], '\n')
		if eol == -1 {
			eol = len(content) - slugEnd
		}
		lineAfterSlug := content[slugEnd : slugEnd+eol]

		if strings.Contains(lineAfterSlug, "}") {
			// Single-line spec: { 'owner/repo' } or { 'owner/repo', ft = 'x' }
			// Insert before the closing }.
			closePos := strings.LastIndex(content[:slugEnd+eol+1], "}")
			newContent = content[:closePos] + fmt.Sprintf(`, commit = "%s"`, newSHA) + content[closePos:]
		} else {
			// Multi-line spec: add a new line after the slug's line.
			lineStart := strings.LastIndex(content[:pos], "\n") + 1
			slugLine := content[lineStart : slugEnd+eol]
			indent := len(slugLine) - len(strings.TrimLeft(slugLine, " \t"))
			newLine := "\n" + strings.Repeat(" ", indent) + fmt.Sprintf(`commit = "%s",`, newSHA)
			insertAt := slugEnd + eol
			newContent = content[:insertAt] + newLine + content[insertAt:]
		}
	}

	if newContent == content {
		return false
	}
	return os.WriteFile(file, []byte(newContent), 0644) == nil
}

// ── Claude API ────────────────────────────────────────────────────────────────

func callClaude(prompt string) (string, error) {
	type msg struct {
		Role    string `json:"role"`
		Content string `json:"content"`
	}
	payload, _ := json.Marshal(struct {
		Model     string `json:"model"`
		MaxTokens int    `json:"max_tokens"`
		Messages  []msg  `json:"messages"`
	}{
		Model:     "claude-opus-4-6",
		MaxTokens: 2048,
		Messages:  []msg{{Role: "user", Content: prompt}},
	})

	req, err := http.NewRequest("POST", "https://api.anthropic.com/v1/messages", bytes.NewReader(payload))
	if err != nil {
		return "", err
	}
	req.Header.Set("x-api-key", os.Getenv("ANTHROPIC_API_KEY"))
	req.Header.Set("anthropic-version", "2023-06-01")
	req.Header.Set("Content-Type", "application/json")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()
	body, _ := io.ReadAll(resp.Body)
	if resp.StatusCode != 200 {
		return "", fmt.Errorf("Anthropic API %d: %s", resp.StatusCode, body[:min(len(body), 200)])
	}
	var result struct {
		Content []struct {
			Text string `json:"text"`
		} `json:"content"`
	}
	if err := json.Unmarshal(body, &result); err != nil || len(result.Content) == 0 {
		return "", fmt.Errorf("unexpected Claude response: %s", body[:min(len(body), 200)])
	}
	return result.Content[0].Text, nil
}

func buildSecurityPrompt(updates []pluginUpdate) string {
	var b strings.Builder
	fmt.Fprintf(&b, "You are auditing %d Neovim plugin update(s) before they are merged into a personal dotfiles repository. These plugins run inside Neovim with full access to the filesystem and shell.\n\n", len(updates))
	b.WriteString("For each plugin, review the commit log and release notes with a security lens. Flag:\n")
	b.WriteString("- New shell commands, system calls, or process execution (vim.fn.system, io.popen, os.execute)\n")
	b.WriteString("- New or changed network requests, remote endpoints, or data exfiltration paths\n")
	b.WriteString("- File writes outside ~/.config or ~/.local\n")
	b.WriteString("- New handling of credentials, tokens, environment variables, or secrets\n")
	b.WriteString("- Obfuscated code, unusual encoding, or base64/hex blobs\n")
	b.WriteString("- New transitive dependencies pulled in by the plugin\n")
	b.WriteString("- Surprising behavioral changes inconsistent with the plugin's stated purpose\n\n")
	b.WriteString("Format for each plugin:\n")
	b.WriteString("**<slug>** — <one sentence: what changed functionally>  \n")
	b.WriteString("Verdict: CLEAN | REVIEW | SUSPICIOUS — <one sentence justification>\n\n")
	b.WriteString("---\n\n")

	for _, u := range updates {
		old := u.spec.currentCommit
		if old == "" {
			old = "unpinned"
		}
		fmt.Fprintf(&b, "### %s  (%s)\n", u.spec.slug, u.tag)
		fmt.Fprintf(&b, "Commits: %s → %s\n", old, u.newSHA)
		if notes := strings.TrimSpace(u.releaseNotes); notes != "" {
			if len(notes) > 800 {
				notes = notes[:800]
			}
			fmt.Fprintf(&b, "Release notes:\n%s\n", notes)
		}
		if len(u.commits) > 0 {
			fmt.Fprintf(&b, "Commits:\n%s\n", strings.Join(u.commits, "\n"))
		}
		b.WriteString("\n")
	}
	return b.String()
}

// ── PR body ───────────────────────────────────────────────────────────────────

func buildPRBody(updates []pluginUpdate, analysis string, unpinnable []pluginSpec) string {
	var b strings.Builder
	b.WriteString("## Neovim Plugin Bumps\n\n")
	b.WriteString("| Plugin | Old | New | Release |\n")
	b.WriteString("|--------|-----|-----|--------|\n")
	for _, u := range updates {
		old := "*unpinned*"
		if u.spec.currentCommit != "" {
			old = fmt.Sprintf("`%s`", u.spec.currentCommit[:8])
		}
		gh := fmt.Sprintf("https://github.com/%s/%s", u.spec.owner, u.spec.repo)
		compare := ""
		if u.spec.currentCommit != "" {
			compare = fmt.Sprintf(" ([compare](%s/compare/%s...%s))", gh, u.spec.currentCommit, u.newSHA)
		}
		tagLink := "–"
		if u.tag != "" {
			tagLink = fmt.Sprintf("[%s](%s/releases/tag/%s)", u.tag, gh, u.tag)
		}
		fmt.Fprintf(&b, "| [%s](%s) | %s | `%s`%s | %s |\n",
			u.spec.slug, gh, old, u.newSHA[:8], compare, tagLink)
	}

	b.WriteString("\n## Security Analysis\n\n")
	b.WriteString(analysis)

	// Collect unique unpinnable slugs (only those not also pinnable elsewhere).
	seen := map[string]bool{}
	var uniqueUnpinnable []string
	for _, s := range unpinnable {
		if !seen[s.slug] {
			seen[s.slug] = true
			uniqueUnpinnable = append(uniqueUnpinnable, s.slug)
		}
	}
	if len(uniqueUnpinnable) > 0 {
		sort.Strings(uniqueUnpinnable)
		b.WriteString("\n\n<details>\n<summary>Plugins needing manual conversion before they can be pinned</summary>\n\n")
		b.WriteString("These appear as bare strings in `dependencies = { ... }` arrays.\n")
		b.WriteString("Convert them to full spec objects to enable commit pinning:\n\n")
		b.WriteString("```lua\n-- Before:\ndependencies = { \"owner/repo\" }\n-- After:\ndependencies = { { \"owner/repo\", commit = \"sha\" } }\n```\n\n")
		for _, s := range uniqueUnpinnable {
			fmt.Fprintf(&b, "- `%s`\n", s)
		}
		b.WriteString("</details>")
	}
	return b.String()
}

// ── Helpers ───────────────────────────────────────────────────────────────────

func max(a, b int) int {
	if a > b {
		return a
	}
	return b
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}

func setOutput(key, value string) {
	if f := os.Getenv("GITHUB_OUTPUT"); f != "" {
		fh, err := os.OpenFile(f, os.O_APPEND|os.O_WRONLY, 0644)
		if err == nil {
			fmt.Fprintf(fh, "%s=%s\n", key, value)
			fh.Close()
		}
	} else {
		fmt.Printf("[output] %s=%s\n", key, value)
	}
}

// ── Main ──────────────────────────────────────────────────────────────────────

func main() {
	if os.Getenv("GITHUB_TOKEN") == "" {
		fmt.Fprintln(os.Stderr, "error: GITHUB_TOKEN not set")
		os.Exit(1)
	}
	if os.Getenv("ANTHROPIC_API_KEY") == "" {
		fmt.Fprintln(os.Stderr, "error: ANTHROPIC_API_KEY not set")
		os.Exit(1)
	}

	luaFiles, err := discoverPluginFiles()
	if err != nil || len(luaFiles) == 0 {
		fmt.Fprintln(os.Stderr, "error: no plugin Lua files found under dot_config/nvim/lua/")
		os.Exit(1)
	}
	fmt.Printf("Plugin files: %s\n\n", strings.Join(luaFiles, ", "))

	allSpecs := parsePlugins(luaFiles)

	// Group by slug; each slug may appear across multiple files.
	bySlug := map[string][]pluginSpec{}
	for _, s := range allSpecs {
		bySlug[s.slug] = append(bySlug[s.slug], s)
	}
	slugs := make([]string, 0, len(bySlug))
	for s := range bySlug {
		slugs = append(slugs, s)
	}
	sort.Strings(slugs)

	fmt.Printf("Checking %d unique plugins against GitHub releases...\n\n", len(slugs))

	var updates []pluginUpdate
	var unpinnable []pluginSpec

	for _, slug := range slugs {
		specs := bySlug[slug]

		var pinnable []pluginSpec
		for _, s := range specs {
			if s.pinnable {
				pinnable = append(pinnable, s)
			} else {
				unpinnable = append(unpinnable, s)
			}
		}
		if len(pinnable) == 0 {
			fmt.Printf("  %-46s bare dependency string\n", slug)
			continue
		}

		fmt.Printf("  %-46s", slug)
		rep := pinnable[0]

		newSHA, tag, notes, err := getLatestRelease(rep.owner, rep.repo)
		if err != nil {
			fmt.Fprintf(os.Stderr, "error: %v\n", err)
			continue
		}
		if newSHA == "" {
			fmt.Println("no release found")
			continue
		}

		// Use first non-empty current commit across all pinnable specs.
		currentCommit := ""
		for _, s := range pinnable {
			if s.currentCommit != "" {
				currentCommit = s.currentCommit
				break
			}
		}

		if currentCommit == newSHA {
			fmt.Printf("up to date  (%s)\n", tag)
			continue
		}

		var commits []string
		if currentCommit != "" {
			commits = getCommitsBetween(rep.owner, rep.repo, currentCommit, newSHA)
		}

		oldDisplay := "unpinned"
		if currentCommit != "" {
			oldDisplay = currentCommit[:8]
		}
		fmt.Printf("%s → %s  (%s)\n", oldDisplay, newSHA[:8], tag)

		updates = append(updates, pluginUpdate{
			spec: pluginSpec{
				slug:          slug,
				owner:         rep.owner,
				repo:          rep.repo,
				currentCommit: currentCommit,
			},
			newSHA:       newSHA,
			tag:          tag,
			releaseNotes: notes,
			commits:      commits,
		})
	}

	if len(updates) == 0 {
		fmt.Println("\nAll pinned plugins are up to date.")
		setOutput("has_updates", "false")
		return
	}

	fmt.Printf("\nCalling Claude for security analysis of %d update(s)...\n", len(updates))
	analysis, err := callClaude(buildSecurityPrompt(updates))
	if err != nil {
		fmt.Fprintf(os.Stderr, "Claude API error: %v\n", err)
		os.Exit(1)
	}

	fmt.Println("\nUpdating Lua files...")
	for _, u := range updates {
		for _, spec := range bySlug[u.spec.slug] {
			if !spec.pinnable {
				continue
			}
			ok := updateCommitInFile(spec.file, u.spec.slug, u.newSHA)
			status := "updated"
			if !ok {
				status = "FAILED"
			}
			fmt.Printf("  %s in %s: %s\n", u.spec.slug, spec.file, status)
		}
	}

	prBody := buildPRBody(updates, analysis, unpinnable)
	prTitle := fmt.Sprintf("chore: bump neovim plugins (%s)", time.Now().UTC().Format("2006-01-02"))

	if err := os.MkdirAll(".github", 0755); err == nil {
		os.WriteFile(".github/pr-body.md", []byte(prBody), 0644)
	}

	setOutput("has_updates", "true")
	setOutput("pr_title", prTitle)
	fmt.Printf("\nDone. %d plugin(s) updated. PR body written to .github/pr-body.md\n", len(updates))
}
