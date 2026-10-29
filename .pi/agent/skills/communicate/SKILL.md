---
name: communicate
description: Explain a concept, flow, root cause or change at a high level in plain language, and draft anything Eric will send to others (PR descriptions, GitHub/Roam replies, team summaries, Notion sections, customer comms). Use whenever the output is for understanding or for another person to read.
---

# Communicate

The audience is me trying to understand something, or the people I'll forward it to: engineers, Ops, clinicians, PMs. Write so it can be read once and understood.

## Rules

- **tl;dr first:** 1–2 sentences that answer the question or name the problem.
- **Plain language:** no method names, file paths, class names or internal codes unless the reader is an engineer and needs them. Describe what happens ("the order is never sent to the pharmacy"), not how the code does it.
- **Customer-facing impact before mechanism.**
- **Short:** short sections, bullets or numbered lists when there are parallel items. Cut anything the reader doesn't need to act or decide.
- **Numbers carry the weight:** counts, dollar amounts, date ranges. Say how each was measured.
- **Confidence:** mark anything unconfirmed ("most likely", "unconfirmed") and say what would confirm it.
- **Keep my voice.** When I give you a draft, keep its structure and wording and fix only what's wrong or unclear. Tell me what you changed and why.

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

**GitHub or Roam reply (I send it, not you):** 1–3 sentences, casual and direct, lowercase is fine. State the answer or the change, with a link if useful. Example: "Fixed in new commit: a checked-out next fill now always takes priority, and added specs for it."

## Format notes

- **Notion:** standard markdown, tables allowed. Mermaid in a ```mermaid block with simple node labels (no `<br/>` or special characters; they break Notion's renderer). Save to `~/scratch/<topic>/` so I can paste it.
- **Customer comms:** match existing macros and comms. Search Metabase (Zendesk data) or the Roam MCP for precedent.
