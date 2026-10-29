---
name: review-pr
description: Review a GitHub pull request (someone else's or our own) to understand its behavior change and prove there are no unintended consequences. Supports levels quick, standard (default) and max. Use when asked to review a PR, check whether a PR is correct, or help Eric review one. Never writes to GitHub.
---

# Review a PR

Goal: I understand exactly how behavior changes, and we're confident nothing unintended happens. Never post to GitHub. Propose comment wording for me instead.

## Levels

| Level | Use when | Do |
|---|---|---|
| `quick` | small or low-risk change, or a first pass | Read the PR, description, linked ticket and diff. Report the behavior change and obvious risks. |
| `standard` (default) | most PRs | `quick`, plus trace each changed code path end to end including callers and downstream effects. Compare before and after behavior. Check assumptions against production data shapes (Metabase MCP). Check against repo patterns and prior art. |
| `max` | high-risk, data-mutating, money or patient-blocking, or when I say "rigorous" | `standard`, plus run every branch and code path locally against the local app, with DB states seeded from real production rows. Exercise edge cases and failure paths (retries, nil data, idempotency, concurrency). Use subagents for parallel path coverage. Every claim must be proven by a run, query or log. Fix or flag every bug found. |

## Process

1. `gh pr view` / `gh pr diff`, check out the branch in a worktree, and read the linked ticket (Linear, Zendesk, Roam thread) and the relevant wiki pages.
2. Understand the surrounding code before judging the diff.
3. Answer: does it solve the stated problem? Is it the simplest approach that fits the codebase? What else does it touch?
4. Check tests: are they meaningful and not bloated, and does non-trivial logic have coverage?
5. Read existing review threads. Note which are addressed and which are open.

## Output

```
## <PR title> (#n): <level> review

tl;dr: <1–2 sentences: what changes and whether it's safe>

### Behavior change
<before → after, per flow, in plain language. Mermaid if it helps.>

### How to review this
<the order to read files and the 2–4 spots that deserve the closest look>

### Issues
Sorted by severity (critical / high / medium / low), each with file:line, why it matters,
evidence, and confidence. Put unconfirmed concerns in an "Uncertain" group with what
would need to be true for them to matter.

### Not verified
<anything you couldn't check. If this is non-empty, don't call the PR safe.>

### Suggested comments
<wording for me to post, short and in my voice, per file:line>
```
