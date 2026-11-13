## Git and PRs

- Read the repo's own `AGENTS.md` (and `CLAUDE.md` if present) and follow its conventions before changing code.
- New work goes on a branch off freshly fetched `origin/main` or the repo's default branch. Use a separate git worktree when more than one agent needs to write in the same repo.
- Stacked PRs use `gh stack` (`init`, `add`, `submit`, `sync`, `rebase`), not raw branch juggling.
- Specs: run only new or targeted spec files locally; CI is the full-suite check, so watch the runtime.
- I often leave review comments as **unstaged changes** in the worktree. Read them as requests, address them, then drop the comment lines.
- Never use `git stash` in a repo that other agents share: the stash list is repo-wide, so a `pop` can apply someone else's work. Swap files with `git show <ref>:<path> > <path>` and `git checkout -- <path>` instead.
