# Neovim Configuration

This is a modular Neovim configuration using lazy.nvim as the plugin manager.

## Directory Structure

```
~/.config/nvim/
├── init.lua                    # Main entry point
├── lua/
│   ├── emchap4/               # Core configuration
│   │   ├── init.lua           # Loads all core modules
│   │   ├── options.lua        # Vim options (line numbers, clipboard, etc.)
│   │   ├── keymaps.lua        # General keymaps
│   │   └── remap.lua          # (Deprecated - kept for backward compatibility)
│   └── plugins/               # Plugin configurations
│       ├── completion.lua     # Blink.cmp autocompletion
│       ├── file-explorer.lua  # Neo-tree file explorer
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
