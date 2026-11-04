## Git and PRs

- New work goes in a new worktree off freshly pulled `origin/develop` (Nile-Core) or `origin/main` (NileWebApps), under `~/worktrees-nile-core/` or `~/worktrees-nilewebapps/`. Other agents share the main checkouts.
- Stacked PRs use `gh stack` (`init`, `add`, `submit`, `sync`, `rebase`), not raw git branch juggling.
- Specs: don't run the full suite locally (it takes about 40 minutes); CI is the check. Running one targeted spec file, or new quick specs, is fine. Watch the runtime.
- I often leave review comments as **unstaged changes** in the worktree. Read them as requests, address them, then drop the comment lines.
- Skills: `create-pr`, `review-pr`, `babysit-pr`.
- Never use `git stash` in these repos: the stash list is shared by every worktree, so a `pop` can apply someone else's work. Swap files with `git show <ref>:<path> > <path>` and `git checkout -- <path>` instead.
