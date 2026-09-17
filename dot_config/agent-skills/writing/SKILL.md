---
name: technical-docs
description: Write and review concise technical documentation using a plain-English voice guide and anti-trope filter. Use for READMEs, design notes, runbooks, API documentation, release notes, and pull-request text.
distribution: repository
---

# Technical documentation

Use this skill for documentation, README files, design notes, pull-request text and user-facing prose.

## Aim

Write concise, factual English for a technically informed reader. Follow *The Economist* style guide unless an external standard requires another form.

Lead with the fact. Use concrete nouns, active verbs and exact numbers. Prefer a short familiar word when it is equally precise. Stop when the necessary facts end.

## Voice

- Write as one expert explaining the facts to another.
- State what happened, what the system does, what failed and what remains unknown.
- Ground claims in code, commands, measurements, dates or named evidence.
- Use British spelling where either spelling is valid.
- Vary sentence length, but keep each sentence easy to parse.
- Use humour or opinion only when the document calls for it. Keep contracts and runbooks literal.
- Admit uncertainty directly: “The SDK does not expose this field” or “This has not been tested.”

## Structure

- Put the main fact in the first sentence.
- Use headings that name the subject or task.
- Do not use `Overview`, `Introduction`, `Conclusion` or `Summary` unless the document type requires one.
- Keep one idea per paragraph, but avoid strings of one-line fragments.
- Use lists for comparison, inventory or steps. Keep items parallel.
- Do not start every bullet with bold text.
- Link to the source of a detailed claim instead of copying it.
- Preserve exact commands, identifiers, paths, schema fields and error text.

## Words

Prefer:

- `use` over `utilise` or `leverage`;
- `is` over `serves as`;
- `before` over `prior to`;
- `about` over `approximately` unless precision matters;
- `can call other agents` over `has orchestration reach`;
- `security` or the named control over `security posture`;
- the direct fact over `it is worth noting that`.

Keep a technical term only when it names an exact API, schema, protocol, resource or control. Define uncommon abbreviations once.

## Banned rhetorical patterns

Rewrite these rather than using them for emphasis.

### Manufactured contrast

Do not write:

- `It is not X; it is Y.`
- `This is not X, but Y.`
- `It is X, not Y.`
- `This is X rather than Y.` when two direct sentences are clearer;
- `Not X. Not Y. Just Z.`
- `not because X, but because Y` unless the contrast is essential evidence.

State the fact once. For example:

- Avoid: `Search is not canonical; Blob is canonical.`
- Write: `Blob is the source of record. Search can be rebuilt.`

### Sincerity claims

Do not write:

- `honestly`, `to be honest`, `if I am honest`;
- `the honest truth`, `truth be told`, `the simple truth`;
- `in all honesty`.

Evidence and specificity establish credibility.

### Rhetorical questions

Do not ask and answer your own question:

- `The result? Failure.`
- `Why does this matter? Because...`
- `Would we deploy it? No.`

Write the answer as a statement.

### False suspense and revelation

Do not use:

- `Here is the thing`;
- `Here is the kicker`;
- `Here is where it gets interesting`;
- `What most people miss is`;
- `turned out to be` as a repeated reveal device.

State the event or result.

### Meta-commentary and editorial signposts

Write about the subject, not about the writing. Remove commentary about what a document claims, shows, proves, covers, makes clear, implies, should be read as or must avoid suggesting. State the fact where it applies.

Keep navigation only when it helps the reader choose a source, such as `This page defines the HTTP contract.`

Do not tell the reader which statement is the main point, key distinction, important caveat or claim to avoid.

Avoid:

- `The main claim to avoid is...`;
- `The key point is...`;
- `The important distinction is...`;
- `The main takeaway is...`;
- `What matters is...`;
- `Documentation must not claim...` when the direct fact is known;
- `Do not claim that...`;
- `We do not claim...`;
- `This document shows that...`;
- `This should not be read as...`;
- `This does not imply...`;
- `It is important to distinguish...`;
- `For the avoidance of doubt...`;
- `The documentation deliberately...`.

Example:

- Avoid: `The main missing claim to avoid is Log Analytics diagnostic success: that remains blocked, not complete.`
- Write: `The active identity lacks the permissions required for Log Analytics diagnostics.`

### Filler transitions

Remove:

- `That said`;
- `For context` and `For reference` when the next sentence already supplies it;
- `Importantly`, `Interestingly`, `Notably`;
- `It is worth noting`, `It bears mentioning`;
- `In order to`;
- `So` at the start of a sentence when it adds no meaning.

### Authority and status noun stacks

Avoid phrases that pile document status, authority and scope into one label. Use the document's purpose or state the fact.

Avoid:

- `authoritative production contracts`;
- `normative contract owner`;
- `documentation home`;
- `support status`;
- `A2A support`;
- `related documents`.

Prefer:

- `agent contracts`;
- `this file defines...`;
- `current state`;
- `supported` or `unsupported`;
- the direct link or fact.

Keep `canonical` only when it names a real data invariant, such as the source-of-record Blob document. Keep `normative` only when distinguishing a requirement from an example is necessary.

### Passive status language

Avoid project-management phrases that hide the actor or cause:

- `remains deferred`;
- `remains blocked`;
- `remains pending`;
- `continues to be`;
- `is currently planned`;
- `has been deferred`.

State the present fact and cause:

- Avoid: `Native connected-agent attachment remains deferred.`
- Write: `Foundry definitions do not attach agents because the installed SDK lacks named-agent authentication.`
- Avoid: `Log Analytics diagnostics remain blocked.`
- Write: `The active identity lacks the workspace permissions required for Log Analytics diagnostics.`

### Inflated language

Avoid unsupported words such as:

- `seamless`, `robust`, `powerful`, `holistic`, `comprehensive`;
- `transformative`, `enterprise-grade`, `best-in-class`, `state-of-the-art`;
- `quietly`, `deeply`, `fundamentally`, `remarkably` used to create importance;
- `landscape`, `tapestry`, `paradigm`, `synergy`, `ecosystem` used as decoration;
- `delve`, `unlock`, `elevate`, `revolutionise`.

Keep `harness` when it names a real test harness, runtime harness or SDK component. Otherwise name the mechanism or measurement instead.

### Stock teaching devices

Do not use:

- `Let us break this down`, `unpack`, `dive in` or `explore` as framing;
- `Think of it as...` analogies when the literal explanation is clearer;
- `Imagine a world where...`;
- listicles disguised as prose (`The first... The second... The third...`).

Assume the reader can follow a direct explanation.

### Artificial rhythm

Avoid:

- repeated sentence openings;
- repeated groups of three;
- strings of gerund fragments (`Testing. Shipping. Learning.`);
- one-sentence paragraphs used for drama;
- repeated keywords within a paragraph unless the repetition is deliberate.

### Empty analysis

Cut trailing phrases such as:

- `highlighting its importance`;
- `reflecting broader trends`;
- `underscoring its role`;
- `contributing to the wider landscape`.

Explain the consequence or stop the sentence.

### Invented labels and vague sources

- Do not coin labels such as `the governance paradox` to replace an argument.
- Do not cite `experts`, `industry reports` or `observers` without naming the source.
- Do not invent quantities, intent, causes, quotations or consensus.

### Repetition and endings

- Do not preview, repeat and summarise the same point.
- Do not repeat a conclusion at the end of each section.
- Do not write `In conclusion`, `To sum up` or `In summary`.
- Do not add optimism after reporting a problem.
- End after the last useful fact, instruction or link.

## Technical prose

- Describe model output as a classification, proposal or generated response.
- Name the code that validates, authorises or writes data.
- Replace anthropomorphic verbs such as `knows`, `thinks`, `understands` and `remembers` with the operation performed.
- State whether a control uses application filtering, Azure role-based access control, network isolation, storage isolation or cryptography.
- Put scope next to a claim: `verified for version 11 on 16 July 2026`.
- Distinguish `implemented`, `tested`, `live-verified`, `accepted`, `planned`, `blocked` and `unsupported`.
- State failures directly. Do not soften them with phrases such as `an area for improvement`.

## Review

Before publishing, check that:

- the first sentence contains the main fact;
- every sentence adds information;
- ordinary words replace avoidable jargon;
- no banned rhetorical pattern remains;
- claims cite code, evidence or an exact contract;
- facts and limits have not been lost while cutting words;
- commands, links, identifiers and quoted errors remain exact;
- the document ends without a repeated summary.
