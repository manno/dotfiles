# GitHub Agentic Workflows: Complete Guide for AI Agents

**Version**: 1.0
**Last Updated**: 2026-05-06
**For**: AI agents helping users create GitHub Agentic Workflows

This document provides complete information about GitHub Agentic Workflows, enabling AI agents to help users write effective automation workflows.

---

## Table of Contents

1. [Overview](#overview)
2. [File Structure](#file-structure)
3. [Frontmatter Configuration](#frontmatter-configuration)
4. [Writing Agent Instructions](#writing-agent-instructions)
5. [Tools and Capabilities](#tools-and-capabilities)
6. [Security Model](#security-model)
7. [Common Patterns](#common-patterns)
8. [Best Practices](#best-practices)
9. [Complete Examples](#complete-examples)
10. [Compilation and Deployment](#compilation-and-deployment)
11. [Troubleshooting](#troubleshooting)

---

## Overview

### What Are GitHub Agentic Workflows?

GitHub Agentic Workflows allow you to write repository automation in **plain Markdown** instead of complex YAML. AI agents (GitHub Copilot, Claude Code, OpenAI) execute the workflows with natural language instructions.

### Key Characteristics

- **Language**: Markdown with YAML frontmatter
- **Execution**: AI agents interpret instructions and execute actions
- **Security**: 5-layer security model (read-only tokens, safe outputs, threat detection, network firewall, human review)
- **Output**: Auto-generates `.lock.yml` file (never edit directly)
- **Location**: `.github/workflows/*.md`
- **Compilation**: Use `gh aw compile` command

### When to Use

✅ **Use Agentic Workflows for:**
- Complex decision-making logic
- User input parsing and validation
- Multiple API calls and data transformations
- Conditional workflows based on context
- Generating formatted output
- Any workflow requiring > 50 lines of traditional YAML

❌ **Don't Use for:**
- Simple tasks (< 10 lines of YAML)
- Pure build/deploy pipelines (use traditional Actions)
- When AI interpretation overhead is unacceptable

---

## File Structure

### Directory Layout

```
.github/workflows/
├── cve-response.md              # Markdown source (you write this)
├── cve-response.lock.yml        # Auto-generated YAML (DON'T EDIT)
├── daily-health-check.md        # Another workflow
└── daily-health-check.lock.yml  # Auto-generated
```

### File Naming Convention

- **Source**: `{workflow-name}.md`
- **Generated**: `{workflow-name}.lock.yml`
- **Pattern**: Use kebab-case for multi-word names
- **Examples**: `cve-auto-fix.md`, `port-issue.md`, `daily-repo-status.md`

---

## Frontmatter Configuration

Every agentic workflow starts with YAML frontmatter enclosed in `---`.

### Complete Frontmatter Template

```yaml
---
description: |
  Brief description of what this workflow does.
  Can be multi-line for detailed explanations.

on:
  # TRIGGER OPTIONS (choose one or more):

  # Slash command trigger
  slash_command:
    name: command-name      # e.g., "fix-cve", "backport"
    events: [issue_comment] # or [pull_request_comment]

  # Reaction acknowledgment
  reaction: "eyes"          # Options: "eyes" 👀, "rocket" 🚀, "+1" 👍, "heart" ❤️

  # Scheduled trigger
  schedule:
    - cron: '0 6 * * *'    # Standard cron syntax

  # Manual trigger
  workflow_dispatch:
    inputs:
      custom_input:
        description: 'Input description'
        required: false
        default: 'default-value'

  # Repository dispatch (external trigger)
  repository_dispatch:
    types: [custom-event-type]

  # Standard GitHub events
  issues:
    types: [opened, labeled]
  pull_request:
    types: [opened, synchronize]

# PERMISSIONS (choose appropriate level)
permissions: read-all       # Default: read-only (RECOMMENDED)
# OR granular permissions:
# permissions:
#   contents: write
#   issues: write
#   pull-requests: write
#   discussions: write

# NETWORK ACCESS
network: defaults           # Allow GitHub API + common domains
# OR
# network: none            # No network access
# OR
# network:
#   allow: [github.com, api.github.com, specific-domain.com]

# SAFE OUTPUTS (what the agent can do)
safe-outputs:
  create-pull-request:
    max-operations: 1       # Limit PRs per run
    expiration-hours: 168   # 7 days

  add-comment:
    max-operations: 5       # Limit comments

  create-issue:
    max-operations: 3
    expiration-hours: 168

  create-discussion:
    max-operations: 5
    category: "q-a"         # Default category
    expiration-hours: 168

  update-issue:
    max-operations: 10

  close-issue:
    max-operations: 5

# TOOLS CONFIGURATION
tools:
  bash: true                # Enable bash commands
  playwright: false         # Browser automation (for UI testing)
  web-fetch: false          # Fetch external URLs

  github:
    toolsets: [issues, pull-requests, discussions, code-scanning, actions]
    lockdown: false         # If true, restricts to essential APIs only

# EXECUTION LIMITS
timeout-minutes: 15         # Max runtime (default: 15, max: 60)
---
```

### Frontmatter Field Reference

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `description` | Yes | string | Brief explanation of workflow purpose |
| `on` | Yes | object | Trigger configuration |
| `permissions` | No | string/object | Default: `read-all` |
| `network` | No | string/object | Default: `defaults` |
| `safe-outputs` | No | object | Actions the agent can perform |
| `tools` | No | object | Available tools and APIs |
| `timeout-minutes` | No | number | Max execution time (default: 15) |

### Common Trigger Patterns

#### Pattern 1: Slash Command on Issues
```yaml
on:
  slash_command:
    name: fix-cve
    events: [issue_comment]
  reaction: "eyes"
```

**Usage**: User comments `/fix-cve CVE-2026-12345` on an issue

#### Pattern 2: Scheduled Daily
```yaml
on:
  schedule:
    - cron: '0 6 * * 1'  # Every Monday at 6 AM UTC
```

#### Pattern 3: New Issue with Label
```yaml
on:
  issues:
    types: [opened, labeled]
```

**Usage**: Trigger when issue is created or labeled

#### Pattern 4: Manual with Inputs
```yaml
on:
  workflow_dispatch:
    inputs:
      component:
        description: 'Component to update'
        required: true
```

---

## Writing Agent Instructions

After the frontmatter, write the agent's instructions in Markdown.

### Structure

```markdown
---
[frontmatter here]
---

# Workflow Title

[Brief introduction explaining the workflow's purpose and context]

## Step 1 – [First Action]

[Detailed instructions for what the agent should do]

[Include specific details, validation rules, and error handling]

## Step 2 – [Second Action]

[More instructions]

## Step 3 – [etc.]

[Continue with numbered steps]
```

### Writing Effective Instructions

#### ✅ DO: Be Specific and Clear
```markdown
## Step 1 – Parse the CVE ID

From the issue title, extract the CVE ID which must match the pattern `CVE-YYYY-NNNNN`.

If the CVE ID is invalid or missing, post a comment:
> ⚠️ Invalid CVE format. Expected: CVE-2026-12345

Then **stop**.
```

#### ❌ DON'T: Be Vague
```markdown
## Step 1 – Get the CVE

Look at the issue and find the CVE.
```

#### ✅ DO: Specify Error Handling
```markdown
## Step 2 – Check org membership

Check whether `${{ github.actor }}` is a member of `${{ github.repository_owner }}`.

If they are **not** a member, post a comment:
> Sorry, only organization members can use this command.

Then **stop** without creating an issue.
```

#### ❌ DON'T: Assume Success
```markdown
## Step 2 – Check org membership

Check if the user is in the org.
```

#### ✅ DO: Provide Templates
```markdown
## Step 5 – Create pull request

Create a PR with:

**Title:**
```
fix: address <CVE-ID> in <component>
```

**Body:**
```markdown
## CVE Fix

🔒 CVE: <CVE-ID>
⚠️ Severity: <SEVERITY>

Closes #<issue-number>
```

**Labels**: `security`, `automated`, `cve-fix`
```

#### ❌ DON'T: Leave Formatting Ambiguous
```markdown
## Step 5 – Create pull request

Create a PR with the CVE info and close the issue.
```

### Using GitHub Context Variables

Access workflow context with `${{ }}` syntax:

| Variable | Description | Example |
|----------|-------------|---------|
| `${{ github.event.issue.number }}` | Issue number | `42` |
| `${{ github.event.issue.title }}` | Issue title | `CVE-2026-12345` |
| `${{ github.event.comment.body }}` | Comment text | `/fix-cve` |
| `${{ github.actor }}` | User who triggered | `username` |
| `${{ github.repository }}` | Repo name | `org/project` |
| `${{ github.repository_owner }}` | Org/user | `user` |
| `${{ github.run_id }}` | Workflow run ID | `12345678` |
| `${{ github.ref }}` | Branch ref | `refs/heads/main` |
| `${{ github.sha }}` | Commit SHA | `abc123...` |

### Step Patterns

#### Validation Step
```markdown
## Step 1 – Validate input

From the command `${{ github.event.comment.body }}`, extract the milestone argument.

Sanitize the milestone to only contain: alphanumeric, hyphens, dots.

If the milestone is empty, post a comment explaining usage and **stop**.
```

#### API Query Step
```markdown
## Step 2 – Fetch issue data

Retrieve issue #${{ github.event.issue.number }} from `${{ github.repository }}` and collect:
- **title**
- **body** (truncated to 65,536 characters)
- **labels** (exclude labels starting with `[zube]:`)
- **assignees** (login names only)
```

#### Conditional Step
```markdown
## Step 3 – Determine fix strategy

Based on the affected package:

**If it's a Go stdlib CVE:**
- Strategy: Update GO_VERSION in workflows and Dockerfiles

**If it's a SUSE base image CVE:**
- Strategy: Update base image digest

**If it's a Ruby gem CVE:**
- Strategy: Update Gemfile
```

#### External Research Step
```markdown
## Step 4 – Check upstream for fixes

Visit the upstream repository at `https://github.com/<org>/<repo>`.

Search recent commits (last 30 days) for mentions of the CVE ID.

If an upstream fix exists, note the commit SHA.
```

#### File Modification Step
```markdown
## Step 5 – Update files

Create a branch: `auto-fix-<cve-id>`

Update all workflow files:
```bash
find .github/workflows -type f \\( -name "*.yaml" -o -name "*.yml" \\) \\
  -exec sed -i "s/GO_VERSION: '[0-9.]*'/GO_VERSION: '<NEW_VERSION>'/" {} \\;
```

Commit changes:
```bash
git add .
git commit -m "fix: address <CVE-ID>"
```
```

#### Create PR/Issue Step
```markdown
## Step 6 – Create pull request

Create a PR in `${{ github.repository }}` with:

- **Title**: `fix: address <CVE-ID> in <component>`
- **Body**: [detailed template above]
- **Labels**: `security`, `automated`, `cve-fix`
- **Assignees**: `${{ github.repository_owner }}/security-team`

After creating the PR, write to workflow summary:
```
PR created: <pr-url>
```
```

### Stopping Execution

Always use explicit **stop** instructions:

```markdown
If the milestone does not exist, post a comment and **stop**.

If the user is not an org member, explain why and **stop** without further action.
```

The word **"stop"** signals the agent to halt execution.

---

## Tools and Capabilities

### GitHub Toolsets

Enable GitHub API access in frontmatter:

```yaml
tools:
  github:
    toolsets: [issues, pull-requests, discussions, code-scanning, actions]
    lockdown: false
```

#### Available Toolsets

| Toolset | Capabilities |
|---------|-------------|
| `issues` | Create, update, close, label, assign issues |
| `pull-requests` | Create, update, merge, review PRs |
| `discussions` | Create, comment on discussions |
| `code-scanning` | Query security alerts |
| `actions` | Trigger workflows, get run status |
| `repositories` | Read repo metadata |
| `teams` | Check team membership |
| `projects` | Manage project boards |

### Bash Tool

Enable shell commands:

```yaml
tools:
  bash: true
```

**Capabilities:**
- Execute shell commands
- Use standard Unix tools (`grep`, `sed`, `awk`, `jq`, `curl`)
- Git operations
- File system operations (within workspace)

**Example usage in instructions:**
```markdown
## Step 3 – Extract version

Run the following command to get the latest Go version:
```bash
curl -s 'https://go.dev/dl/?mode=json' | jq -r '.[0].version' | sed 's/go//'
```
```

### Playwright Tool

Enable browser automation:

```yaml
tools:
  playwright: true
```

**Capabilities:**
- Navigate web pages
- Click elements
- Fill forms
- Take screenshots
- Extract page content

**Example usage:**
```markdown
## Step 1 – Test accessibility

Use Playwright to navigate to `localhost:3000`.

Examine the page for WCAG 2.2 violations by:
- Clicking interactive elements
- Checking keyboard navigation
- Capturing screenshots of issues
```

### Web Fetch Tool

Enable fetching external URLs:

```yaml
tools:
  web-fetch: true
```

**Capabilities:**
- Fetch content from URLs
- Parse HTML/JSON responses
- Access external APIs (within network allowlist)

**Example usage:**
```markdown
## Step 2 – Check upstream release notes

Fetch the release notes from:
`https://github.com/upstream/repo/releases/tag/v1.2.3`

Look for mentions of security fixes or CVEs.
```

---

## Security Model

GitHub Agentic Workflows implement a 5-layer security model:

### Layer 1: Read-Only Tokens by Default

```yaml
permissions: read-all  # Agent gets read-only token
```

**What it means:**
- Agent can observe repository
- Agent cannot modify repository directly
- Even if agent tries to create PR/push code, token doesn't allow it

### Layer 2: Safe Outputs

```yaml
safe-outputs:
  create-pull-request:
    max-operations: 1
```

**What it means:**
- Agent produces a structured artifact describing intended actions
- Separate job with write permissions applies the actions
- Agent never directly modifies repo

### Layer 3: Threat Detection

Automatic before every safe output:
- AI scans agent's proposed changes
- Checks for prompt injection attacks
- Checks for leaked credentials
- Checks for malicious code patterns

If threats detected, the safe output is rejected.

### Layer 4: Network Firewall

```yaml
network: defaults  # Allowlist: github.com, api.github.com, etc.
```

**What it means:**
- All outbound traffic routed through proxy
- Only allowlisted domains accessible
- Prevents data exfiltration

### Layer 5: Human Review Required

**Built-in:**
- PRs are never merged automatically
- Humans must always review and approve
- Agent can only propose, not execute

### Security Best Practices

#### ✅ DO: Sanitize User Input

```markdown
## Step 1 – Parse command

Sanitize the milestone value to only contain: alphanumeric characters, hyphens, and dots.
```

**Why**: Prevents command injection

#### ✅ DO: Verify Permissions

```markdown
## Step 2 – Check org membership

Verify `${{ github.actor }}` is a member of `${{ github.repository_owner }}`.

If not, **stop** with error message.
```

**Why**: Prevents unauthorized access

#### ✅ DO: Limit Safe Outputs

```yaml
safe-outputs:
  create-pull-request:
    max-operations: 1  # Only 1 PR
  add-comment:
    max-operations: 3  # Max 3 comments
```

**Why**: Prevents runaway automation

#### ✅ DO: Set Reasonable Timeouts

```yaml
timeout-minutes: 15  # Max 15 minutes
```

**Why**: Prevents hung workflows

#### ❌ DON'T: Request Excessive Permissions

```yaml
# BAD
permissions:
  contents: write
  issues: write
  pull-requests: write
  actions: write
  packages: write
```

**Better**: Use `read-all` and rely on safe outputs

---

## Common Patterns

### Pattern 1: Slash Command Handler

**Use Case**: User comments `/command <args>` to trigger automation

```yaml
---
description: Handle /fix-cve command on issues

on:
  slash_command:
    name: fix-cve
    events: [issue_comment]
  reaction: "eyes"

permissions: read-all

safe-outputs:
  create-pull-request:
    max-operations: 1
  add-comment:
    max-operations: 3

tools:
  bash: true
  github:
    toolsets: [issues, pull-requests]

timeout-minutes: 15
---

# Fix CVE Command Handler

User posted: `${{ github.event.comment.body }}` on issue #${{ github.event.issue.number }}

## Step 1 – Parse command

Command format: `/fix-cve <CVE-ID>`

Extract the CVE ID (must match `CVE-YYYY-NNNNN`).

If invalid, post comment with usage and **stop**.

## Step 2 – Verify permissions

Check if `${{ github.actor }}` is a member of `${{ github.repository_owner }}`.

If not a member, post error and **stop**.

## Step 3 – Analyze CVE

[Analysis steps...]

## Step 4 – Create fix

[Fix implementation...]

## Step 5 – Create PR

[PR creation...]
```

### Pattern 2: Scheduled Health Check

**Use Case**: Daily/weekly automated reports

```yaml
---
description: Weekly health check of repository

on:
  schedule:
    - cron: '0 6 * * 1'  # Every Monday 6 AM
  workflow_dispatch:

permissions: read-all

safe-outputs:
  create-issue:
    max-operations: 1

tools:
  bash: true
  github:
    toolsets: [issues, actions, code-scanning]

timeout-minutes: 20
---

# Weekly Health Check

Today is Monday. Generate health report for `${{ github.repository }}`.

## Step 1 – Check build status

Query the last 5 workflow runs on main branch.

Collect: status, conclusion, workflow name, run date.

## Step 2 – Check for security alerts

Query code scanning alerts with severity HIGH or CRITICAL.

## Step 3 – Check for stale PRs

List open PRs older than 7 days.

## Step 4 – Generate report

Create issue titled "Health Report - Week of <date>"

Body should include:
- Build status table
- Security alert count
- List of stale PRs
- Recommended actions

Labels: `report`, `automated`, `health-check`
```

### Pattern 3: Issue Triage

**Use Case**: Auto-label and categorize new issues

```yaml
---
description: Auto-triage new issues

on:
  issues:
    types: [opened]

permissions: read-all

safe-outputs:
  update-issue:
    max-operations: 1
  add-comment:
    max-operations: 1

tools:
  github:
    toolsets: [issues]

timeout-minutes: 5
---

# Issue Triage

New issue #${{ github.event.issue.number }} created by @${{ github.event.issue.user.login }}

## Step 1 – Analyze issue content

Read the issue title and body.

Classify into categories:
- **bug**: Contains "bug", "error", "broken", "not working"
- **feature**: Contains "feature request", "enhancement", "add"
- **question**: Contains "how to", "question", "help"
- **security**: Contains "CVE", "security", "vulnerability"

## Step 2 – Assign labels

Based on classification, apply appropriate labels.

If security-related, also add `priority-high` label.

## Step 3 – Assign to project

If bug or security issue, add to "Current Sprint" project.

## Step 4 – Post welcome comment

If this is the user's first issue, post a welcome comment:
> Thanks for opening your first issue! A maintainer will review it soon.
```

### Pattern 4: PR Validation

**Use Case**: Check PR meets requirements before review

```yaml
---
description: Validate PR requirements

on:
  pull_request:
    types: [opened, synchronize]

permissions: read-all

safe-outputs:
  add-comment:
    max-operations: 2

tools:
  bash: true
  github:
    toolsets: [pull-requests]

timeout-minutes: 10
---

# PR Validation

Validate PR #${{ github.event.pull_request.number }}

## Step 1 – Check PR description

Ensure PR body is not empty.

If empty, post comment:
> ⚠️ Please add a description explaining the changes.

## Step 2 – Check for tests

List all changed files.

If files in `src/` were modified, check if corresponding test files in `tests/` were updated.

If no tests updated, post comment:
> ⚠️ Tests may be needed for these changes.

## Step 3 – Check commit messages

Review commit messages for conventional commit format.

If not following format, post helpful comment with examples.

## Step 4 – Summarize

Post a summary comment listing:
- Files changed
- Tests status
- Commit message compliance
```

### Pattern 5: Release Automation

**Use Case**: Create release notes from PRs

```yaml
---
description: Generate release notes

on:
  workflow_dispatch:
    inputs:
      milestone:
        description: 'Milestone for release'
        required: true

permissions: read-all

safe-outputs:
  create-discussion:
    max-operations: 1
    category: "announcements"

tools:
  bash: true
  github:
    toolsets: [pull-requests, discussions]

timeout-minutes: 15
---

# Generate Release Notes

Generate release notes for milestone: `${{ github.event.inputs.milestone }}`

## Step 1 – Fetch merged PRs

Get all PRs merged into main branch with milestone `${{ github.event.inputs.milestone }}`.

## Step 2 – Categorize PRs

Group PRs by label:
- **Features**: PRs with `enhancement` label
- **Bug Fixes**: PRs with `bug` label
- **Security**: PRs with `security` label
- **Documentation**: PRs with `documentation` label
- **Other**: Everything else

## Step 3 – Format release notes

Create markdown formatted notes:

```markdown
## Release v${{ github.event.inputs.milestone }}

### 🚀 Features
- Description (#PR-number) by @author

### 🐛 Bug Fixes
- Description (#PR-number) by @author

### 🔒 Security
- Description (#PR-number) by @author

### Contributors
Thanks to: @user1, @user2
```

## Step 4 – Create discussion

Post formatted notes as discussion in "announcements" category.
```

---

## Best Practices

### Writing Style

#### Be Explicit
```markdown
✅ GOOD:
## Step 1 – Sanitize input
Sanitize the milestone to only contain alphanumeric characters, hyphens, and dots.

❌ BAD:
## Step 1 – Clean input
Clean the milestone value.
```

#### Use Step Numbers
```markdown
✅ GOOD:
## Step 1 – Parse
## Step 2 – Validate
## Step 3 – Execute

❌ BAD:
## Parse the input
## Validate it
## Do the thing
```

#### Specify Exact Outputs
```markdown
✅ GOOD:
Post a comment:
> ✅ PR created: <url>
>
> Review required from security team.

❌ BAD:
Let the user know a PR was created.
```

### Error Handling

#### Always Validate First
```markdown
## Step 1 – Validate input
[Check all inputs]

## Step 2 – Verify permissions
[Check user has access]

## Step 3 – Confirm prerequisites
[Check milestone exists, etc.]

## Step 4 – Execute action
[Only after all validations pass]
```

#### Explicit Stop Conditions
```markdown
If the CVE ID is invalid, post error message and **stop**.

If user lacks permissions, explain why and **stop** without creating PR.
```

### Performance

#### Set Appropriate Timeouts
- Simple commands: 5 minutes
- Data analysis: 10 minutes
- Complex operations: 15 minutes
- Maximum allowed: 60 minutes (avoid if possible)

#### Limit Network Calls
```markdown
## Step 1 – Batch API calls

Fetch all required data in one step:
- Issue details
- User info
- Milestone data

Don't make separate calls for each piece of data.
```

### Maintainability

#### Use Comments
```markdown
---
description: |
  This workflow handles CVE auto-fix.

  Triggered by: /fix-cve command on issues
  Creates: PR with appropriate fixes
  Requires: Security team review
---
```

#### Document Assumptions
```markdown
## Step 2 – Parse semver

The version must follow semantic versioning (MAJOR.MINOR.PATCH).

Extract components using regex: `v?(\d+)\.(\d+)\.(\d+)`

If version doesn't match pattern, **stop** with error.
```

#### Add Workflow Identifiers
```markdown
At the end of PR/issue body, add:

---
🤖 Generated by [CVE Auto-Fix](https://github.com/${{ github.repository }}/actions/runs/${{ github.run_id }})

<!-- gh-aw-workflow-id: cve-auto-fix -->
```

---

## Complete Examples

### Example 1: CVE Auto-Fix (Production-Ready)

```markdown
---
description: |
  Automatically respond to CVE findings from image scanning.
  Analyzes the CVE and creates PR with appropriate fix.

on:
  slash_command:
    name: fix-cve
    events: [issue_comment]
  reaction: "eyes"

permissions: read-all

network: defaults

safe-outputs:
  create-pull-request:
    max-operations: 1
  add-comment:
    max-operations: 3

tools:
  bash: true
  web-fetch: true
  github:
    toolsets: [issues, pull-requests, code-scanning]
    lockdown: false

timeout-minutes: 15
---

# CVE Auto-Fix

You are an automation assistant that responds to CVE findings.

User posted: `${{ github.event.comment.body }}` on issue #${{ github.event.issue.number }}

This issue was created by the security scanning team.

## Step 1 – Parse the CVE issue

From the issue title and body, extract:
- **CVE ID** (format: CVE-YYYY-NNNNN)
- **Affected package** (e.g., stdlib, libssl, nokogiri)
- **Severity** (CRITICAL, HIGH, MEDIUM, LOW)
- **Fixed version** (if available)

If the issue doesn't contain a valid CVE, post a comment:
> ⚠️ This doesn't appear to be a valid CVE issue.

Then **stop**.

## Step 2 – Determine fix strategy

Based on the affected package:

**If it's a Go stdlib CVE:**
- Check latest stable Go version at https://go.dev/dl/?mode=json
- Determine if CVE is fixed in that version
- Strategy: Update GO_VERSION in workflows and Dockerfiles

**If it's a base image CVE:**
- Check for newer base image digest
- Strategy: Update Dockerfile to pin new digest

**If it's a dependency CVE:**
- Research available versions that fix the CVE
- Strategy: Update dependency file (go.mod, Gemfile, package.json)

Post a comment summarizing the strategy:
> **Fix Strategy Determined**
>
> - CVE: <CVE-ID>
> - Severity: <SEVERITY>
> - Fix: <strategy>
>
> Creating PR...

## Step 3 – Check for upstream fixes

Visit the upstream repository (from Chart.yaml or package metadata).

Search recent commits (last 60 days) for:
- Mentions of the CVE ID
- Security-related commits
- Version bumps that might address the CVE

If an upstream fix exists, note the commit SHA.

## Step 4 – Create fix branch and make changes

Create branch: `auto-fix-cve-<cve-number>`

**For Go stdlib fixes:**
```bash
NEW_VERSION="1.26.1"  # Use version from Step 2

# Update workflows
find .github/workflows -type f \\( -name "*.yaml" -o -name "*.yml" \\) \\
  -exec sed -i "s/GO_VERSION: '[0-9.]*'/GO_VERSION: '${NEW_VERSION}'/" {} \\;

# Update Dockerfiles
find . -name "Dockerfile*" \\
  -exec sed -i "s/ARG GO_VERSION=[0-9.]*/ARG GO_VERSION=${NEW_VERSION}/" {} \\;
```

**For base image fixes:**
```bash
NEW_DIGEST="sha256:abc123..."  # Use digest from Step 2

sed -i "s|FROM registry.suse.com/bci/bci-micro:latest|FROM registry.suse.com/bci/bci-micro@${NEW_DIGEST}|" Dockerfile
```

Commit changes:
```bash
git add .
git commit -m "fix: address ${{ github.event.issue.number }} (<CVE-ID>)

Updates <package> to fix <CVE-ID>.

Closes #${{ github.event.issue.number }}

Co-Authored-By: Security Bot <security@company.com>"
```

## Step 5 – Create pull request

Create PR with:

**Title:**
```
fix: address <CVE-ID> in <component>
```

**Body:**
```markdown
## CVE Fix

🔒 **CVE**: <CVE-ID>
⚠️ **Severity**: <SEVERITY>
📦 **Affected**: <package-name>
🔧 **Component**: <component>

## Original Issue

Closes #${{ github.event.issue.number }}

## Changes

- Updated <file1> to version X.Y.Z
- Updated <file2> with new base image
- etc.

<if upstream fix exists>
## Upstream Reference
Based on upstream commit: <commit-sha>
</if>

## Testing Required

- [ ] Build passes with updated dependencies
- [ ] Image runs without errors
- [ ] CVE scanner confirms fix

## Security Review

This PR requires review from:
- [ ] Security team (CVE verification)
- [ ] Component maintainers (functionality)

---

🤖 Generated by [CVE Auto-Fix](https://github.com/${{ github.repository }}/actions/runs/${{ github.run_id }})

<!-- gh-aw-workflow-id: cve-auto-fix -->
```

**Labels**: `security`, `automated`, `cve-fix`, `needs-review`

After creating PR, post final comment on issue:
> ✅ **PR Created**
>
> I've created PR #<number> to address this CVE.
>
> The PR updates <summary> and requires review.
```

### Example 2: Daily Health Check

```markdown
---
description: |
  Daily health check report for repository.
  Monitors builds, dependencies, and open issues.

on:
  schedule:
    - cron: '0 6 * * 1'  # Every Monday at 6 AM UTC
  workflow_dispatch:

permissions: read-all

network: defaults

safe-outputs:
  create-issue:
    max-operations: 1

tools:
  bash: true
  github:
    toolsets: [issues, actions, pull-requests]

timeout-minutes: 20
---

# Daily Repository Health Check

Generate weekly health report for `${{ github.repository }}`.

Today is **Monday, <current-date>**.

## Step 1 – Check build status

Query the last 10 workflow runs on the main branch:
```bash
gh run list --repo ${{ github.repository }} --branch main --limit 10 \\
  --json conclusion,status,name,createdAt
```

Collect:
- Number of successful builds
- Number of failed builds
- Most recent failure (if any)
- Build trend (improving/declining)

## Step 2 – Check open issues

Count open issues by label:
- `bug`
- `enhancement`
- `security`
- `question`

Identify:
- Issues with no activity in 30+ days
- Issues without labels
- Issues assigned but not updated in 14+ days

## Step 3 – Check open PRs

List open PRs and categorize:
- **Active**: Updated within 7 days
- **Stale**: No updates for 7-30 days
- **Very Stale**: No updates for 30+ days

Check for:
- PRs awaiting review
- PRs with failed checks
- PRs with merge conflicts

## Step 4 – Check dependencies (if applicable)

If the repo has package files (go.mod, package.json, Gemfile):
- Check for outdated dependencies
- Check for dependencies with known CVEs

## Step 5 – Generate health report

Create an issue titled: `[Health Report] Week of <date>`

**Body format:**
```markdown
## 📊 Weekly Health Report

**Repository**: `${{ github.repository }}`
**Report Date**: <current-date>
**Period**: Last 7 days

---

## 🏗️ Build Health

| Metric | Value | Status |
|--------|-------|--------|
| Recent builds (10) | X successful, Y failed | ✅/⚠️/❌ |
| Build success rate | X% | ✅/⚠️/❌ |
| Last failure | <date> - <reason> | ✅/⚠️/❌ |

<if any failures>
### Failed Builds
- <workflow-name> failed on <date>: <reason>
</if>

---

## 📋 Issue Health

| Category | Open Count | Trend |
|----------|-----------|-------|
| Bugs | X | ↗️/→/↘️ |
| Enhancements | X | ↗️/→/↘️ |
| Security | X | ↗️/→/↘️ |
| Questions | X | ↗️/→/↘️ |

### Issues Needing Attention
- X stale issues (30+ days no activity)
- X unlabeled issues
- X assigned but stale (14+ days)

---

## 🔄 Pull Request Health

| Status | Count | Action Needed |
|--------|-------|---------------|
| Active (< 7 days) | X | Review |
| Stale (7-30 days) | X | Ping authors |
| Very Stale (30+ days) | X | Close or escalate |

### PRs Requiring Attention
<list of stale PRs with titles and links>

---

## 📦 Dependency Health

<if applicable>
- Outdated dependencies: X
- Dependencies with CVEs: X
- Recommendations: <list>
</if>

---

## 🎯 Action Items

### High Priority
1. <action item 1>
2. <action item 2>

### Medium Priority
3. <action item 3>
4. <action item 4>

### Low Priority
5. <action item 5>

---

📅 **Next Report**: <next-monday-date>

🤖 Generated by [Health Check](https://github.com/${{ github.repository }}/actions/runs/${{ github.run_id }})

<!-- gh-aw-workflow-id: health-check -->
```

**Labels**: `report`, `health-check`, `automated`

After creating the issue, write to workflow summary:
```
Health report created: <issue-url>
```
```

---

## Compilation and Deployment

### Install gh-aw CLI

```bash
# Install the GitHub CLI extension
gh extension install github/gh-aw

# Verify installation
gh aw version
```

### Create Workflow

```bash
# Navigate to repository
cd /path/to/repo

# Create workflows directory
mkdir -p .github/workflows

# Create your workflow markdown file
cat > .github/workflows/my-workflow.md <<'EOF'
---
description: My workflow description
on:
  workflow_dispatch:
permissions: read-all
tools:
  bash: true
---

# My Workflow
Instructions here...
EOF
```

### Compile Workflow

```bash
# Compile markdown to YAML
gh aw compile .github/workflows/my-workflow.md

# This creates: .github/workflows/my-workflow.lock.yml
```

**Output:**
```
✓ Compiled .github/workflows/my-workflow.md
  → .github/workflows/my-workflow.lock.yml
```

### Commit and Push

```bash
# Stage both files
git add .github/workflows/my-workflow.md
git add .github/workflows/my-workflow.lock.yml

# Commit
git commit -m "feat: add agentic workflow for X"

# Push
git push origin main
```

### Test Workflow

```bash
# Manual trigger
gh workflow run my-workflow.md

# Or trigger via event (e.g., comment on issue)
gh issue comment 123 --body "/my-command"

# Watch execution
gh run watch

# View logs
gh run view --log
```

### Update Workflow

```bash
# Edit the markdown file
vim .github/workflows/my-workflow.md

# Recompile
gh aw compile .github/workflows/my-workflow.md

# Commit changes
git add .github/workflows/my-workflow.{md,lock.yml}
git commit -m "chore: update workflow logic"
git push
```

### Workflow Management Commands

```bash
# List all agentic workflows
gh aw list

# Validate workflow syntax
gh aw validate .github/workflows/my-workflow.md

# Get workflow status
gh aw status my-workflow

# View workflow logs
gh aw logs my-workflow --run latest

# Disable workflow
gh workflow disable my-workflow.lock.yml

# Enable workflow
gh workflow enable my-workflow.lock.yml
```

---

## Troubleshooting

### Common Issues

#### Issue: Workflow not triggering

**Symptom**: Slash command posted but workflow doesn't run

**Solutions:**
1. Check frontmatter trigger config:
   ```yaml
   on:
     slash_command:
       name: exact-command-name  # Must match exactly
   ```

2. Verify `.lock.yml` file exists and is up to date:
   ```bash
   gh aw compile .github/workflows/workflow-name.md
   ```

3. Check workflow is enabled:
   ```bash
   gh workflow enable workflow-name.lock.yml
   ```

#### Issue: Agent doesn't understand instructions

**Symptom**: Agent performs wrong actions or gets confused

**Solutions:**
1. Be more explicit in instructions
2. Break down complex steps into smaller steps
3. Add examples and templates
4. Use "If X, then Y, otherwise Z" conditionals

**Before:**
```markdown
## Step 1 – Process the issue
Handle the issue appropriately.
```

**After:**
```markdown
## Step 1 – Categorize the issue

Read the issue title and body.

If title contains "CVE-" or body mentions "security":
- Category: security
- Priority: high

If title contains "bug" or "error":
- Category: bug
- Priority: medium

Otherwise:
- Category: enhancement
- Priority: low
```

#### Issue: Safe output rejected

**Symptom**: "Threat detected" error in logs

**Solutions:**
1. Check agent's proposed changes for:
   - Leaked credentials (API keys, tokens)
   - Malicious code patterns
   - Prompt injection attempts

2. Review safe-output limits:
   ```yaml
   safe-outputs:
     create-pull-request:
       max-operations: 1  # Ensure not exceeded
   ```

3. Ensure instructions don't ask agent to output secrets

#### Issue: Timeout

**Symptom**: Workflow fails with timeout error

**Solutions:**
1. Increase timeout:
   ```yaml
   timeout-minutes: 30  # Increase from 15
   ```

2. Reduce scope of work per run
3. Break into multiple smaller workflows

#### Issue: Network error

**Symptom**: Cannot fetch external URLs

**Solutions:**
1. Enable network access:
   ```yaml
   network: defaults
   ```

2. Add specific domains to allowlist:
   ```yaml
   network:
     allow: [github.com, api.github.com, example.com]
   ```

3. Use web-fetch tool:
   ```yaml
   tools:
     web-fetch: true
   ```

#### Issue: Permission denied

**Symptom**: Agent cannot create PR/issue

**Solutions:**
1. Check safe-outputs are configured:
   ```yaml
   safe-outputs:
     create-pull-request:
       max-operations: 1
   ```

2. Ensure not exceeding max-operations limit

3. Check permissions in frontmatter (usually keep `read-all`)

### Debugging Tips

#### Enable verbose logging

In workflow instructions:
```markdown
## Step X – Debug

Before executing, print to workflow summary:
```
Step X starting...
Context: <relevant-variables>
```

Execute action...

After executing, print to workflow summary:
```
Step X completed
Result: <result-summary>
```
```

#### Add checkpoints

```markdown
## Step 2 – Validate

Check if milestone exists.

Write to summary: "Milestone validation: <exists/missing>"

If missing, **stop**.

Otherwise, continue to Step 3.
```

#### Review generated YAML

```bash
# View the compiled workflow
cat .github/workflows/workflow-name.lock.yml

# Look for the agent execution steps
# Check safe-output configuration
```

#### Test in isolation

Create a test repository to validate workflows before deploying to production.

```bash
# Fork repo for testing
gh repo fork --clone

# Deploy workflow to test repo
cd forked-repo
cp ../prod-repo/.github/workflows/my-workflow.md .github/workflows/
gh aw compile .github/workflows/my-workflow.md
git add .github/workflows/
git commit -m "test: deploy workflow"
git push

# Test workflow
gh workflow run my-workflow.md
gh run watch
```

---

## Summary for AI Agents

When helping users create GitHub Agentic Workflows:

### ✅ Always Do:
1. Start with frontmatter (description, triggers, permissions, tools)
2. Write step-by-step instructions with clear numbers
3. Be explicit about validation and error handling
4. Include templates for outputs (PR bodies, comments, etc.)
5. Sanitize user inputs
6. Verify permissions before actions
7. Use **stop** keyword for halting execution
8. Add workflow identifiers to generated content
9. Limit safe-outputs appropriately
10. Set reasonable timeouts

### ❌ Never Do:
1. Edit `.lock.yml` files (they're auto-generated)
2. Request excessive permissions
3. Leave error handling ambiguous
4. Assume AI will "figure it out"
5. Forget to validate inputs
6. Skip security checks
7. Allow unlimited safe-output operations
8. Use vague instructions

### 🎯 Goal:
Write workflows that are:
- **Secure** (read-only, validated, limited)
- **Clear** (explicit, step-by-step)
- **Maintainable** (well-documented, self-explanatory)
- **Reliable** (handles errors, validates inputs)

---

## Version History

- **1.0** (2026-05-06): Initial comprehensive guide
- Based on GitHub Agentic Workflows v0.43.15
- Incorporates real-world patterns from production usage

---

## Additional Resources

- **GitHub Agentic Workflows Docs**: https://github.github.com/gh-aw/
- **gh-aw CLI Repository**: https://github.com/github/gh-aw
- **Community Examples**: https://github.com/githubnext/agentics
- **Discussion Forum**: https://github.com/orgs/community/discussions (tag: agentic-workflows)

---

**END OF GUIDE**
