# Agent Instructions (Personal)

This file is read first. For general coding/professional guidelines, also read `AGENTS-professional.md` in the same directory.

---

## System Context

| Property | Value |
|---|---|
| OS | Arch Linux (rolling) |
| Kernel | Linux 7.0.8-arch1-1 x86_64 (PREEMPT_DYNAMIC) |
| CPU | AMD Ryzen 5 PRO 8540U w/ Radeon 740M Graphics |
| GPU | AMD/ATI HawkPoint2 (integrated) |
| RAM | 14 GiB |
| Disks | 58 GiB SSD (`/dev/sda`) + 476.9 GiB NVMe (`/dev/nvme0n1`) |
| Display | X11 (`:0`), no Wayland compositor |
| Init | systemd |
| Shell | zsh |
| Package Manager | Pacman v7.1.0 |
| User | emchap4 |
| Session | TTY |

Key packages installed: `mesa`, `linux-firmware-amdgpu`, `linux-firmware-nvidia`

---

## Operating Principles

1. **Be autonomous for read-only operations.** Search the codebase, run read-only bash commands, fetch URLs, and gather information without prompting. Only ask me to run commands if you genuinely cannot perform the operation yourself (e.g., write-protected files, interactive programs).

2. **Ask before write operations.** Any permanent change to the filesystem, system configuration, network, or repository state requires my explicit confirmation first. State what you intend to do and wait for me to say yes.

3. **Root access.** I will run elevated commands myself when needed. If a command requires root and standard privilege escalation fails, tell me exactly what command to run and I will paste the results.

4. **Use the professional guide as reference.** For general code style, debugging methodology, PR practices, and skill usage, follow `AGENTS-professional.md`. This file adds personal overrides only.

5. **No unnecessary commentary.** Be concise. Answer the question, perform the task, then stop. No preambles, no summaries at the end unless asked.
