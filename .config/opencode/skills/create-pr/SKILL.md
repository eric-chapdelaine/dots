---
name: create-pr
description: Create a GitHub pull request from a description or Jira ticket — pulls main, creates a branch, writes focused commits, and opens a PR matching Eric's style (concise title, minimal description, small scoped commits).
---

## What I do

Given a task description or Jira ticket ID:

1. Understand the ask — read repos to understand context; use Glean if company-specific knowledge is needed
2. Ask clarifying questions if the approach is ambiguous before writing any code
3. Pull latest `main` and create a properly named branch
4. Implement the change in focused, incrementally committed chunks
5. Open a GitHub PR with the correct title and description format

---

## Step-by-step process

### 1. Understand the task

Read the relevant code first. If a Jira ticket ID is provided, use the Jira MCP (or Glean) to read it. If the task touches company-specific systems, teams, or concepts that aren't clear from the repos, use Glean to look them up.

**Ask questions before writing code if:**
- The right repo or file to change is unclear
- There are multiple valid approaches and the tradeoffs matter
- The task could require cross-repo changes (confirm this is actually necessary first)
- The scope of change is ambiguous
- The Jira ticket or description is too high-level and doesn't speak to implementation — in this case, read the relevant code, compile the reasonable implementation options with a brief tradeoff summary for each, and ask the user which to go with. Only skip asking if one option is clearly the right choice given the codebase.

Do not ask questions if the task is straightforward and the right path is clear from reading the code.

### 2. Branch naming

Branch names follow this pattern: `ec825m_<short_snake_case_description>`

- Keep it short (3–5 words max)
- Describe what the change does, not why
- No ticket numbers in the branch name

Examples from real PRs:
- `ec825m_dont_resolve_replay_nodes_always`
- `ec825m_stop_replay_on_unfilled`
- `ec825m_remove_auth_logging_noise`
- `ec825m_allow_new_workflows_handoff`
- `ec825m_add_jira_fallback_for_supplier_transfer_check`

```bash
git checkout main
git pull origin main
git checkout -b ec825m_<description>
```

### 3. Implementation

Follow the Development Philosophy in AGENTS.md:
- Minimize unintended consequences — search all usages before changing shared code
- Prefer the simplest solution — fewest changes possible, avoid cross-repo changes unless necessary
- Comment at a high level only — no narrating what each line does, no boilerplate JSDoc

### 4. Commits

Commit frequently and atomically. Each commit should capture one logical unit of work.

**Commit message style:**
- Headline: 2–6 words, lowercase, no period, describes what changed
- No ticket numbers, no "WIP", no "fix:" prefix conventions
- Body: always populate with a verbose explanation of what was done and why — the reasoning, the tradeoffs, any non-obvious decisions made in this commit

Examples from real PRs:
- `add test`
- `use ticket service instead`
- `add mocks`
- `update comment`
- `don't auth if from s2s`
- `replace "agent" with "user" wording`
- `add new handoff only wizards`
- `formatting`
- `fix storybook`
- `generate` (for regenerated artifacts)
- `undo whitespace change`

Every commit should describe the specific thing it does. Start with the first meaningful unit of work — there is no "initial implementation" catchall. Merge-from-main commits are fine and expected.

```bash
git add <files>
git commit -m "skip node name resolver when cvs has a value" -m "NODE_NAME_VALUE_RESOLVERS previously ran unconditionally for any matching node, even when the CVS already had a recorded answer. This meant does-customer-have-item would re-derive its value from live S2S data instead of trusting what was submitted in the original run, causing replay to potentially take a different WFE graph path. Added a !nodeValue guard so the resolver is skipped when the CVS already has a value for the node."
# ... more work ...
git commit -m "add tests" -m "Two tests for the new branching behavior on does-customer-have-item: one asserting the S2S resolver is not called when CVS has a stored value, and one asserting it is called (with the correct orderProductId) when CVS has no value."
```

### 5. Open the PR

Push the branch and open a PR. Then immediately edit the title and description to match the format below — do not leave the auto-generated title from `gh pr create`.

```bash
git push -u origin ec825m_<description>
gh pr create --title "<title>" --body "<body>"
```

---

## PR title style

- Plain English, sentence case, no period
- Describes what the change does at a high level
- 5–10 words, concise

Examples:
- `Don't resolve replay nodes if there is already a value for them`
- `Stop request replay on screens that were not visited by user 1`
- `Remove auth logging noise`
- `Allow new workflows for handoffs`
- `Add jira fallback for supplier transfer ticket check`

---

## PR description format

**Always use the repo's existing PR template as-is.** Before creating the PR, read `.github/pull_request_template.md` (or `.github/PULL_REQUEST_TEMPLATE.md`) in the target repo and use it verbatim as the base. Do not replace, reorder, or remove its sections — fill in the blanks the template provides.

Only fill in the sections that apply to this change. Leave placeholder text (like `_Only fill out this section if..._`) in place if the section doesn't apply.

**What to fill in within the template:**
- The description/what-is-changing section: 1–4 sentences or bullets, plain English, conversational
- Changelog fields: ticket ID, BR handle, TESTED
- Screenshots: add if the change is visible in Storybook or the workflow UI; skip or note N/A for pure logic changes

**Description writing style — what to aim for:**

Good (from PR 2888):
> don't allow replaying past a screen that user 1 did not go to.
> * we can determine that user 1 didn't go to a screen if none of the prompt nodes on that screen appear in the previous component value store

Good (from PR 2817):
> We are getting a lot of unable to decode auth tokens from partner home requests. This is because when partner home queries for a federated type in UDL and UDL forwards the auth token to DSE via the s2s gateway. The partner auth token does not work via the s2s gateway so an error is logged.
>
> But there is no need for authentication in this case (there are no user checks/etc. because we are already called by the s2s gateway)
>
> NOTE: This PR does not change any behavior or fix any issue, it just cleans up our logs.

Bad — do not write this kind of description:
> This PR introduces a comprehensive solution to address the issue of replay nodes being resolved when a value already exists in the component value store. The implementation follows established patterns and ensures backward compatibility while improving correctness.

Keep it conversational and direct, like you're explaining it to a teammate in Slack.

---

## Important rules

- **Pull main before branching.** Always start from a fresh `git pull origin main`.
- **Never force-push to main.** Branch only.
- **No cross-repo changes unless explicitly asked.** If the fix can be done in one repo, do it there.
- **Don't leave the GitHub auto-generated PR title.** Always set a clean title via `gh pr edit` or `--title` flag.
- **Honor the repo's PR template.** Read `.github/pull_request_template.md` before creating the PR and use it as the base. Never replace it with a custom format.
- **The AI-generated PR description sections** (risk assessment, Cursor Bugbot, etc.) are added automatically by bots after PR creation — do not reproduce them manually.
- **Screenshots:** If the change is visible in Storybook or the workflow UI, add before/after recordings. For pure logic changes, skip the section or note N/A.
