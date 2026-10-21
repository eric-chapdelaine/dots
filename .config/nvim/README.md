# Neovim Configuration

Modular Neovim config using [lazy.nvim](https://github.com/folke/lazy.nvim).
Bootstrapped automatically on first launch by `init.lua` — no manual install step.

Runs on Arch Linux and macOS. Where behaviour differs, the OS check is
`vim.fn.has("mac") == 1` (or `vim.loop`/`uname` for paths).

## Directory Structure

```
~/.config/nvim/
├── init.lua                    # Entry point: loads core, bootstraps lazy.nvim
├── lua/
│   ├── emchap4/                # Core configuration (not plugins)
│   │   ├── init.lua            # Requires the modules below
│   │   ├── env.lua             # Environment setup (node on PATH)
│   │   ├── options.lua         # Vim options (folds, numbers, clipboard)
│   │   ├── keymaps.lua         # Global keymaps
│   │   ├── autocmds.lua        # Autocommands
│   │   └── debug_context.lua   # Debug context helper
│   └── plugins/                # One file per plugin group
│       ├── aerial.lua          # Symbol outline
│       ├── completion.lua      # nvim-cmp + LuaSnip
│       ├── context.lua         # treesitter-context sticky headers
│       ├── dap.lua             # nvim-dap debugging
│       ├── file-explorer.lua   # mini.files
│       ├── formatting.lua      # conform.nvim
│       ├── git.lua             # gitsigns, fugitive, rhubarb, blame
│       ├── glance.lua          # LSP peek windows
│       ├── local-fim.lua       # Local fill-in-the-middle completion
│       ├── lsp.lua             # nvim-lspconfig + Mason
│       ├── rails.lua           # vim-rails + vim-test
│       ├── telescope.lua       # Fuzzy finder
│       ├── toggleterm.lua      # Terminal management
│       └── treesitter.lua      # Parsers + highlighting
└── lazy-lock.json              # Plugin version lockfile (tracked)
```

> **Not in this directory:** plugin source. lazy.nvim installs into
> `~/.local/share/nvim/lazy/`, parsers into `~/.local/share/nvim/parser/`,
> and Mason binaries into `~/.local/share/nvim/mason/bin/`. None of that is
> version-controlled.

## Requirements

| Requirement | Why | Install |
|---|---|---|
| Neovim ≥ 0.10 | uses `vim.treesitter.foldexpr()` | — |
| `git` | lazy.nvim bootstrap | system |
| `tree-sitter` CLI | **compiles parsers** — without it, folding/indent/highlighting silently fail | `pacman -S tree-sitter-cli` / `brew install tree-sitter`, or let Mason install `tree-sitter-cli` |
| `node` | LSP servers, prettier | system |
| `rg`, `fd` | telescope | system |

`tree-sitter` is a **build-time** dependency: the `main` branch of
nvim-treesitter no longer ships prebuilt parsers, so it shells out to
`tree-sitter build` on install/update. First launch after a fresh clone may
race (parsers build before Mason finishes installing the CLI) — if folding
looks dead, run `:MasonToolsInstall` then `:TSUpdate`.

## Key Features

- **LSP**: vtsls (TS/JS), phpactor, ruby_lsp (mise/binstub aware), pyright, lua_ls
- **Folding**: treesitter `foldexpr`, all folds open by default (`foldlevel=99`)
- **Formatting**: conform.nvim, project-aware (prettier/prettierd, ecs, stylua, rubocop)
- **Completion**: nvim-cmp + LuaSnip, plus local FIM (Tab / Shift-Tab)
- **Debugging**: nvim-dap + dap-python + dap-view
- **Git**: gitsigns, fugitive, rhubarb, blame.nvim

## Key Bindings

Leader is `<Space>`.

### General
| Key | Action |
|---|---|
| `<Esc>` | Clear search highlights |
| `<Esc><Esc>` (terminal) | Exit terminal mode |
| `<leader>d` | Diagnostic float |
| `<leader>tf` | Toggle format-on-save |

### Files & Search
| Key | Action |
|---|---|
| `\` | Toggle mini.files |
| `<leader>sf` | Find git files |
| `<leader>sr` | Find all files |
| `<leader>sg` | Live grep |
| `<leader>ps` | Grep with prompt |
| `<leader>pf` | Grep with regex + glob filter |
| `<leader>sb` | Buffers |
| `<leader>sh` | Help tags |
| `<leader>st` | Treesitter symbols |
| `<leader>s.` | Recent files |

### LSP
| Key | Action |
|---|---|
| `gd` / `gD` | Definition / declaration |
| `gr` | References |
| `gi` | Implementation |
| `gO` / `gW` | Document / workspace symbols |
| `grt` | Type definition |
| `grn` | Rename |
| `gra` | Code action |
| `gpd` / `gpr` / `gpt` / `gpi` | Glance peek (def/ref/type/impl) |
| `<leader>th` | Toggle inlay hints |

### Git
| Key | Action |
|---|---|
| `<leader>gb` | Toggle blame |

### Terminal
| Key | Action |
|---|---|
| `<leader>tt` / `<leader>t1` | Terminal 1 |
| `<leader>t2` / `<leader>t3` | Terminals 2 / 3 |
| `<C-h/j/k/l>` (in terminal) | Move window |

### Debugging
| Key | Action |
|---|---|
| `<leader>dc` / `<F6>` | Continue |
| `<leader>dn` / `<F7>` | Step over |
| `<leader>di` / `<F8>` | Step into |
| `<leader>do` / `dt` / `db` | Step out / terminate / breakpoint |
| `<leader>du` / `dr` | Toggle dap-view / REPL |

### Formatting
| Key | Action |
|---|---|
| `<leader>f` | Format buffer (n/v mode) |

Format-on-save is **on by default**; toggle with `<leader>tf`.

## Adding a Plugin

Create `lua/plugins/<name>.lua` returning a lazy.nvim spec:

```lua
return {
  'author/plugin-name',
  event = 'VeryLazy',        -- or ft=, cmd=, keys=
  opts = {},
}
```

Restart — lazy.nvim picks it up. Update `lazy-lock.json` via `:Lazy sync`.

## Managing Plugins

| Command | Purpose |
|---|---|
| `:Lazy` | Plugin UI |
| `:Lazy sync` | Install missing + update |
| `:Lazy update` | Update all |
| `:Mason` | LSP servers / formatters / linters |
| `:MasonToolsInstall` | Install everything named in `lsp.lua` |
| `:TSUpdate` | Rebuild treesitter parsers |
| `:checkhealth` | Diagnose |
