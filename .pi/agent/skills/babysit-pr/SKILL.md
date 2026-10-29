---
name: babysit-pr
description: Autonomously drive a GitHub PR to all-green CI by polling checks, retrying unrelated flakes, fixing related failures, and handling automated reviewer comments (Bugbot, security, privacy, code quality). Stops for human review comments. Use when asked to babysit, watch or get a PR merge-ready.
---

# Babysit a PR

Run without stopping for questions. The only stop points are listed below.

## Loop

1. **Poll** `gh pr checks <n>` and the review threads (GraphQL `reviewThreads`). Space polls to match how long CI usually takes; compare against recent PRs.
2. **Failing check:**
   - Read the logs (Semaphore for Nile-Core, GitHub Actions / Currents MCP for NileWebApps e2e).
   - Not caused by this PR (a flake, or broken on `develop`/`main` too): re-run it. If it fails the same way twice, check whether it's a known or recurring flake and note it in the report.
   - Caused by this PR: make the minimal fix, commit, push, and poll again.
3. **New automated reviewer comment** (Cursor Bugbot, Cursor security or privacy automations, GitHub code quality):
   - Assess whether it's valid, against the code and production data where relevant.
   - Valid: fix it, push, reply with one line ("Fixed in `<sha>`: <what changed>"), and resolve the thread.
   - Not valid: reply with one line explaining why ("we have a BAA with Datadog"), and resolve it.
4. **NileWebApps:** after every push, comment `/run-e2e`. The merge gate is `e2e-gate`; `@soak` failures don't block.
5. Repeat until every required check is green and no automated threads are unresolved.

## Stop and hand back to me when

- **A human leaves a review comment.** Don't reply and don't change code. Propose the fix (via `review-pr` / `create-pr` reasoning) and the reply wording (via `communicate`), then wait for approval. Once I approve, make the change, push, and resume the loop.
- A fix needs a product or design decision, or would grow the PR's scope.
- The failure is in shared infrastructure outside the PR (CI quota, deploy pipeline).

## Report

When everything is green, or at a stop point, report: final check status, what failed and how it was handled (retried / fixed in `<sha>`), automated comments addressed, and anything waiting on me.
