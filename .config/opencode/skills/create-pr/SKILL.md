---
name: create-pr
description: Create a GitHub pull request from a description or ticket — pulls main, creates a branch, writes focused commits, and opens a PR with a concise title and minimal description.
---

## What I do

Given a task description or issue/ticket ID:

1. Understand the ask — read repos to understand context
2. Ask clarifying questions if the approach is ambiguous before writing any code
3. Pull latest `main` and create a properly named branch
4. Implement the change in focused, incrementally committed chunks
5. Open a GitHub PR with the correct title and description format

---

## Step-by-step process

### 1. Understand the task

Read the relevant code first. If a ticket ID is provided, read it. If the task touches company-specific systems or concepts that aren't clear from the repos, look them up.

**Ask questions before writing code if:**
- The right repo or file to change is unclear
- There are multiple valid approaches and the tradeoffs matter
- The task could require cross-repo changes (confirm this is actually necessary first)
- The scope of change is ambiguous
- The ticket or description is too high-level — in this case, read the relevant code, compile the reasonable implementation options with a brief tradeoff summary for each, and ask the user which to go with. Only skip asking if one option is clearly the right choice given the codebase.

Do not ask questions if the task is straightforward and the right path is clear from reading the code.

### 2. Branch naming

Branch names follow this pattern: `<username>_<short_snake_case_description>`

- Keep it short (3–5 words max)
- Describe what the change does, not why
- No ticket numbers in the branch name

```bash
git checkout main
git pull origin main
git checkout -b <username>_<description>
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

Every commit should describe the specific thing it does. Start with the first meaningful unit of work — there is no "initial implementation" catchall.

```bash
git add <files>
git commit -m "short headline" -m "Longer explanation of what was done and why, including reasoning and tradeoffs."
```

### 5. Open the PR

Push the branch and open a PR with a clean title and description. Do not leave the auto-generated title from `gh pr create`.

```bash
git push -u origin <username>_<description>
gh pr create --title "<title>" --body "<body>"
```

---

## PR title style

- Plain English, sentence case, no period
- Describes what the change does at a high level
- 5–10 words, concise

---

## PR description format

**Always use the repo's existing PR template as-is.** Before creating the PR, read `.github/pull_request_template.md` (or `.github/PULL_REQUEST_TEMPLATE.md`) in the target repo and use it verbatim as the base. Do not replace, reorder, or remove its sections — fill in the blanks the template provides.

Only fill in the sections that apply to this change.

**Description writing style:**

Keep it conversational and direct, like you're explaining it to a teammate in Slack. Short, plain English, 1–4 sentences or bullets. Avoid corporate-sounding prose.

---

## Important rules

- **Pull main before branching.** Always start from a fresh `git pull origin main`.
- **Never force-push to main.** Branch only.
- **No cross-repo changes unless explicitly asked.** If the fix can be done in one repo, do it there.
- **Don't leave the GitHub auto-generated PR title.** Always set a clean title via `gh pr edit` or `--title` flag.
- **Honor the repo's PR template.** Read `.github/pull_request_template.md` before creating the PR and use it as the base. Never replace it with a custom format.
