# dotfiles

Personal dotfiles managed with [yadm](https://yadm.io) — a Git wrapper that
tracks files **in place** in `$HOME` (no symlinks, no `stow`).

Two machines:

| Host | OS | Role |
|---|---|---|
| Arch desktop | Arch Linux | X11, i3, polybar, autorandr |
| MacBook | macOS | yabai/skhd, iTerm2 |

## How it works

```sh
yadm status                 # like git status
yadm add ~/.zshrc           # add a file
yadm commit -m "msg"        # commit
yadm push                   # publish
yadm pull --ff-only         # pull on the other machine
yadm ls-files               # what is tracked
yadm list -a                # tracked + untracked-but-trackable
```

`yadm` == `git` with `--work-tree=$HOME --git-dir=~/.local/share/yadm/repo.git`.
Everything you know from git applies.

## Layout

Files live at their real `$HOME` paths. The only directories that exist
*purely* for this repo are:

```
~/.config/yadm/
├── config      # yadm settings (status.showUntrackedFiles=no)
└── README.md   # this file

~/.gitignore    # yadm's ignore file — sees all of $HOME, keep rules anchored
```

> `~/README.md` is **not** part of this repo — it belongs to an unrelated
> project. That is why the orientation doc lives here.

## Per-machine differences

Prefer yadm's **alternates** over hand-rolled `if` blocks. A file named
`foo##os.Darwin` is checked out as `foo` on macOS, `foo##os.Linux` on Linux.
Both variants can be committed; only the matching one materialises.

Currently the OS split is still done inline in `.zshrc` (see "Structure
follow-ups" below).

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
| `.vim/autoload/plug.vim` | bootstrapped by `.vim/vimrc` on first run |
| `.vim/pack/`, `.vim/bundle/` | plugin manager territory |
| `.config/configstore/` | npm update-check timestamps |
| `.config/opencode/skills/{create-pr,run-repos-locally,workflow-storybook-testing}/SKILL.md` | workplace-specific |

`.pi/agent/npm/package.json` **is** tracked — it is declarative (which pi
extensions I want), while the lockfile is resolved state.

## Bootstrap a new machine

```sh
yadm clone <url>                  # clones into $HOME
yadm status                       # should be clean
```

Then per-OS:

```sh
# Arch
sudo pacman -S --needed git zsh neovim tree-sitter-cli nodejs npm \
  ripgrep fd fzf i3-wm polybar autorandr

# macOS
brew install git zsh neovim tree-sitter node ripgrep fd fzf
```

First Neovim launch bootstraps lazy.nvim and compiles treesitter parsers
(`tree-sitter` CLI must exist first, or folding/highlighting silently fail).
Then `:MasonToolsInstall` and `:Lazy sync`.

## Conventions & gotchas

- **Never `git add -A` / `yadm add -A`.** `$HOME` contains hundreds of
  thousands of untracked files. Add explicit paths.
  (`status.showUntrackedFiles=no` is set as a guard.)
- **Untracking ≠ ignoring.** `yadm rm --cached <f>` removes from the index but
  the *next checkout* on another clone deletes the working copy. Back up
  machine-specific files before pulling a commit that untracks them.
- **Check before committing a large diff** that you did not stage a lockfile or
  binary blob.
- Secrets never enter history: `gh hosts.yml` is ignored, and the `gho_` token
  was stripped from the commit that added `.config/gh/config.yml`.

## Structure follow-ups (not yet done)

1. Split `.zshrc` into `.config/zsh/{common,linux,darwin}.zsh`.
2. Add `.config/yadm/bootstrap` for per-OS dependency install.
3. Decide `PLUGIN_USAGE.md`'s future (regenerate from `lua/plugins/`, or delete
   and let `:Lazy` + keymap `desc` be the source of truth).
4. Move opencode skills → `.pi/agent/skills/` (pi is the current tool).
5. `defaults export` iTerm2 prefs to text instead of the binary plist.
