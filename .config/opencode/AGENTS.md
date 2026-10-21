# Agent Instructions (Personal)

This file is read first. For general coding/professional guidelines, also read `AGENTS-professional.md` in the same directory.

---

## System Context

Hosts differ (Arch Linux/X11 workstation vs macOS). Detect the current host before relying on specifics:

```sh
uname -s                       # Darwin | Linux
echo "$XDG_SESSION_TYPE"       # x11 | wayland | tty
command -v yabai || command -v i3
```

Do not hardcode absolute paths from one machine into shared config — branch on OS or use `$HOME`.

---

## Operating Principles

1. **Be autonomous for read-only operations.** Search the codebase, run read-only bash commands, fetch URLs, and gather information without prompting. Only ask me to run commands if you genuinely cannot perform the operation yourself (e.g., write-protected files, interactive programs).

2. **Ask before write operations.** Any permanent change to the filesystem, system configuration, network, or repository state requires my explicit confirmation first. State what you intend to do and wait for me to say yes.

3. **Root access.** I will run elevated commands myself when needed. If a command requires root and standard privilege escalation fails, tell me exactly what command to run and I will paste the results.

4. **Use the professional guide as reference.** For general code style, debugging methodology, PR practices, and skill usage, follow `AGENTS-professional.md`. This file adds personal overrides only.

5. **No unnecessary commentary.** Be concise. Answer the question, perform the task, then stop. No preambles, no summaries at the end unless asked.

---

## Session Discipline

- **Secrets first.** Never print, commit, or send tokens, credentials, or PHI outside the machine. Deny `.env` reads; load secrets from `~/.config/secrets.sh` (untracked).
- **Start fresh sessions** for new tasks rather than continuing long ones.
- **Don't run specs or tests unless explicitly asked.** Make the change, describe what to verify, stop.
- **If a tool or query fails twice, stop and report** — don't retry autonomously.
- **Minimal changes.** Search all usages before changing shared code.

---

## Debugging Order

1. **Read the code first.** Understand the code path. Most issues are identifiable before looking at any data.
2. **Logs and metrics.** Query logs, metrics, or events for evidence.
3. **Database.** Use only if logs didn't have enough detail.

---

## Skills

Load a skill when a task matches it. Tracked skills in this repo:

- **create-pr** — Create a GitHub pull request from a description or ticket
- **review-pr** — Review a GitHub pull request end-to-end
- **macos-window-control** — Move, resize, and interact with macOS windows via AppleScript
- **write-discovery** — Write a technical discovery document for a new feature

Usage-specific skills (not tracked; live only on work machines):
`run-repos-locally`, `workflow-storybook-testing`.

Machine-local skills may also exist under `~/.pi/agent/skills/` (e.g. `llm-wiki`).
