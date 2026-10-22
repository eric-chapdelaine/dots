# dotfiles

Personal dotfiles managed with [yadm](https://yadm.io) — a Git wrapper that
tracks files **in place** in `$HOME` (no symlinks, no `stow`).

Two machines, both laptops:

| Machine | OS | Window manager |
|---|---|---|
| Arch laptop | Arch Linux | i3 + polybar + autorandr |
| MacBook | macOS | yabai + skhd + ghostty/iTerm2 |

## How it works

```sh
yadm status                 # like git status
yadm add ~/.zshrc           # add a file
yadm commit -m "msg"        # commit
yadm push                   # publish
yadm pull --ff-only         # pull on the other machine
yadm ls-files               # what is tracked
yadm alt                    # rebuild alternate symlinks (automatic on checkout)
```

`yadm` == `git` with `--work-tree=$HOME --git-dir=~/.local/share/yadm/repo.git`.

## Layout

Files live at their real `$HOME` paths. The only directories that exist
*purely* for this repo are:

```
~/.config/yadm/
├── config      # yadm settings
├── bootstrap   # per-OS install, run by `yadm clone`/`yadm bootstrap`
├── README.md   # this file
└── hooks/
    └── post_pull   # warns when a pull deletes machine-specific files

~/.config/zsh/
├── common.zsh  # shared across both OSes
├── linux.zsh   # Arch only
└── darwin.zsh  # macOS only

~/.gitignore    # yadm's ignore file — sees all of $HOME, keep rules anchored
```

`~/.zshrc` is a ~20-line entry point: prompt, `$EDITOR`, then sources
`common.zsh` plus the one matching OS module.

> `~/README.md` is **not** part of this repo — it belongs to an unrelated
> project. That is why the orientation doc lives here.

## OS-specific files (yadm alternates)

Anything named `foo##os.Linux` / `foo##os.Darwin` is tracked normally, and
`yadm alt` creates a symlink at the clean path **only on the matching OS**.
This is what keeps i3 off the Mac and yabai off the Arch box.

| Suffixed path | Materialises as | OS |
|---|---|---|
| `.config/i3##os.Linux/` | `.config/i3` | Arch |
| `.config/polybar##os.Linux/` | `.config/polybar` | Arch |
| `.config/autorandr##os.Linux/` | `.config/autorandr` | Arch |
| `.config/yabai##os.Darwin/` | `.config/yabai` | macOS |
| `.config/skhd##os.Darwin/` | `.config/skhd` | macOS |
| `Library/Application Support/com.mitchellh.ghostty/config##os.Darwin` | same path, no suffix | macOS |
| `Library/Preferences/com.googlecode.iterm2.plist##os.Darwin` | same path, no suffix | macOS |

Generated symlinks are auto-excluded from git status (`yadm.auto-exclude`).
`yadm alt` runs automatically after clone/checkout.

**Gotcha:** `yadm alt` refuses to replace an existing *real directory* with a
symlink ("Skipping alt … as X is a directory"). Use `yadm mv <dir> <dir>##os.X`
to create an alternate — that moves the working tree correctly.

### Caveat: app-managed config files

iTerm2 and Ghostty rewrite their own config when you change a setting. The
target path is a **symlink** to the tracked file, so changes are captured only
if the app writes *through* the link. If an app replaces the link with a real
file, the alternate silently desyncs (the tracked `##os.Darwin` file stops
receiving edits). Detect it with:

```sh
ls -l ~/Library/Preferences/com.googlecode.iterm2.plist   # expect a symlink
```

If it became a regular file, copy your changes into the tracked file by hand
and re-run `yadm alt`. Do **not** set `yadm.alt-copy true` — that makes the
target a real copy, so app rewrites are never captured at all (verified: the
tracked source stays at its original content and git reports nothing).

## What is deliberately NOT tracked

| Path | Why |
|---|---|
| `.config/gh/hosts.yml` | contains a GitHub token |
| `.config/secrets.sh` | local secrets |
| `.pi/agent/auth.json` | provider API keys |
| `.pi/agent/settings.json` | per-machine default provider/model |
| `.pi/agent/models.json` | per-machine local model paths |
| `.pi/agent/sessions/`, `bin/` | runtime state |
| `.pi/agent/npm/package-lock.json` | churns on every extension update |
| `.config/opencode/node_modules/`, lockfiles | resolved dependency state |
| `.vim/` | dead — Vim is not used; Neovim only |
| `.config/configstore/` | npm update-check timestamps |
| `.config/opencode/skills/{create-pr,run-repos-locally,workflow-storybook-testing}/SKILL.md` | workplace-specific |

`.pi/agent/npm/package.json` **is** tracked — declarative (which pi extensions),
while the lockfile is resolved state.

## Bootstrap a new machine

```sh
yadm clone <url> --bootstrap      # or run `yadm bootstrap` afterwards
```

The bootstrap script installs per-OS packages, materialises alternates, syncs
lazy.nvim, builds treesitter parsers, and installs Mason tools. Then:

- `gh auth login`
- pi provider keys → `~/.pi/agent/auth.json` (never tracked)
- macOS: yabai/skhd need sudoers + Accessibility permissions
- Arch: `autorandr --save <name>` (profiles are machine-specific)

**`tree-sitter-cli` is the critical dependency** — nvim-treesitter's `main`
branch compiles parsers at install time. Without the CLI, parsers silently
fail and folding/highlighting/indent stop working, because `options.lua` uses
`vim.treesitter.foldexpr()`.

## Conventions & gotchas

- **Never `yadm add -A`.** `$HOME` holds ~442k untracked files.
  `status.showUntrackedFiles=no` is set as a guard.
- **Untracking ≠ ignoring.** `yadm rm --cached <f>` removes it from the index,
  but the *next checkout* on another clone **deletes** the working copy. Back
  up machine-specific files before pulling such a commit — the `post_pull`
  hook warns about this.
- Secrets never enter history: `gh hosts.yml` is ignored, the `gho_` token was
  stripped from the commit that added `.config/gh/config.yml`, and the iTerm2
  plist had its `/Users/<workuser>` bookmark removed.
- `.gitconfig` uses `!gh auth git-credential` (PATH-relative) rather than
  `/usr/bin/gh`, so it works on both OSes.

## Changing things

- **New shell alias/function** → `.config/zsh/common.zsh`
- **Linux-only shell setting** → `.config/zsh/linux.zsh`
- **macOS-only shell setting** → `.config/zsh/darwin.zsh`
- **New OS-specific app config** → name it `##os.Linux` / `##os.Darwin`
- **Neovim** → `.config/nvim/` (see its own README)
- **Packages needed on a new machine** → add to `.config/yadm/bootstrap`
