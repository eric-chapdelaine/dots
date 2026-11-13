---
name: create-pr
description: Implement, verify and open a pull request (single or stacked) with a minimal diff, focused tests, local end-to-end verification, and a high-level description that follows the repo's PR template. Use when asked to make, fix up, or describe a PR.
---

# Create a PR

## 1. Set up

- `git fetch origin`, then create a branch off the repo's default branch. Use a worktree when more than one agent needs to write in the same repo.
- Read the repo `AGENTS.md` (and `CLAUDE.md` if present) before changing code.
- For a stack, use `gh stack init` / `gh stack add`, and `gh stack submit` to open or update the PRs.

## 2. Build it

- Make the smallest diff that fully solves the problem. Follow existing patterns; find the closest prior art and match it.
- Before changing shared code, find every caller and check each one.
- Comments are 1–2 lines and say why. No history narration.
- Update any docs the change makes stale.

## 3. Verify it

1. **Unit tests** for isolated logic only. Don't turn the spec suite into an edge-case catalog. Config-only changes (CODEOWNERS, copy) usually need no test.
2. **Local end-to-end** for behavior and edge cases, run from the real entrypoint, with real data shapes. See "Verify by running it" in AGENTS.md. Stubs in specs must return what the real call returns.
3. **Infra changes (CDK, Terraform, Lambda, Docker):** run the stack's tests and a synth/plan, and run the container image locally on the target architecture.
4. **Specs:** run only new or targeted spec files, and only if they're quick. CI runs the full suite.
5. **Review:** run the `review-pr` skill at `standard` (or the level I ask for) against your own diff, and fix what it finds.

## 4. Describe it

Use the repo's PR template. Keep every section. Write per the `communicate` skill: a bird's-eye view for a reviewer who can read the code for specifics.

- **Problem:** what breaks or is missing, for whom, and how we know (ticket or thread link, sizing).
- **Solution:** the high-level behavior change in a few bullets. A mermaid diagram if a flow is easier to see than read.
  - **Callouts:** important implications, decisions with the reason why, risks, deploy or ordering requirements, and what's deliberately out of scope.
- **Risk / Feature Flag:** the repo's own boxes, each with a one-line reason.
- **Testing:** what you verified and how (local scenarios, real-data checks, specs added). Say plainly what wasn't tested and propose a staging check for me to approve.
- **Monitoring:** how we'll know it works after deploy.

Leave out file tables, commit timelines, "addressed review comments" logs and implementation detail that belongs in code.

When updating an existing description: `gh pr view <n> --json body` first, edit from that current text, and change only what's wrong or stale.

## 5. Hand off

Report the PR link, the tl;dr of the change, what was verified, and open questions. Offer `babysit-pr` if CI is still running.
