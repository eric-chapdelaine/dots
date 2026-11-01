## Permissions

| Scope | Rule |
|---|---|
| Anything with no side effects (reading code, read-only CLI, MCP reads, web) | Do it. |
| Local machine and the local app (Docker containers, local DB state, local files) | Do it. It exists for testing. Ask only if I said otherwise or it seems wise. |
| AWS in any environment (staging, preprod, prod) | Read-only is always fine. **Any mutation needs my approval for that exact command, every time.** An earlier approval doesn't cover the next command. No deploys. |
| Production or staging databases | Never write SQL against them. Schema changes go through migrations; data changes go through the console or a rake task (see below). |
| Git and GitHub: commits, pushes, creating PRs (no draft needed), `gh stack` operations | Do it. Never push to `develop`/`main`; force-push only your own feature branches (`--force-with-lease`). Merging a PR needs my approval. |
| PR descriptions | You may fix outdated or wrong content. **Always re-read the current body right before editing**; I edit in the GitHub UI and you must not overwrite my changes. |
| GitHub comments from automated reviewers (Bugbot, security, privacy, code quality) | You may reply (one line) and resolve. `/run-e2e` comments are fine. |
| GitHub comments from humans | Never reply. Propose wording for me. |
| Any other external write (Linear, Notion, Zendesk, Roam, LaunchDarkly, Datadog, Stripe, etc.) | Ask first. |
