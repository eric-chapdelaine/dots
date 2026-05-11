---
name: write-discovery
description: Write a technical discovery document for a new feature or workflow change — given a Figma design, WIP discovery, product spec, or description, produces a structured discovery covering all repo changes, dependencies, edge cases, open questions, and risks.
---

## What I do

Given any combination of: a Figma link, a WIP discovery document, a product spec, or a plain description of the change:

1. Deeply understand the ask — read the Figma, product spec, and any WIP discovery in full
2. Research the relevant codebases to understand what already exists and what patterns to follow
3. Identify all dependencies, gaps, and risks — this is the most important part
4. Write the discovery document in the standard format, scoped to high-level changes only

The output is a comprehensive discovery document written to a markdown file. The most valuable parts are the open items table, the dependency/sequencing analysis, edge cases, and open questions for PM/Design — not a line-by-line implementation guide.

---

## Inputs

The user will provide some combination of:
- **Figma link** — one or more screens or flow diagrams
- **WIP discovery** — a partially written `.md` file to build on or reformat
- **Product spec** — a Google Doc or internal document link
- **Description** — a plain-English description of the change

Always use whatever is provided. If a WIP discovery exists, use it as a starting point and expand it significantly.

---

## Step-by-step process

### 1. Read all provided inputs

- **Figma:** Use `figma_get_design_context` on provided node IDs. If a URL is given, extract the node ID. If the initial node is just one frame, use `figma_get_metadata` to discover neighboring nodes, then screenshot relevant frames to understand the full flow. Do not stop after one frame — trace the full user journey.
- **Product spec:** Use `glean_default_read_document` on the URL, then use the Task tool to summarize the relevant sections.
- **WIP discovery:** Read the file in full. Identify what's already captured vs. what's missing. Note the open items table — these are things the author already flagged as unresolved.
- **Description:** Extract the core ask, the actors involved, and the business outcome.

### 2. Research the codebase

This step is the core of good discovery work. Do it thoroughly.

**For every repo touched by the change:**

- **Identify the closest analogue** — find an existing similar flow and read it end-to-end. For workflow changes: read the full workflow config (root JSON + all nodes), all DSE node resolvers, all GraphQL queries, and the UDL resolvers. This tells you exactly what pattern to follow.
- **Search for the relevant GraphQL schema fields** — confirm which fields exist and which need to be created. Use the Task/explore agent to grep the UDL `.graphqls` files.
- **Check what does NOT exist** — enumerate the schema fields, mutations, and endpoints that would be needed but aren't there. These become dependencies.
- **Look at how similar flows are wired together** — check workflow links, `select-*-action` routing nodes, feature flag gating, ARA permission checks, Unleash flags, and how the `flowTypeId` / Scribe enum is defined.
- **Check git history for similar work** — use `git log --oneline --all | grep <keyword>` or `gh` CLI to find PRs where similar changes were made. Use those as implementation references.
- **Use Glean** to look up team ownership, internal docs, or prior incident context for unfamiliar systems (OX, F&L, ARA, etc.).

**Specifically check for:**
- Missing UDL schema fields / mutations
- Missing OX or external API endpoints
- New Scribe `flowTypeId` / `JourneyFlowType` enum values needed
- New ARA permissions needed
- Unleash flags needed for rollout
- New frontend component types or library changes needed
- Cross-repo changes that might be blocked on another team
- Existing mock stubs that would need to be added for local development

### 3. Ask questions before writing if needed

If the scope is ambiguous in ways that would materially change the document, ask the user before proceeding:
- Is this for WFE or the Workflow Platform? (They are different systems)
- Is this agent-only or does it also have a storefront path?
- Is there a specific output file path to write to?
- Are there any known constraints from PM or another team?

Do not ask about things you can determine from reading the code or inputs.

### 4. Write the discovery document

Write to a `.md` file. If the user provided a WIP file path, overwrite it. Otherwise, choose a sensible path (e.g. `~/Downloads/[Discovery] <Feature Name>.md`).

Follow the output format below. Calibrate the level of detail: **high-level only**. Engineers reading this are senior and will make their own low-level implementation decisions. The document's job is to:
- Map every repo and subsystem that needs to change
- Identify what doesn't exist yet (the blockers)
- Surface dependencies and their ordering
- Flag edge cases and risks
- Ask the questions only PM/Design/external teams can answer

Do **not** write code snippets unless they are essential for illustrating a structural question (e.g. a new GraphQL type shape). Do **not** narrate implementation details that follow trivially from existing patterns.

---

## Output format

```markdown
Spec: [<Title>](<URL>)        ← if a product spec was provided

**High level ask:** <1–2 sentence plain-English summary of the feature.>

**Figma:** <URL>              ← if Figma was provided

| `Tech Discovery Open Items` |  |
| :---- | ----- |
| `[<Team/System>] <Unresolved question or dependency that cannot proceed without external input>` | |
| ... | |

# Overview

<2–4 sentences on the broader context: what system this fits into, what pattern it follows, any important architectural decisions (e.g. "this is scoped to the Workflow Platform, not WFE").>

# Flow Overview

<ASCII diagram or short bullet list tracing the happy path through the workflow graph.>

# <Repo Name> Changes

## `[<Repo>]` <Ticket-level unit of work> — <S/M/L/XL> pts

<2–4 sentences describing what needs to change and why, at a high level. Note the pattern to follow if one exists.>

**Key decisions / open items for this ticket:**
- <anything unresolved that the implementing engineer must decide or confirm>

... (repeat per repo, per logical unit of work)

# Dependencies & Sequencing

| Dependency | Owner | Blocks |
|---|---|---|
| <what is needed> | <team> | <what it blocks> |

# Edge Cases & Risk Areas

| Edge Case | Handling |
|---|---|
| <scenario> | <how the flow handles it, or "open item" if unresolved> |

# Scribe Logging

<Note the flowTypeId / JourneyFlowType enum value needed and which node fires the SUBMIT event. If Scribe tables are relevant for monitoring, call them out.>

# Open Questions for PM / Design

<Numbered list of questions that only PM, Design, or an external team can answer. These are not implementation questions — they are scope/UX/business questions.>
```

---

## Tone and calibration rules

- **High-level only.** A good entry is "Add a new `canConvertStoreCreditToOpm` eligibility field to UDL (backed by OX API — pending OX contract)." A bad entry is a fully specified GraphQL type definition with all fields enumerated.
- **Dependencies and open items are more valuable than implementation detail.** If you're unsure whether to include something, ask: "Would a senior engineer need to know this before they start, or will they figure it out themselves?"
- **The open items table is the most important section.** Every item in it should be something that genuinely cannot be determined from the codebase — it requires input from another team, another person, or a product decision.
- **Be concrete about what doesn't exist.** "This GraphQL field does not exist in the UDL schema" is far more useful than "we may need a new field."
- **Reference existing patterns by name and path.** "Follow the pattern of `manage-financial-apply-rewards`" gives an engineer a starting point without over-specifying.
- **No bullet soup.** Prose is better than exhaustive nested lists. Favor a clear sentence over three bullet points that say the same thing.

---

## Tool usage guidance

| Tool | When to use |
|---|---|
| `figma_get_design_context` | Primary tool for reading Figma — use on every node ID found |
| `figma_get_metadata` | Use to discover neighboring node IDs when you only have one frame |
| `figma_get_screenshot` | Use to visually inspect screens when design context is insufficient |
| `glean_default_read_document` | Read Google Docs / product specs |
| `glean_default_search` | Look up team ownership, internal docs, prior incidents, company context |
| `glean_default_chat` | Synthesize answers from multiple Glean sources for complex questions |
| Task tool (explore agent) | Search repo for existing patterns, schema fields, file structures |
| Task tool (general agent) | Parallelize heavy research across multiple repos |
| `bash` with `git log` / `gh` | Find PRs where similar work was done; understand what has shipped |
| `bigquery_execute_sql` | If production data is needed to understand edge cases or volume |
| `read` | Read specific known files once you have paths |

Run Figma, Glean, and codebase research in parallel where possible. The research phase should be thorough before writing begins.

---

## Critical rules

- **Never write implementation details that belong to the engineer.** If you find yourself specifying MVEL expressions, exact SQL queries, or method signatures, step back — those are implementation decisions.
- **Always check what does NOT exist before writing.** The most common mistake in discovery is assuming a needed API, field, or service already exists. Grep the schemas, read the configs.
- **Always check whether this is WFE or Workflow Platform scope.** These are different systems and the wrong answer invalidates the entire document. Check `agent-context/workflow-platform.md` and the current workflow config directories.
- **Identify the closest existing analogue in the codebase** and call it out explicitly. This is the single most useful reference an implementing engineer gets from a discovery.
- **Surface all cross-team dependencies** — OX, F&L, ARA, Unleash, Scribe, external APIs. Each one is a potential blocker and deserves its own open item.
- **Ask the product questions.** Ambiguities in Figma or spec about scope, granularity, or edge case handling should be called out explicitly as questions for PM/Design — not silently assumed.
