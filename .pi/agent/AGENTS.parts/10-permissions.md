## Permissions

| Scope | Rule |
|---|---|
| Anything with no side effects (reading code, read-only CLI, MCP reads, web) | Do it. |
| Local machine and the local app (Docker containers, local DB state, local files) | Do it. It exists for testing. Ask only if I said otherwise or it seems wise. |
| Any cloud account | Read-only is always fine. **Any mutation needs my approval for that exact command, every time.** An earlier approval doesn't cover the next command. No deploys. |
| Production or staging databases | Never write SQL against them. Schema changes go through migrations; data changes go through a reviewed console script or a one-off task. |
| Git and GitHub: commits, pushes, creating PRs (no draft needed), `gh stack` operations | Do it. Never push to someone else's `main`/`develop`; force-push only your own branches (`--force-with-lease`). Merging a PR needs my approval. |
| PR descriptions | You may fix outdated or wrong content. **Always re-read the current body right before editing**; I edit in the GitHub UI and you must not overwrite my changes. |
| GitHub comments from automated reviewers (Bugbot, security, privacy, code quality) | You may reply (one line) and resolve. |
| GitHub comments from humans | Never reply. Propose wording for me. |
| Any other external write (issue tracker, docs, chat, feature flags, monitoring, billing, email, CRM) | Ask first. |
