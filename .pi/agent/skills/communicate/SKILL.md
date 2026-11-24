---
name: communicate
description: Explain a concept, flow, root cause or change at a high level in plain language, and draft anything Eric will send to others (PR descriptions, GitHub replies, team summaries, docs sections, customer comms). Use whenever the output is for understanding or for another person to read.
---

# Communicate

The audience is me trying to understand something, or the people I'll forward it to: engineers, Ops, support, PMs. Write so it can be read once and understood.

## Rules

- **tl;dr first:** 1–2 sentences that answer the question or name the problem.
- **Plain language:** no method names, file paths, class names or internal codes unless the reader is an engineer and needs them. Describe what happens ("the invoice is never sent to the customer"), not how the code does it.
- **Customer-facing impact before mechanism.**
- **Short:** short sections, bullets or numbered lists when there are parallel items. Cut anything the reader doesn't need to act or decide.
- **Numbers carry the weight:** counts, dollar amounts, date ranges. Say how each was measured.
- **Confidence:** mark anything unconfirmed ("most likely", "unconfirmed") and say what would confirm it.
- **Keep my voice.** When I give you a draft, keep its structure and wording and fix only what's wrong or unclear. Tell me what you changed and why.

## Writing style

- **Plain sentences.** No filler or hedging openers ("It is worth noting", "Based on the analysis"), no restating the question in the answer, no throat-clearing.
- **No leading phrases on bullets.** Don't start a bullet with a bolded or label-style lead ("**Stale care actions waited months.** ...", "Near miss: ..."). Write the bullet as a plain sentence that starts with its content.
- **It must not read as LLM-written.** Write like an engineer who was in the room:
  - No em dashes, no "not X but Y" or "X, not Y" constructions, no rule-of-three lists, no "This ensures / enables / highlights", no "key", "critical", "robust", "comprehensive", "leverage", "notably", "importantly", "in order to", "ultimately".
  - No dramatic or summarizing closers ("Together, these meant...", "In short..."). End a paragraph when the facts end.
  - No quote marks around ordinary words for emphasis, and no parenthetical glosses after every term. Explain a term once, only if the reader needs it.
  - Vary sentence length. Short and flat is fine. Use "we" and plain verbs (got, hit, ran, sent, closed). A slightly blunt sentence beats a polished one.
  - Don't give every section or bullet the same shape.

## Shapes I use

**Problem explanation / root cause:**
```
<1–2 sentence description of the problem and its impact>

<1 short paragraph on why it happened>

Short term fix: <what unblocks the affected cases now>
Long term fix: <what stops it from happening again>
```

**Team update / executive summary:**
```
Summary: <1 short paragraph>

Impact:
- <group>: <count> — <what it means for them> — <proposed action>

Next steps:
1. ...
```

**GitHub or chat reply (I send it, not you):** 1–3 sentences, casual and direct, lowercase is fine. State the answer or the change, with a link if useful. Example: "Fixed in new commit: a checked-out next fill now always takes priority, and added specs for it."

## Format notes

- **Docs (wiki, markdown files):** standard markdown, tables allowed. Mermaid in a ```mermaid block with simple node labels (no `<br/>` or special characters; they break some renderers). Save to `~/scratch/<topic>/` so I can paste it.
- **Customer comms:** match existing macros and comms. Find precedent before inventing wording, and ask me where that precedent lives.
