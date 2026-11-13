# pi + Gondolin tool isolation (pig, pig-env)

Copied from `@earendil-works/pi-coding-agent/examples/extensions/gondolin` and extended.

## pig: private VM

`pig` = `pi -e ~/.pi/gondolin-ext` (`~/.local/bin/pig`). pi's tools (`read`, `write`, `edit`, `bash`, `grep`, `find`,
`ls`, `!`) run inside a Gondolin micro-VM. The model, credentials, MCP servers and other extensions stay on the host.

- The cwd (and, for a git worktree, the main repo's `.git`) is mounted **at the same path** in the guest; writes go
  through to the host. The rest of the guest filesystem is the VM's own.
- The guest gets only its own env (`vm-env.mjs`): no host proxy (`HTTP(S)_PROXY` points at a host-only tracing proxy),
  `NODE_OPTIONS`, cloud credentials or tokens. Internet is open.
- GitHub: the guest's `GH_TOKEN` is a placeholder. The host swaps in the real `gh auth token` only on requests to GitHub
  hosts, so the token can't be sent anywhere else (verified: a placeholder sent to httpbin.org is blocked with 403).
- Host Postgres is reachable as `host-postgres:5432` (TCP mapping to 127.0.0.1). Redis is the VM's own (`redis://127.0.0.1:6379/0`,
  started at boot), so a VM's job workers never pick up queues other checkouts left in the host Redis.
  The host Redis is still reachable as `host-redis:6379` if a task really needs it.
- Knobs: `PIG_IMAGE` (an image tag, e.g. one built from `images/`; default Alpine base), `PIG_MEMORY` (2G), `PIG_CPUS` (2),
  `PIG_DISK` (8G).

## pig-env: shared VM

`pig-env` (`pig-env.mjs`) owns a named VM so it outlives any one agent and several agents can use it.

```bash
pig-env up app-a --image <image> --mount ~/code/app --memory 6G --cpus 4   # runs until stopped
PIG_ENV=app-a pig                      # agent whose bash runs in that VM (file tools use the same files on the host)
pig-env exec app-a -- bash             # shell in it
pig-env snapshot app-a                 # disk checkpoint to ~/.cache/pig-env/snapshots/app-a.qcow2; the env keeps running
pig-env up app-b --from app-a --mount ~/code/app-2   # independent copy-on-write copy
pig-env list | pig-env down app-a
```

- Snapshots keep the root disk only. `/root`, `/tmp`, `/var/cache`, `/var/log` are tmpfs; guest HOME is `/home/agent`.
- All agents attached to one env share its network settings and running processes.
- `guest-bin/` is mounted read-only at `/opt/pig-bin` (on `PATH`) in every VM when it exists, so machine-local guest
  scripts (untracked; e.g. a project's setup script) are always the current version, including in forks of old snapshots.
- A snapshot is a qcow2 overlay on its image's rootfs (`~/.cache/gondolin/images/objects/<build-id>`). Rebuilding an image
  leaves the old object untagged; don't `gondolin image rm` an untagged object while a snapshot still uses it
  (`qemu-img info <snapshot>` shows the backing file).

## Images

`images/` holds image build configs. This repo has none: the work image (`dev-base`, a work toolchain) is built from the private work repo. Without it, a VM here runs the stock Alpine base.

Building one requires e2fsprogs (`brew install e2fsprogs` on macOS, the distro package on Linux).

## Requirements

Node >= 23.6, QEMU (`brew install qemu`); the krun runner for darwin-arm64 ships with the package.
