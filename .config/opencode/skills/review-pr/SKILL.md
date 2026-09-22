---
name: review-pr
description: Review a GitHub pull request end-to-end — reads the PR and relevant repo context, then produces a structured review categorized by severity and confidence. Never writes to GitHub.
---

## What I do

Given a GitHub PR URL:

1. Read the PR fully — title, description, all changed files, and all inline diff hunks
2. Understand the broader repo context — what the repo does, what patterns it follows, and how the changed files fit in
3. Determine whether the PR accomplishes what its description claims
4. Evaluate whether the approach is the best available solution given the codebase
5. Produce a structured written review (printed to the user — never posted to GitHub)

---

## Step-by-step process

### 1. Read the PR

Use the GitHub CLI (`gh`) to fetch:
- PR metadata: title, description, base branch, author, labels
- Full file diff for every changed file
- Any inline comments already on the PR

### 2. Understand repo context

Read enough of the surrounding codebase to understand:
- The architecture and patterns in the changed area
- What the changed files are responsible for
- Whether the change is consistent with how similar problems are solved elsewhere
- Whether any tests exist for the changed code, and if so, whether they are being updated

Do not skip this step. If the changed code is part of a critical subsystem, read the surrounding files to understand the full impact.

### 3. Assess alignment with the stated goal

Answer explicitly:
- Does the PR accomplish what its title and description claim?
- Are there obvious gaps or edge cases the PR does not address?

### 4. Assess solution quality

Answer explicitly:
- Is this the best way to solve the problem given the existing codebase?
- Are there simpler or more idiomatic alternatives?
- Does the change introduce unnecessary complexity?
- Does it follow the repo's established patterns?

---

## Output format

Print the review to the user using this structure. Never post or push anything to GitHub.

```
## PR Review: <title> (#<number>)

**Repo:** <repo>
**Author:** <author>
**Branch:** <head> → <base>

---

### Summary

<2–4 sentence plain-English summary of what the PR does and why.>

### Goal Alignment

<Does the PR accomplish what its description claims? Note any gaps.>

### Solution Assessment

<Is this the best approach? Alternatives considered? Complexity appropriate?>

---

### Issues

Issues are grouped by severity. Within each severity, high-confidence problems are listed before uncertain ones.

#### CRITICAL — Must fix before merge
> High confidence issues that will cause bugs, data loss, security problems, or break existing behavior.

- **[file:line]** Description of the problem and why it matters.

#### HIGH — Should fix before merge
> Confident issues that are meaningfully wrong but not immediately catastrophic.

- **[file:line]** Description.

#### MEDIUM — Worth fixing
> Likely issues or clear code quality problems. Fix if straightforward.

- **[file:line]** Description.

#### LOW — Minor / nitpick
> Style, naming, or minor consistency issues. Fix at your discretion.

- **[file:line]** Description.

#### UNCERTAIN — Possible issues (needs human judgment)
> Things that look suspicious but may be intentional or have context the reviewer lacks.

- **[file:line]** Description of the concern and what would need to be true for this to be a real problem.

---

### Context Gaps

<If there is any part of the PR that you could not fully evaluate due to missing context, state it explicitly here. Do NOT mark the PR as good if you have unresolved context gaps.>

---

### Verdict

**APPROVE / REQUEST CHANGES / NEEDS MORE CONTEXT**

<One paragraph explaining the verdict.>
```

---

## Critical rules

- **Never write to GitHub.** No comments, no reviews, no approvals, no dismissals. Output is printed to the user only.
- **Do not say the PR is good if you have context gaps.** If you could not fully understand what a change does, say so explicitly in "Context Gaps" and set the verdict to "NEEDS MORE CONTEXT".
- **Differentiate confidence levels.** CRITICAL/HIGH/MEDIUM/LOW are issues you are confident about. UNCERTAIN is for things that might be a problem but you are not sure.
- **Read the description.** The PR description often contains critical context, known limitations, or callouts that change the analysis.
- **Check tests.** If the changed code has no test coverage and the change is non-trivial, call it out as at least a MEDIUM issue.
- **Check for follow-on effects.** Consider whether the change affects callers, consumers, or downstream systems beyond the files directly modified.
