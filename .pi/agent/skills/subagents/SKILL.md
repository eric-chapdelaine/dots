---
name: subagents
description: Delegate work to subagents that run as visible pi sessions in herdr tabs ("subagent - <desc>"), optionally inside Gondolin VMs (pig) or a shared VM (pig-env). Use to try several hypotheses or fixes in parallel, to keep a known noisy task (environment setup, long log digging) out of the main context, or for independent review.
---

# Subagents

Tools (from `~/.pi/agent/extensions/herdr-subagents`): `subagent_spawn`, `subagent_wait`, `subagent_list`,
`subagent_read`, `subagent_close`, plus `intercom` for messages. Subagents report with `subagent_done`.

## When to delegate

- **Explore in parallel.** For example, three plausible fixes for a flaky e2e DNS failure: one subagent per fix, each in its
  own VM, then compare the reports. This beats trying fixes one after another.
- **Known, noisy tasks.** Building an environment, bisecting, digging through logs. The subagent's transcript stays
  in its tab; you only read its report.
- **Independent review.** A fresh `reviewer` with no attachment to the code.
- **Don't** delegate a small task you can finish faster yourself, or work that needs your whole conversation context.

## Spawning

- **Preset:** pick the least capable one that can do the job (the spawn tool lists them, with their models).
  `low-investigator` for narrow lookups, `env-builder` to set up a VM. `investigator`, `reviewer`, and `worker`, the
  implementer. `advisor` only for a decision or direction when stuck, or when the only thing that works is an ugly
  solution; give it the options and evidence, and it recommends without implementing.
  Presets live in `~/.pi/agent/extensions/herdr-subagents/presets.json`. Which model each one gets is per machine:
  the private `presets.work.json` overlays the tiers and limits where that repo is cloned.
- **MCP:** pass only the servers the task needs (for example `mcp: ["playwright"]`, or `[]`). Read-only presets get only tools
  the server marks read-only. Machine-specific aliases and per-preset MCP limits live in `presets.local.json` next to
  `presets.json` (untracked).
- **Task:** self-contained. The subagent has none of your context: give paths, ids, what you already ruled out, and exactly
  what to report. It reports `## Answer / ## Evidence / ## Confidence / ## Not verified`.
- **desc:** 2–5 words. Eric scans the tab names.

## Sandboxes: share or copy?

| `sandbox` | Use when |
|---|---|
| `vm` | Independent work, when the preset uses it. A private Gondolin VM whose image comes from the preset file (`vmImage`); cwd mounted at the same path. Internet and a GitHub token work; no cloud credentials. |
| `env:<name>` | Several agents need the **same running setup** (built gems, a running server). Start it once: `pig-env up <name> --image <image> --mount <dir> [--memory 6G --cpus 4]`, in a herdr tab named `env - <name>`. All attached agents share its network settings and state. |
| copy of an env | Agents need the same starting point but would **interfere** (migrations, different fixes). `pig-env snapshot <name>`, then one `pig-env up <name>-a --from <name> --mount <their dir>` per agent. Only snapshot when there is real setup to reuse; a fresh `vm` is cheaper otherwise. |
| `host` | The task needs the host machine itself (Docker, playwright against the host). |

- Each agent that writes code gets its **own git worktree** (AGENTS.md "Git and PRs"); a shared env needs every directory it writes in mounted.
- Each agent that writes to a database gets its own copy of it.
- **Project recipes:** a project's testing skill may define a ready snapshot and a one-command setup for its stack (a
  script in `~/.pi/gondolin-ext/guest-bin/`, on `PATH` in every VM). Use those instead of setting the stack up by hand.
- Start long-lived envs detached, so a tool timeout can't kill them: `nohup pig-env up <name> ... > /tmp/pig-env-<name>.log
  2>&1 & disown`, then poll `pig-env list` until it shows.
- Writing many small files (e.g. `node_modules`) into a mounted folder is several times slower than the VM's own disk, and
  deleting them from inside the VM is slower still; delete from the host. npm ignores SIGTERM; stop it with `kill -9`.
- In VMs, `/root`, `/tmp` and `/var/cache` are tmpfs and are not kept in snapshots; install into `/opt` or `$HOME` (`/home/agent`).
- `pig-env list` shows running envs and snapshots; `pig-env down <name>` stops one. Stop envs you started when done.

## Collecting results

- `subagent_wait` blocks until the reports are in (or a subagent is blocked or gone). If you end your turn instead, each
  report arrives as a message when it's ready.
- Weigh the reports yourself. Re-check any claim you'll act on, as you would another agent's diagnosis.
- `subagent_read` shows a subagent's terminal when it seems stuck. Eric can also open its tab and type into it.
- `subagent_close` its tab when you no longer need it, unless Eric may want to look at it.

## Messaging and approvals

- `intercom` reaches only agents in your own tree (your parent, your subagents, their siblings). Names from `subagent_list`
  are the addresses; the root session is `main`.
- Subagents follow AGENTS.md exactly as you do. **Only Eric approves.** When a subagent asks for approval, or for a cloud
  command (subagents have no cloud credentials), bring the exact command to Eric, and pass his answer back with `intercom`
  reply. Never approve on his behalf.
- Depth and live-subagent limits come from the preset file: 1 and 2 personal, 2 and 8 work.
