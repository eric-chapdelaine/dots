# Neovim Configuration

This is a modular Neovim configuration using lazy.nvim as the plugin manager.

## Directory Structure

```
~/.config/nvim/
├── init.lua                    # Main entry point
├── lua/
│   ├── emchap4/               # Core configuration
│   │   ├── init.lua           # Loads all core modules
│   │   ├── env.lua            # Environment setup (adds node to PATH)
│   │   ├── options.lua        # Vim options (line numbers, clipboard, etc.)
│   │   ├── keymaps.lua        # General keymaps
│   │   ├── autocmds.lua       # Autocommands
│   │   └── remap.lua          # (Deprecated - kept for backward compatibility)
│   └── plugins/               # Plugin configurations
│       ├── completion.lua     # Blink.cmp autocompletion
│       ├── file-explorer.lua  # Neo-tree file explorer
│       ├── formatting.lua     # Code formatting (conform.nvim)
│       ├── git.lua            # Git integrations (gitsigns, fugitive)
│       ├── lsp.lua            # LSP configuration
│       ├── telescope.lua      # Fuzzy finder
│       └── treesitter.lua     # Syntax highlighting
└── lazy-lock.json             # Plugin version lockfile
```

## Key Features

- **Modular Structure**: Each plugin category has its own file
- **LSP Support**: Configured for TypeScript, PHP, Java, and Lua
- **Git Integration**: Gitsigns and Fugitive for Git operations
- **Fuzzy Finding**: Telescope for file/text searching
- **Autocompletion**: Blink.cmp with LSP integration
- **File Explorer**: Neo-tree for file navigation
- **Auto-formatting**: Conform.nvim with project-aware prettier for TypeScript/JavaScript and ECS for PHP

## Key Bindings

### General
- `<Space>` - Leader key
- `<Esc>` - Clear search highlights
- `<Esc><Esc>` - Exit terminal mode (in terminal)

### File Navigation
- `\` - Toggle Neo-tree file explorer

### Telescope (Fuzzy Finder)
- `<leader>sf` - Find git files
- `<leader>sr` - Find all files
- `<leader>sg` - Live grep
- `<leader>sb` - Browse buffers
- `<leader>sh` - Help tags
- `<leader>st` - Treesitter symbols
- `<leader>s.` - Recently opened files
- `<leader>ps` - Grep with prompt

### LSP
- `grn` - Rename symbol
- `gra` - Code action
- `gr` - Go to references
- `gi` - Go to implementation
- `gd` - Go to definition
- `gD` - Go to declaration
- `gO` - Document symbols
- `gW` - Workspace symbols
- `grt` - Go to type definition
- `<leader>th` - Toggle inlay hints

### Formatting
- `<leader>f` - Format current buffer (respects project prettier config)
- `<leader>tf` - Toggle format on save (globally)
- Auto-format on save enabled by default

## Adding New Plugins

1. Create a new file in `lua/plugins/` (e.g., `my-plugin.lua`)
2. Return a table with plugin specifications:

```lua
return {
  {
    'author/plugin-name',
    config = function()
      -- Plugin configuration
    end,
  },
}
```

3. Restart Neovim - lazy.nvim will automatically load the new plugin

## Customization

- **Options**: Edit `lua/emchap4/options.lua`
- **Keymaps**: Edit `lua/emchap4/keymaps.lua`
- **Plugins**: Edit files in `lua/plugins/`

## Managing Plugins

- `:Lazy` - Open lazy.nvim UI
- `:Lazy update` - Update all plugins
- `:Lazy sync` - Install missing and update plugins
- `:Mason` - Manage LSP servers, formatters, and linters

## Formatting Setup

The configuration uses `conform.nvim` for code formatting with the following features:

### Automatic Project Detection
- **TypeScript/JavaScript**: Automatically finds and uses `.prettierrc`, `prettier.config.js` from your project root (DSE, Frontend)
- **PHP**: Uses ECS (Easy Coding Standard) from WFE `vendor/bin/ecs`, falls back to `php-cs-fixer`
- **Lua**: Uses `stylua`

### Format on Save
Format on save is enabled by default. The formatter will:
1. Look for project-specific prettier config in your repo (DSE, Frontend, etc.)
2. Use that config for formatting
3. Fall back to LSP formatting if no formatter is configured

### Manual Formatting
Press `<leader>f` in normal or visual mode to format the current buffer or selection.

### Required Tools
Formatters are already installed:
- ✅ **Prettier**: Installed globally via `npm install -g prettier`
- ✅ **Node.js PATH**: Automatically configured via `lua/emchap4/env.lua`
- **PHP formatter**: Uses project-local `php-cs-fixer` or falls back to LSP
- **Lua formatter**: Auto-installed via Mason (stylua)

If you need to reinstall prettier:
```bash
# Use the node version for your project
nvm use 18  # For frontend
npm install -g prettier

# Or for DSE
nvm use 14
npm install -g prettier
```

### Toggling Format on Save
To toggle format on save globally, press `<leader>tf`.

Alternatively, you can disable it via commands:
```vim
" Disable globally
:lua vim.g.disable_autoformat = true

" Disable for current buffer only
:lua vim.b.disable_autoformat = true

" Re-enable
:lua vim.g.disable_autoformat = false
```
