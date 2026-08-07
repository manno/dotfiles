#!/usr/bin/env node
// analyze-plugin.mjs
//
// Job 2 of the plugin-bump workflow.
// Performs agentic security analysis of a single Neovim plugin update using
// the z.ai GLM API (OpenAI-compatible) with iterative tool calling.
//
// GITHUB_TOKEN still backs the `gh api` tool calls below; only inference
// moved off GitHub (GitHub Models was retired on 2026-07-30).
//
// Required env vars:
//   PLUGIN_SLUG, PLUGIN_SLUG_SAFE, PLUGIN_OWNER, PLUGIN_REPO,
//   PLUGIN_OLD_SHA, PLUGIN_NEW_SHA, PLUGIN_TAG, GITHUB_TOKEN, ZAI_API_KEY
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
  ZAI_API_KEY,
} = process.env;

for (const v of ['PLUGIN_SLUG', 'PLUGIN_SLUG_SAFE', 'PLUGIN_OWNER', 'PLUGIN_REPO', 'PLUGIN_NEW_SHA', 'PLUGIN_TAG', 'GITHUB_TOKEN', 'ZAI_API_KEY']) {
  if (!process.env[v]) { console.error(`Missing required env var: ${v}`); process.exit(1); }
}

const API_URL = 'https://api.z.ai/api/paas/v4/chat/completions';
const MODEL = 'glm-4.7';

// glm-4.7 accepts up to 131072. Billing is on tokens actually produced, so a
// generous ceiling costs nothing; it only has to be high enough that a verdict
// is never truncated. Note `thinking` defaults to enabled on GLM-4.5+, and
// those reasoning tokens count against this budget too.
const MAX_TOKENS = 16384;

// Default is 1.0. A security verdict should be reproducible: the same diff
// should not come back CLEAN one run and WARN the next.
const TEMPERATURE = 0.2;

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

// Chars per tool result. Sized well under the 200k context so a full audit
// fits without pruning; the old 2000 was a workaround for GitHub Models'
// 8000-token request cap and cost the model most of its diff context.
const CHUNK_SIZE = 8000;

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
      description: `Get the unified diff patch for a specific file in this update. Large diffs are returned in chunks of ${CHUNK_SIZE} chars. If the result ends with a "... N chars remaining" note, call again with offset set to the next position to read the next chunk.`,
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
      description: `Get the full content of a file at the new commit. Use for files where a diff alone is not enough context. Large files are returned in chunks of ${CHUNK_SIZE} chars. If the result ends with a "... N chars remaining" note, call again with offset set to the next position.`,
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
    if (data.type === 'dir') return 'Path is a directory, not a file.';

    // The GitHub Contents API does not return content for files >1MB.
    // A large file with no readable diff is likely minified or bundled code
    // copied from an external source and cannot be audited.
    if (!data.content) {
      const kb = data.size ? ` (${Math.round(data.size / 1024)} KB)` : '';
      return `UNREADABLE_LARGE_FILE: ${path}${kb} — file exceeds the GitHub Contents API limit. Content cannot be reviewed; treat as unauditable.`;
    }

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

// ── z.ai GLM API ──────────────────────────────────────────────────────────────

async function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

// `allowTools: false` omits the tool definitions entirely, which forces the
// model to answer in prose instead of requesting more files.
async function callModel(messages, { allowTools = true } = {}) {
  const maxRetries = 10;
  const maxDelay = 600_000; // cap at 10 min
  let delay = 10_000; // start at 10 s; 429s come in bursts at job startup

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    const res = await fetch(API_URL, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${ZAI_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: MODEL,
        messages,
        ...(allowTools ? { tools, tool_choice: 'auto' } : {}),
        max_tokens: MAX_TOKENS,
        temperature: TEMPERATURE,
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
      throw new Error(`z.ai API ${res.status}: ${body.slice(0, 300)}`);
    }

    const data = await res.json();
    const u = data.usage;
    if (u) {
      console.error(`[${PLUGIN_SLUG}]   tokens — prompt: ${u.prompt_tokens}, completion: ${u.completion_tokens}, total: ${u.total_tokens}`);
      totalTokens.prompt     += u.prompt_tokens     ?? 0;
      totalTokens.completion += u.completion_tokens ?? 0;
      totalTokens.total      += u.total_tokens      ?? 0;
    }
    // finish_reason lives on the choice, not on the message inside it.
    const choice = data.choices[0];
    return { message: choice.message, finishReason: choice.finish_reason };
  }

  throw new Error(`z.ai API still rate-limiting after ${maxRetries} retries (max wait ${maxDelay / 60_000}min each)`);
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
- Do NOT use WARN without a specific file+line citation — EXCEPT when a tool returns UNREADABLE_LARGE_FILE: in that case cite the filename and its size as the finding.
- If any changed file returns UNREADABLE_LARGE_FILE, issue **Verdict: WARN** citing that file. Large minified or bundled files copied from an external source cannot be audited and must be treated as suspicious.
- Do NOT tell the user to review the diff themselves — you are the reviewer; give a conclusion.
- Keep the report concise: verdict line, 2–4 sentence summary, findings section if WARN/BLOCK.
- Diffs are returned in ${CHUNK_SIZE}-char chunks; use the offset parameter to page through large files.
- Your turns are limited. Request every file you want in a SINGLE turn — batching many
  get_file_diff calls into one turn is expected; fetching them one at a time will exhaust
  your budget before you reach a verdict.
- Prioritise files that can carry executable behaviour. Tests, documentation, changelogs,
  and lockfiles are low value — skip them unless nothing else is suspicious.`;

async function main() {
  // GLM rejects a conversation that is nothing but a system message
  // (error 1214, "messages parameter is illegal") where gpt-4o accepted one.
  // The system turn defines the role; this user turn starts the work.
  const messages = [
    { role: 'system', content: systemPrompt },
    { role: 'user', content: `Audit the ${PLUGIN_SLUG} update (${rangeDesc}). Start by calling list_changed_files, investigate whatever warrants attention, then give your verdict.` },
  ];

  let finalContent = '';
  // Raised from 10 once pruning was removed: the limit is turns, not context
  // (a large plugin only reached ~21k of the 200k window in 10 turns).
  const maxIterations = 20;

  for (let i = 1; i <= maxIterations; i++) {
    console.error(`[${PLUGIN_SLUG}] iteration ${i}/${maxIterations}...`);

    // On the last turn, withdraw the tools and demand a verdict, so a slow
    // investigation degrades into a real (if less informed) answer rather
    // than the "reached the iteration limit" fallback.
    const finalTurn = i === maxIterations;
    if (finalTurn) {
      console.error(`[${PLUGIN_SLUG}]   final turn — forcing a verdict`);
      messages.push({
        role: 'user',
        content: 'You are out of turns. Do not request any more files. Issue your verdict now based on what you have already examined, and say plainly which parts of the diff you did not get to.',
      });
    }

    const { message: msg, finishReason } = await callModel(messages, { allowTools: !finalTurn });

    if (finishReason === 'length') {
      console.error(`[${PLUGIN_SLUG}]   warning: truncated at max_tokens (${MAX_TOKENS}) — report may be incomplete`);
    }

    const hasToolCalls = !!msg.tool_calls?.length;
    const text = msg.content?.trim() ?? '';

    // GLM intermittently returns an assistant turn with neither content nor
    // tool calls. Treat it as a wasted turn and retry rather than concluding
    // the audit on it; the empty message is not added to the transcript.
    if (!hasToolCalls && !text) {
      console.error(`[${PLUGIN_SLUG}]   empty response — retrying`);
      continue;
    }

    messages.push(msg);

    if (finalTurn || !hasToolCalls) {
      finalContent = text;
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

    // No history pruning: GLM-4.7 carries a 200k context, so the full
    // transcript fits. Keeping every turn also means the message prefix only
    // ever grows, which is what lets z.ai serve repeat context from its
    // prompt cache at a fraction of the uncached input rate.
  }

  // Reachable only if the model returns an empty message — the final turn
  // withholds the tools, so running out of iterations still yields a verdict.
  if (!finalContent) {
    finalContent = '**Verdict: WARN**\n\nThe model returned no verdict text. Manual review recommended.';
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
