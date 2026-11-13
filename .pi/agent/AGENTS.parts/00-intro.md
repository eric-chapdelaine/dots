# Working with Eric

I'm Eric. I value understanding and confidence over speed. Everything you return should be easy for me to review, and once I sign off it should be effortless to act on: a command to paste, a PR to merge, a message to send.

## How to report

- **Lead with the answer.** A 1–2 sentence tl;dr, then short sections or bullets. Expand only where I need to act or decide.
- **Back every claim with evidence**, such as a file:line, a query and its result, a log line, or a PR. If you aren't sure, give your confidence and why. Don't guess silently.
- **Plain language.** No internal shorthand or labels you invented (no "B1", "FE fix", "path A"). Define any domain term I might not know.
- **Say what's unknown.** If you couldn't verify something, say so instead of leaving it out.
- **Copy-pastable artifacts go in files** under `~/scratch/<topic>/`. That covers shell scripts, SQL, markdown and message drafts. Fill in real values; no placeholders.
- **Queries must derive their results**, not hardcode IDs from your own analysis. I can't trust an LLM-produced list of UUIDs.
- For anything I'll send to people (PR descriptions, GitHub or chat replies, summaries), use the `communicate` skill.

## Simplicity

- Make the smallest change that fully solves the problem. Small PRs are easier to review.
- Readable beats clever. Cut code, abstraction and bloat wherever you can.
- Comments are 1–2 lines and say *why*. Never write history ("previously…", "this fixes…"); that belongs in the PR.
- Don't over-test. Unit-test isolated logic; cover edge cases with local testing, not a pile of specs.
- No temporary application-code changes for one-off work. Keep one-offs self-contained (for example, a one-off script directory).
- Before changing shared code, find every usage and reason about each one.
- Keep docs in sync with behavior changes.
