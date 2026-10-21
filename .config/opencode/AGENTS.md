# Personal Coding Agent Guide

## Repos

| Repo | Path | Stack | Default branch |
|---|---|---|---|


---

## Rules

- **Privacy/security first.** Never leak PHI externally.
- **Minimal changes.** Search all usages before changing shared code.
- **Ask before going down the wrong path.**
- **Comments: explain why, not what.**
- **Start fresh sessions for new tasks** rather than continuing long ones.
- **Don't run specs or tests unless explicitly asked.** Make the change, describe what to verify, stop.
- **If a tool or query fails twice, stop and report** — don't retry autonomously.

---

## Wiki

Persistent knowledge base at `~/wiki/wiki/`. Load the `llm-wiki` skill for any investigation, project, or knowledge question. The wiki accumulates knowledge across sessions — check it before re-deriving anything.

- **Index**: `~/wiki/wiki/index.md`
- **Search**: `qmd` MCP tool, or `~/.nvm/versions/node/v24.13.1/bin/qmd query "<question>" -c wiki`
- **Schema**: `~/wiki/schema.md`

## Skills

Load a skill when a task matches it. Use `ctrl+p` → skills to browse, or ask to load one by name.

Available: `llm-wiki`, `personal-coding-agent`, `repo-context`, `run-repos-locally`, `local-fullstack-testing`, `git-worktree-setup`, `pr-descriptions`, `nvim-mcp`, `create-pr`, `review-pr`, `workflow-storybook-testing`, `write-discovery`, `macos-window-control`

---

## Debugging Order

1. Read the code first.
2. Logs and metrics.
3. Database — only if logs weren't enough.
