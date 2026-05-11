# Personal Coding Agent Guide

General instructions for AI coding agents working in personal and professional projects.

---

## Development Philosophy

### Minimize unintended consequences
Before changing any function, type, helper, or constant, search for all usages across the codebase and reason through the impact on each one. If a change could affect a code path you weren't asked to touch, flag it or find a narrower solution.

### Prefer the simplest solution
Make as few changes as possible to solve the problem. A small targeted fix is almost always better than a refactor. Cross-repo changes multiply the surface area for breakage and review burden — avoid them unless the problem genuinely cannot be solved within the repo at hand.

### Ask questions during development
When working on a task incrementally, ask clarifying questions before going down a path that might be wrong. When asked to complete a feature entirely, make good decisions autonomously and summarize the key choices made after finishing.

### Comments: high-level only
Write a 1–2 line comment explaining *why* something non-obvious is happening or what a block of logic is doing at a high level. Do not over-explain. Specifically:
- Do not comment on function signatures, parameter types, or return values when they are self-evident from the code
- Do not narrate what each line does
- Do not add boilerplate JSDoc on simple private functions
- A well-named function or variable often makes a comment unnecessary — prefer that

---

## Code Style

### TypeScript/JavaScript: ESLint + Prettier, 2-space indent, named exports, alphabetical imports
### React: functional components with hooks, 2-space indent
### Java: Google Java Style, 2-space indent, 120 char line limit, K&R braces, full Javadoc on public APIs, test naming `test{Method}_when{Scenario}_then{Outcome}`
### PHP: PSR-12, typed properties, dependency injection, PHPUnit tests

---

## Debugging Order of Operations

When investigating a bug or production issue, follow this sequence:

1. **Read the code first.** Understand the code path. Most issues can be identified by reading the relevant logic before looking at any data.
2. **Logs and metrics.** Query logs, metrics, or events for evidence.
3. **Database.** Use only if logs didn't have enough detail.

---

## Pull Request Best Practices

- Small, focused PRs reviewable in one sitting
- All tests pass before requesting review
- Follow existing patterns and conventions
- Clear description of what and why
- Link related issue tickets

---

## Skills

Skills provide specialized workflows for specific tasks. Available skills:

- **create-pr** — Create a GitHub pull request from a description or ticket
- **review-pr** — Review a GitHub pull request end-to-end
- **macos-window-control** — Move, resize, and interact with macOS windows via AppleScript
- **write-discovery** — Write a technical discovery document for a new feature
