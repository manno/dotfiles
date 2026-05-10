// bump-nvim-plugins.go
//
// Job 1 of the plugin-bump workflow.
// Scans Neovim plugin Lua files for lazy.nvim specs, checks each plugin's
// latest GitHub release, updates commit = "sha" pins in place, and outputs
// a JSON matrix for the per-plugin analyze jobs.
//
// Usage (from repo root):
//
//	GITHUB_TOKEN=... go run scripts/bump-nvim-plugins.go
package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
)

// ── Types ─────────────────────────────────────────────────────────────────────

type pluginSpec struct {
	slug          string
	owner         string
	repo          string
	file          string
	pos           int
	slugEnd       int
	currentCommit string
	branch        string
	pinnable      bool
}

type pluginUpdate struct {
	spec   pluginSpec
	newSHA string
	tag    string
}

// matrixEntry is one element of the JSON array passed to the analyze matrix job.
type matrixEntry struct {
	Slug     string `json:"slug"`
	SlugSafe string `json:"slug_safe"` // "/" replaced with "-", safe for artifact names
	Owner    string `json:"owner"`
	Repo     string `json:"repo"`
	OldSHA   string `json:"old_sha"` // empty string when previously unpinned
	NewSHA   string `json:"new_sha"`
	Tag      string `json:"tag"`
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
	tagData, err := ghGet(fmt.Sprintf("/repos/%s/%s/git/tags/%s", owner, repo, ref.Object.SHA))
	if err != nil || tagData == nil {
		return "", err
	}
	var tagObj struct {
		Object struct{ SHA string `json:"sha"` } `json:"object"`
	}
	json.Unmarshal(tagData, &tagObj)
	return tagObj.Object.SHA, nil
}

// getLatestRelease returns (commitSHA, tagName, error).
// Tries GitHub Releases first; falls back to the most recent tag.
func getLatestRelease(owner, repo string) (string, string, error) {
	data, err := ghGet(fmt.Sprintf("/repos/%s/%s/releases/latest", owner, repo))
	if err != nil {
		return "", "", err
	}
	if data != nil {
		var rel struct {
			TagName    string `json:"tag_name"`
			PreRelease bool   `json:"prerelease"`
		}
		if json.Unmarshal(data, &rel) == nil && !rel.PreRelease && rel.TagName != "" {
			sha, err := resolveTagSHA(owner, repo, rel.TagName)
			return sha, rel.TagName, err
		}
	}
	tagsData, err := ghGet(fmt.Sprintf("/repos/%s/%s/tags?per_page=1", owner, repo))
	if err != nil || tagsData == nil {
		return "", "", err
	}
	var tags []struct {
		Name string `json:"name"`
	}
	if json.Unmarshal(tagsData, &tags) != nil || len(tags) == 0 {
		return "", "", nil
	}
	sha, err := resolveTagSHA(owner, repo, tags[0].Name)
	return sha, tags[0].Name, err
}

// getBranchHead returns the HEAD commit SHA of a branch.
func getBranchHead(owner, repo, branch string) (string, error) {
	data, err := ghGet(fmt.Sprintf("/repos/%s/%s/branches/%s", owner, repo, branch))
	if err != nil || data == nil {
		return "", err
	}
	var b struct {
		Commit struct {
			SHA string `json:"sha"`
		} `json:"commit"`
	}
	if err := json.Unmarshal(data, &b); err != nil {
		return "", err
	}
	return b.Commit.SHA, nil
}

// ── Lua parsing ───────────────────────────────────────────────────────────────

var (
	slugRE         = regexp.MustCompile(`['"]([A-Za-z0-9][A-Za-z0-9_.\-]*/[A-Za-z0-9][A-Za-z0-9_.\-]*)['"]`)
	nonPluginKeyRE = regexp.MustCompile(`\b(import|cmd|event|ft|cond|dir|section|pattern|adapter)\s*=\s*$`)
	commitRE       = regexp.MustCompile(`commit\s*=\s*['"]([a-f0-9]{7,40})['"]`)
	branchRE       = regexp.MustCompile(`branch\s*=\s*['"]([^'"]+)['"]`)
)

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
		default:
			return -1, -1
		}
	}
scan:
	if start == -1 {
		return -1, -1
	}
	depth := 0
	for i := start; i < len(content); i++ {
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

func isPinnableSpec(content string, pos, braceStart int) bool {
	if braceStart == -1 {
		return false
	}
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
	if len(before) >= 2 {
		prev := before[len(before)-2]
		if prev == '=' || prev == '!' || prev == '<' || prev == '>' || prev == '~' {
			return true
		}
	}
	return false
}

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
	type key struct{ file, slug string }
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
			slug := content[loc[2]:loc[3]]
			pos := loc[0]

			// Skip if we've already found a pinnable spec for this slug in this
			// file. Unpinnable occurrences (e.g. bare dep strings) don't set the
			// seen flag, so a later full-spec occurrence can still be recorded.
			if seen[key{file, slug}] {
				continue
			}

			before := strings.TrimRight(content[max(0, pos-30):pos], " \t")
			if nonPluginKeyRE.MatchString(before) {
				continue
			}

			lineStart := strings.LastIndex(content[:pos], "\n") + 1
			if strings.HasPrefix(strings.TrimLeft(content[lineStart:pos], " \t"), "--") {
				continue
			}

			braceStart, braceEnd := findEnclosingBrace(content, pos)
			pinnable := isPinnableSpec(content, pos, braceStart)
			if pinnable {
				seen[key{file, slug}] = true
			}

			currentCommit := ""
			branch := ""
			if braceStart != -1 && braceEnd != -1 {
				block := content[braceStart : braceEnd+1]
				if m := commitRE.FindStringSubmatch(block); m != nil {
					currentCommit = m[1]
				}
				if m := branchRE.FindStringSubmatch(block); m != nil {
					branch = m[1]
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
				branch:        branch,
				pinnable:      pinnable,
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

	pos, slugEnd := -1, -1
	var braceStart, braceEnd int
	for _, loc := range slugRE.FindAllStringSubmatchIndex(content, -1) {
		if content[loc[2]:loc[3]] != slug {
			continue
		}
		bs, be := findEnclosingBrace(content, loc[0])
		if isPinnableSpec(content, loc[0], bs) {
			pos, slugEnd = loc[0], loc[1]
			braceStart, braceEnd = bs, be
			break
		}
	}
	if pos == -1 {
		return false
	}
	if braceStart == -1 || braceEnd == -1 {
		fmt.Fprintf(os.Stderr, "  warning: cannot find table bounds for %s in %s\n", slug, file)
		return false
	}
	block := content[braceStart : braceEnd+1]

	var newContent string
	if commitRE.MatchString(block) {
		newBlock := commitRE.ReplaceAllString(block, fmt.Sprintf(`commit = "%s"`, newSHA))
		newContent = content[:braceStart] + newBlock + content[braceEnd+1:]
	} else {
		eol := strings.IndexByte(content[slugEnd:], '\n')
		if eol == -1 {
			eol = len(content) - slugEnd
		}
		lineAfterSlug := content[slugEnd : slugEnd+eol]

		if strings.Contains(lineAfterSlug, "}") {
			closePos := strings.LastIndex(content[:slugEnd+eol+1], "}")
			newContent = content[:closePos] + fmt.Sprintf(`, commit = "%s"`, newSHA) + content[closePos:]
		} else {
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

// ── Helpers ───────────────────────────────────────────────────────────────────

func max(a, b int) int {
	if a > b {
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

func slugSafe(slug string) string {
	return strings.ReplaceAll(slug, "/", "-")
}

// ── Main ──────────────────────────────────────────────────────────────────────

func main() {
	if os.Getenv("GITHUB_TOKEN") == "" {
		fmt.Fprintln(os.Stderr, "error: GITHUB_TOKEN not set")
		os.Exit(1)
	}

	luaFiles, err := discoverPluginFiles()
	if err != nil || len(luaFiles) == 0 {
		fmt.Fprintln(os.Stderr, "error: no plugin Lua files found under dot_config/nvim/lua/")
		os.Exit(1)
	}
	fmt.Printf("Plugin files: %s\n\n", strings.Join(luaFiles, ", "))

	allSpecs := parsePlugins(luaFiles)

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
	var unpinnableSlugs []string

	for _, slug := range slugs {
		specs := bySlug[slug]

		var pinnable []pluginSpec
		for _, s := range specs {
			if s.pinnable {
				pinnable = append(pinnable, s)
			}
		}
		if len(pinnable) == 0 {
			fmt.Printf("  %-46s bare dependency string\n", slug)
			unpinnableSlugs = append(unpinnableSlugs, slug)
			continue
		}

		fmt.Printf("  %-46s", slug)
		rep := pinnable[0]

		var newSHA, tag string
		if rep.branch != "" {
			newSHA, err = getBranchHead(rep.owner, rep.repo, rep.branch)
			tag = "branch:" + rep.branch
		} else {
			newSHA, tag, err = getLatestRelease(rep.owner, rep.repo)
			if err == nil && newSHA == "" {
				newSHA, err = getBranchHead(rep.owner, rep.repo, "main")
				tag = "branch:main"
			}
		}
		if err != nil {
			fmt.Fprintf(os.Stderr, "error: %v\n", err)
			continue
		}
		if newSHA == "" {
			fmt.Println("no release found")
			continue
		}

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
				branch:        rep.branch,
			},
			newSHA: newSHA,
			tag:    tag,
		})
	}

	if len(updates) == 0 {
		fmt.Println("\nAll pinned plugins are up to date.")
		setOutput("has_updates", "false")
		return
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

	// Build matrix JSON for the analyze jobs.
	matrix := make([]matrixEntry, 0, len(updates))
	for _, u := range updates {
		matrix = append(matrix, matrixEntry{
			Slug:     u.spec.slug,
			SlugSafe: slugSafe(u.spec.slug),
			Owner:    u.spec.owner,
			Repo:     u.spec.repo,
			OldSHA:   u.spec.currentCommit,
			NewSHA:   u.newSHA,
			Tag:      u.tag,
		})
	}
	matrixJSON, _ := json.Marshal(matrix)

	// Write matrix.json and unpinnable.json for the pr job artifact.
	os.MkdirAll(".github/bump", 0755)
	os.WriteFile(".github/bump/matrix.json", matrixJSON, 0644)

	unpinnableJSON, _ := json.Marshal(unpinnableSlugs)
	os.WriteFile(".github/bump/unpinnable.json", unpinnableJSON, 0644)

	setOutput("has_updates", "true")
	setOutput("matrix", string(matrixJSON))
	fmt.Printf("\nDone. %d plugin(s) to update.\n", len(updates))
}
