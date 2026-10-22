# pi + Gondolin tool isolation

`pig` = `pi -e ~/.pi/gondolin-ext` (alias in `~/.config/zsh/common.zsh`).

This extension (copied from `@earendil-works/pi-coding-agent/examples/extensions/gondolin`,
bumped to `@earendil-works/gondolin@0.13.0`) replaces pi's built-in tools
`read`, `write`, `edit`, `bash`, `grep`, `find`, `ls` and the `!` user-bash hook
with implementations that run inside a Gondolin micro-VM.

- Host cwd is mounted at guest `/workspace` via `RealFSProvider` → writes go
  through to the host. Rest of the guest filesystem is ephemeral.
- The model, provider credentials, sessions, and all other extensions still run
  on the host.
- `bash` inside the VM inherits the host env vars passed by pi, so provider API
  keys exported in your shell are visible inside the VM. This is *not* a
  credential boundary.
- VM boots on `session_start`, closes on `session_shutdown`. Status shows as
  `Gondolin: <vm-id> (/workspace)`.

Requires:

- Node >= 23.6
- QEMU (`qemu-system-x86_64`, `qemu-img`, `virtiofsd`) —
  `sudo pacman -S --needed qemu-base`

Guest assets: `alpine-base:latest` (Alpine 3.23, bash/curl/git-less base with
node/npm/python3/openssh), pulled to `~/.cache/gondolin/`.

Backends: `--vmm qemu` (default) or `--vmm krun` (libkrun/KVM, faster boot,
already installed via `@earendil-works/gondolin-krun-runner-linux-x64`).

Smoke test:

```bash
cd ~/some/project && pig -p 'run `uname -a && pwd` and report the output'
# expect: Linux ... /workspace
```
