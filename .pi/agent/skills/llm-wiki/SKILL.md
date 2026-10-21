---
name: llm-wiki
description: Persistent, compounding personal knowledge wiki at ~/wiki/wiki (issues, projects, codebase, entities, concepts, decisions) searched with qmd. Use at the start of any session and whenever investigating a bug, planning a project, recording architecture knowledge, ingesting a source from ~/wiki/raw, or linting the wiki.
---

# Skill: llm-wiki

## Purpose

The wiki is a persistent, compounding knowledge base at `~/wiki/wiki/`. It accumulates knowledge across sessions — investigations, codebase architecture, domain concepts, entity quirks, past decisions. Every session should leave the wiki richer than it found it.

**Read the schema first**: `~/wiki/schema.md` — it defines page types, templates, operations, and conventions.

---

## Wiki Location

```
~/wiki/
  raw/        ← Immutable sources (you drop files here)
  wiki/       ← LLM-owned pages
    index.md  ← Master catalog (start here)
    log.md    ← Append-only activity record
    issues/   ← Bugs, incidents, errors
    projects/ ← Features, refactors, multi-session work
    codebase/ ← Persistent architecture knowledge
    entities/ ← Third-party services, internal services, teams
    concepts/ ← Domain knowledge, workflows, business rules
    decisions/← Architecture decisions and rejected alternatives
  schema.md   ← Full wiki conventions and workflows
```

---

## Starting Any Session

1. Check `~/wiki/wiki/index.md` for relevant existing pages.
2. Use qmd to search: `qmd query "<topic>" -c wiki` (or the qmd MCP tool).
3. Read relevant pages. Resume from their current state — do not re-derive.

---

## Searching

qmd is installed at `~/.nvm/versions/node/v24.13.1/bin/qmd`.

```bash
# Hybrid search (best)
~/.nvm/versions/node/v24.13.1/bin/qmd query "DoseSpot pharmacy pricing" -c wiki

# Keyword search (fast)
~/.nvm/versions/node/v24.13.1/bin/qmd search "lucy rx" -c wiki

# Get a specific page
~/.nvm/versions/node/v24.13.1/bin/qmd get "wiki/issues/lucy-rx-bugs.md"
```

Or use the `qmd` MCP tool directly (tools: `query`, `get`, `multi_get`, `status`).

---

## The Three Operations

### Maintain (most common — during investigations and projects)

When working on a bug or feature:

1. **Before any code**: Find or create the relevant `issues/` or `projects/` page.
2. **Immediately after any new finding**: Update the page. Update the top summary and `updated` frontmatter.
3. **When a finding reveals persistent codebase knowledge**: Write a `codebase/`, `concept/`, or `entity/` page for it. Don't bury architecture knowledge inside a single issue doc.
4. **When done**: Set `status: resolved` or `status: done`. Update `index.md`.
5. **Append to log.md**: `| YYYY-MM-DD | maintain | <title> | <what changed> |`

### Ingest (when user drops a source into ~/wiki/raw/)

1. Read the source.
2. Discuss key takeaways.
3. Write summary/analysis in the appropriate `wiki/` subdirectory.
4. Update entity, concept, and codebase pages the source touches.
5. Update `index.md`. Append to `log.md`.

### Lint (when wiki feels stale or user asks)

Check for: resolved issues still marked active, orphan pages, contradictions, mentioned concepts lacking their own page, missing `related` links.

---

## Creating Pages

- Follow the templates in `~/wiki/schema.md`.
- Always include frontmatter (`title`, `type`, `status`, `updated`, `tags`, `related`).
- Update `index.md` immediately.
- Append to `log.md`.
- Prefer smaller, focused pages over monolithic ones. Cross-link via `related`.

---

## Rules

1. **One page per focused concept** — split, don't combine.
2. **Update status + summary on every pass** — top summary and `updated` frontmatter.
3. **File insights back** — good answers become pages. Don't let knowledge disappear into chat.
4. **Always record file paths with line numbers** when known.
5. **Never delete content** — mark superseded or resolved.
6. **index.md is the source of truth** for what exists. Keep it current.
7. **log.md is append-only**. Grep for context: `grep "^|" ~/wiki/wiki/log.md | tail -20`
8. **Write for engineers** — facts, paths, data flows. No meta-commentary.
