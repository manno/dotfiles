#!/usr/bin/env node
// analyze-plugin.mjs
//
// Job 2 of the plugin-bump workflow.
// Performs agentic security analysis of a single Neovim plugin update using
// the GitHub Models API (OpenAI-compatible) with iterative tool calling.
//
// Required env vars:
//   PLUGIN_SLUG, PLUGIN_SLUG_SAFE, PLUGIN_OWNER, PLUGIN_REPO,
//   PLUGIN_OLD_SHA, PLUGIN_NEW_SHA, PLUGIN_TAG, GITHUB_TOKEN
//
// Output: writes {PLUGIN_SLUG_SAFE}-analysis.md in the current directory.

import { execFileSync } from 'node:child_process';
import { writeFileSync } from 'node:fs';

const {
  PLUGIN_SLUG,
  PLUGIN_SLUG_SAFE,
  PLUGIN_OWNER: owner,
  PLUGIN_REPO: repo,
  PLUGIN_OLD_SHA: oldSHA,
  PLUGIN_NEW_SHA: newSHA,
  PLUGIN_TAG: tag,
  GITHUB_TOKEN,
} = process.env;

for (const v of ['PLUGIN_SLUG', 'PLUGIN_SLUG_SAFE', 'PLUGIN_OWNER', 'PLUGIN_REPO', 'PLUGIN_NEW_SHA', 'PLUGIN_TAG', 'GITHUB_TOKEN']) {
  if (!process.env[v]) { console.error(`Missing required env var: ${v}`); process.exit(1); }
}

const outFile = `${PLUGIN_SLUG_SAFE}-analysis.md`;

// ── GitHub API via gh CLI ─────────────────────────────────────────────────────

function ghApi(path) {
  try {
    const out = execFileSync('gh', ['api', path], {
      encoding: 'utf8',
      env: process.env,
      maxBuffer: 10 * 1024 * 1024,
    });
    return JSON.parse(out);
  } catch (e) {
    return { _error: e.message.slice(0, 300) };
  }
}

// ── Tool definitions ──────────────────────────────────────────────────────────

const tools = [
  {
    type: 'function',
    function: {
      name: 'list_changed_files',
      description: 'List all files changed between the old and new commit SHAs, with additions/deletions counts.',
      parameters: { type: 'object', properties: {}, required: [] },
    },
  },
  {
    type: 'function',
    function: {
      name: 'get_file_diff',
      description: 'Get the unified diff patch for a specific file in this update. Large diffs are returned in chunks of 2000 chars. If the result ends with a "... N chars remaining" note, call again with offset set to the next position to read the next chunk.',
      parameters: {
        type: 'object',
        properties: {
          filename: { type: 'string', description: 'File path within the repo, as returned by list_changed_files.' },
          offset:   { type: 'number', description: 'Character offset to start reading from. Omit or set to 0 for the first chunk.' },
        },
        required: ['filename'],
      },
    },
  },
  {
    type: 'function',
    function: {
      name: 'get_file_content',
      description: 'Get the full content of a file at the new commit. Use for files where a diff alone is not enough context. Large files are returned in chunks of 2000 chars. If the result ends with a "... N chars remaining" note, call again with offset set to the next position.',
      parameters: {
        type: 'object',
        properties: {
          path:   { type: 'string', description: 'File path within the repo.' },
          offset: { type: 'number', description: 'Character offset to start reading from. Omit or set to 0 for the first chunk.' },
        },
        required: ['path'],
      },
    },
  },
  {
    type: 'function',
    function: {
      name: 'get_commit_details',
      description: 'Get the commit message and per-file stats for a specific commit SHA.',
      parameters: {
        type: 'object',
        properties: {
          sha: { type: 'string', description: 'Full commit SHA.' },
        },
        required: ['sha'],
      },
    },
  },
];

// ── Tool execution ────────────────────────────────────────────────────────────

const CHUNK_SIZE = 2000; // chars per tool result (~500 tokens)

// Return a slice of `text` starting at `offset`, with a continuation hint
// appended when more content follows. The model can request the next chunk
// by calling the same tool again with offset set to the returned next position.
function chunk(text, offset) {
  const slice = text.slice(offset, offset + CHUNK_SIZE);
  const remaining = text.length - (offset + CHUNK_SIZE);
  if (remaining > 0) {
    return `${slice}\n... ${remaining} chars remaining — call with offset: ${offset + CHUNK_SIZE}`;
  }
  return slice;
}

function executeTool(name, args) {
  const base = oldSHA || `${newSHA}^`;

  if (name === 'list_changed_files') {
    const data = ghApi(`/repos/${owner}/${repo}/compare/${base}...${newSHA}`);
    if (data._error) return `Error: ${data._error}`;
    if (!Array.isArray(data.files)) return 'No changed files found or comparison unavailable.';
    if (data.files.length === 0) return 'No files changed.';
    return data.files
      .map(f => `${f.status.padEnd(10)} ${f.filename}  (+${f.additions} -${f.deletions})`)
      .join('\n');
  }

  if (name === 'get_file_diff') {
    const { filename, offset = 0 } = args;
    const data = ghApi(`/repos/${owner}/${repo}/compare/${base}...${newSHA}`);
    if (data._error) return `Error: ${data._error}`;
    const file = (data.files || []).find(f => f.filename === filename);
    if (!file) return `File not found in diff: ${filename}`;
    return chunk(file.patch || '(binary file or patch not available)', offset);
  }

  if (name === 'get_file_content') {
    const { path, offset = 0 } = args;
    const data = ghApi(`/repos/${owner}/${repo}/contents/${path}?ref=${newSHA}`);
    if (data._error) return `Error: ${data._error}`;
    if (!data.content) return 'No content available (directory or binary file).';
    try {
      const text = Buffer.from(data.content.replace(/\n/g, ''), 'base64').toString('utf8');
      return chunk(text, offset);
    } catch {
      return '(failed to decode content)';
    }
  }

  if (name === 'get_commit_details') {
    const { sha } = args;
    const data = ghApi(`/repos/${owner}/${repo}/commits/${sha}`);
    if (data._error) return `Error: ${data._error}`;
    const files = (data.files || [])
      .map(f => `  ${f.filename}  (+${f.additions} -${f.deletions})`)
      .join('\n');
    const msg = data.commit?.message?.slice(0, 500) ?? '(no message)';
    return `SHA: ${sha}\nMessage:\n${msg}\n\nFiles:\n${files}`;
  }

  return `Unknown tool: ${name}`;
}

// ── GitHub Models API ─────────────────────────────────────────────────────────

async function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function callModels(messages) {
  const maxRetries = 10;
  const maxDelay = 600_000; // cap at 10 min
  let delay = 10_000; // start at 10 s; 429s come in bursts at job startup

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    const res = await fetch('https://models.github.ai/inference/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${GITHUB_TOKEN}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'openai/gpt-4o',
        messages,
        tools,
        tool_choice: 'auto',
        max_tokens: 4096,
      }),
    });

    if (res.status === 429) {
      const retryAfter = parseInt(res.headers.get('retry-after') ?? '0', 10);
      const wait = Math.min(retryAfter > 0 ? retryAfter * 1000 : delay, maxDelay);
      console.error(`[${PLUGIN_SLUG}] 429 rate-limited — waiting ${wait / 1000}s (attempt ${attempt}/${maxRetries})`);
      await sleep(wait);
      delay = Math.min(delay * 2, maxDelay);
      continue;
    }

    if (!res.ok) {
      const body = await res.text();
      throw new Error(`GitHub Models API ${res.status}: ${body.slice(0, 300)}`);
    }

    const data = await res.json();
    const u = data.usage;
    if (u) {
      console.error(`[${PLUGIN_SLUG}]   tokens — prompt: ${u.prompt_tokens}, completion: ${u.completion_tokens}, total: ${u.total_tokens}`);
      totalTokens.prompt     += u.prompt_tokens     ?? 0;
      totalTokens.completion += u.completion_tokens ?? 0;
      totalTokens.total      += u.total_tokens      ?? 0;
    }
    return data.choices[0].message;
  }

  throw new Error(`GitHub Models API still rate-limiting after ${maxRetries} retries (max wait ${maxDelay / 60_000}min each)`);
}

// ── Token usage accumulator ───────────────────────────────────────────────────

const totalTokens = { prompt: 0, completion: 0, total: 0 };

// ── Main ──────────────────────────────────────────────────────────────────────

const rangeDesc = oldSHA
  ? `${oldSHA.slice(0, 8)} → ${newSHA.slice(0, 8)} (${tag})`
  : `initial pin to ${newSHA.slice(0, 8)} (${tag}) — no previous commit to compare`;

const systemPrompt = `You are a security auditor reviewing a Neovim plugin update.

Plugin: ${PLUGIN_SLUG}
Update: ${rangeDesc}
Repository: https://github.com/${owner}/${repo}

Use the available tools to examine the changes between ${oldSHA || 'the beginning'} and ${newSHA}.
Start by calling list_changed_files, then investigate the files that warrant attention —
especially Lua, Vim script, shell scripts, Python, and CI/CD configuration files.

Look specifically for:
- Shell execution: vim.fn.system(), io.popen(), os.execute(), jobstart(), vim.system()
- New network calls or changed remote endpoints (curl, wget, luasocket, plenary.curl)
- Credential, token, or environment variable handling (os.getenv, vim.env)
- File writes outside ~/.config or ~/.local
- Obfuscated code: base64/hex literals, dynamic require(), loadstring()
- New autocommands on broad events (BufWritePost, BufEnter, VimEnter, TextChanged)
- Suspicious install scripts or post-install hooks
- Changes to CI/CD workflows that could affect artifact integrity

After your investigation, issue one of these verdicts:

**Verdict: CLEAN** — nothing suspicious found; provide a short summary of what you checked.
**Verdict: WARN** — a specific suspicious pattern found; you MUST cite the exact file and line number(s).
**Verdict: BLOCK** — strong evidence of malicious behaviour; you MUST cite exact file and line(s).

Rules:
- Do NOT use WARN without a specific file+line citation.
- Do NOT tell the user to review the diff themselves — you are the reviewer; give a conclusion.
- Keep the report concise: verdict line, 2–4 sentence summary, findings section if WARN/BLOCK.
- Request at most 3 files per turn. Diffs are returned in 2000-char chunks; use the offset parameter to page through large files.`;

async function main() {
  const messages = [{ role: 'system', content: systemPrompt }];

  let finalContent = '';
  const maxIterations = 10;

  for (let i = 1; i <= maxIterations; i++) {
    console.error(`[${PLUGIN_SLUG}] iteration ${i}/${maxIterations}...`);

    const msg = await callModels(messages);
    messages.push(msg);

    const finish = msg.finish_reason ?? (msg.tool_calls?.length ? 'tool_calls' : 'stop');
    if (finish === 'length') {
      console.error(`[${PLUGIN_SLUG}]   warning: finish_reason=length — response was truncated`);
    }

    if (!msg.tool_calls || msg.tool_calls.length === 0) {
      finalContent = msg.content ?? '';
      break;
    }

    for (const tc of msg.tool_calls) {
      let args = {};
      try { args = JSON.parse(tc.function.arguments); } catch {}
      console.error(`[${PLUGIN_SLUG}]   → ${tc.function.name}(${JSON.stringify(args)})`);
      const result = executeTool(tc.function.name, args);
      messages.push({
        role: 'tool',
        tool_call_id: tc.id,
        name: tc.function.name,  // required by OpenAI spec
        content: result,
      });
    }

    // GitHub Models caps the total request body at 8000 tokens. The messages
    // array grows each iteration: every tool call adds an assistant message
    // (with tool_calls) and one or more tool messages (one per tool called).
    // For large plugins this blows the limit after just a few diffs.
    //
    // We prune by dropping the oldest assistant+tool block after each
    // iteration, keeping only messages[0] (the system prompt) and the
    // KEEP_PAIRS most recent assistant turns with their tool responses.
    //
    // The OpenAI API requires that tool results immediately follow the
    // assistant message that requested them, so we must cut at an assistant
    // message boundary — never in the middle of a block. We find the index
    // of the (N - KEEP_PAIRS)th assistant message and splice up to there.
    //
    // Example: model called two tools in turn 1, one tool in turn 2.
    //   [0] user: system prompt              ← always kept
    //   [1] assistant: tool_calls [a, b]     ← oldest block
    //   [2] tool: result for a
    //   [3] tool: result for b
    //   [4] assistant: tool_calls [c]        ← kept (KEEP_PAIRS = 2 means keep last 2)
    //   [5] tool: result for c
    //
    // Cutting at index 1 (the oldest assistant) gives the correct result.
    // The naive KEEP_PAIRS * 2 offset would cut at index 3, leaving an
    // orphaned tool message at [1] and causing a 400 invalid_request_error.
    const KEEP_PAIRS = 2;
    const assistantIndices = messages
      .map((m, i) => (m.role === 'assistant' && i > 0 ? i : -1))
      .filter(i => i >= 0);
    if (assistantIndices.length > KEEP_PAIRS) {
      const cutAt = assistantIndices[assistantIndices.length - KEEP_PAIRS];
      messages.splice(1, cutAt - 1);
      console.error(`[${PLUGIN_SLUG}]   pruned history to ${messages.length} messages`);
    }
  }

  if (!finalContent) {
    finalContent = `**Verdict: WARN**\n\nAnalysis reached the iteration limit (${maxIterations}) without producing a final verdict. Manual review recommended.`;
  }

  console.error(`[${PLUGIN_SLUG}] total tokens — prompt: ${totalTokens.prompt}, completion: ${totalTokens.completion}, total: ${totalTokens.total}`);

  const report = `## ${PLUGIN_SLUG} — ${tag}\n\n${finalContent}\n`;
  writeFileSync(outFile, report, 'utf8');
  console.log(`[${PLUGIN_SLUG}] wrote ${outFile}`);
}

main().catch(e => {
  console.error(`[${PLUGIN_SLUG}] fatal:`, e.message);
  writeFileSync(
    outFile,
    `## ${PLUGIN_SLUG} — ${tag}\n\n**Verdict: ERROR**\n\nAnalysis script failed: ${e.message}\n`,
    'utf8',
  );
  process.exit(1);
});
