# Neovim Plugin Usage Guide

This document covers all custom plugins added to enhance code navigation, context awareness, and terminal management.

## Table of Contents
1. [nvim-ufo (Code Folding)](#1-nvim-ufo-enhanced-code-folding)
2. [nvim-treesitter-context (Sticky Headers)](#2-nvim-treesitter-context-sticky-function-header)
3. [glance.nvim (LSP Peek)](#3-glancenvim-lsp-navigation-peek-window)
4. [toggleterm.nvim (Terminal Management)](#4-toggletermnvim-terminal-management)
5. [cursoragent.nvim (Cursor Agent)](#5-cursoragentnvim-cursor-agent-integration)
6. [nvim-mcp (Cursor IDE control)](#6-nvim-mcp-cursor-ide-control)
7. [blame.nvim (Git Blame with Commit Messages)](#7-blamenvim-git-blame-with-commit-messages)
8. [vim-rhubarb (GitHub Integration)](#8-vim-rhubarb-github-integration)
9. [vim-rails (Rails Navigation)](#9-vim-rails-rails-navigation)
10. [vim-test (Run RSpec from Neovim)](#10-vim-test-run-rspec-from-neovim)
11. [Workflow Examples](#workflow-examples)

---

## 1. nvim-ufo (Enhanced Code Folding)

### What it does:
- Provides intelligent code folding using treesitter and LSP
- Shows fold previews without opening the fold
- Displays fold count and prettier fold text

### Keybindings:
- `za` - Toggle fold under cursor (vim default)
- `zc` - Close fold under cursor (vim default)
- `zo` - Open fold under cursor (vim default)
- `zM` - Close all folds in file
- `zR` - Open all folds in file
- `zK` - Peek at folded content in popup (or show hover if not on fold)

### Usage:
1. Navigate to a function or code block
2. Press `zc` to fold it - you'll see something like `function myFunc() { ... } ↕ 15 lines`
3. Press `zo` to unfold it
4. When cursor is on a folded line, press `zK` to preview the content without opening
5. Use `zM` to fold everything and get a bird's-eye view of your file structure
6. Use `zR` to unfold everything when you need to see details

### Tips:
- Folds start open by default (foldlevel=99)
- The fold column on the left shows fold status with icons
- Folding is based on treesitter, so it understands your code structure

---

## 2. nvim-treesitter-context (Sticky Function Header)

### What it does:
- Shows the current function/class/block signature at the top of the window
- Updates automatically as you scroll through code
- Helps you maintain context when deep in nested code

### Keybindings:
- `<leader>tc` - Toggle context on/off
- `[c` - Jump to the context line (e.g., jump to function definition from inside function body)

### Usage:
1. Open any code file and scroll down into a function
2. The top of your window will show the function signature
3. If you're in nested blocks (e.g., inside an if inside a for inside a function), you'll see all 3 contexts
4. Press `[c` to jump to the function/block definition
5. Click on the context line to jump to it

### Tips:
- Shows up to 3 lines of context by default
- Works best with treesitter-supported languages
- If it feels distracting, toggle it off with `<leader>tc`
- Context is highlighted differently than regular code for easy identification

---

## 3. glance.nvim (LSP Navigation Peek Window)

### What it does:
- Lets you peek at definitions, references, implementations, and type definitions WITHOUT leaving your current file
- Shows a split window with list of locations and live preview
- Perfect for quick code inspection without losing your place

### Keybindings:
- `gpd` - Glance peek definitions
- `gpr` - Glance peek references
- `gpt` - Glance peek type definitions
- `gpi` - Glance peek implementations

### When glance window is open:
**In the list pane (left):**
- `j`/`k` or `↓`/`↑` - Navigate between items
- `<Tab>`/`<S-Tab>` - Navigate between files (locations)
- `<CR>` or `o` - Jump to location and close glance
- `v` - Open in vertical split
- `s` - Open in horizontal split
- `t` - Open in new tab
- `<leader>l` - Focus the preview pane (right side)
- `q` or `<Esc>` - Close glance window

**In the preview pane (right):**
- `<Tab>`/`<S-Tab>` - Navigate between files
- `<leader>l` - Focus the list pane (left side)
- `Q` - Close glance window

### Usage:
1. Place cursor on a function call or variable
2. Press `gpd` to peek at its definition
3. Use `j`/`k` to navigate if there are multiple definitions
4. The right pane shows live preview of each location
5. Press `<CR>` to jump there, or `q` to close and stay where you are

### Tips:
- Use this when you just want to quickly check something without losing your place
- `gpr` is great for seeing everywhere a function/variable is used
- The preview window is fully functional - you can scroll, search, etc.
- Glance complements your existing LSP keybindings (`gd`, `gr`, `gi`)

---

## 4. toggleterm.nvim (Terminal Management)

### What it does:
- Manages multiple persistent terminal sessions within Neovim
- Provides quick access to terminals without losing your editing context
- Terminal 1: Horizontal split for quick commands
- Terminals 2-4: Replace buffer mode for long-running processes

### Keybindings:
- `<leader>tt` - Toggle Terminal 1 (horizontal split, 30% height)
- `<leader>t2` - Toggle Terminal 2 (replaces current buffer)
- `<leader>t3` - Toggle Terminal 3 (replaces current buffer)
- `<leader>t4` - Toggle Terminal 4 (replaces current buffer)

### Terminal Mode Navigation:
When inside a terminal, use these keybindings:
- `<Esc>` - Exit terminal mode to normal mode
- `<C-h>` - Move to left window
- `<C-j>` - Move to window below
- `<C-k>` - Move to window above
- `<C-l>` - Move to right window

### Usage:

**Terminal 1 (Quick Commands):**
1. Press `<leader>tt` to open a horizontal split at the bottom
2. Run quick commands (e.g., `git status`, `npm test`)
3. Press `<leader>tt` again to toggle it away
4. The terminal persists - toggle it back to see your previous session

**Terminals 2-4 (Long-running Processes):**
1. Press `<leader>t2` to replace your current buffer with a terminal
2. Run long-running processes (e.g., `npm run dev`, test watchers, REPL)
3. Press `<leader>t2` again to return to your previous buffer
4. Each terminal (2-4) maintains its own session independently

### Workflow Examples:

**Example 1: Development Server + Tests**
```
1. Open your main code file
2. Press <leader>tt and run `npm run dev` (or use <leader>t2 for fullscreen)
3. Close terminal with <leader>tt
4. Press <leader>t3 and run `npm run test:watch`
5. Toggle between your code and test output with <leader>t3
6. Press <leader>tt anytime for quick git commands
```

**Example 2: Multiple Build Processes**
```
1. <leader>t2 - Frontend dev server
2. <leader>t3 - Backend server
3. <leader>t4 - Database CLI or logs
4. <leader>tt - Quick git/file operations
5. Switch between them instantly without restarting processes
```

**Example 3: REPL Workflow**
```
1. Open your Python/Node/Ruby file
2. Press <leader>t2 to open a Python REPL
3. Test code snippets in the REPL
4. Press <leader>t2 to return to your code
5. Make changes, press <leader>t2 to test again
```

### Terminal Behavior:

**Terminal 1 (`<leader>tt`):**
- Opens horizontally at bottom (30% of screen height)
- Good for: Quick commands, git operations, one-off builds
- Doesn't take over your whole screen
- Persists when toggled off

**Terminals 2-4 (`<leader>t2-t4`):**
- Replaces your current buffer completely
- Good for: Dev servers, test watchers, logs, REPLs
- Each remembers what buffer you were in
- Returns to previous buffer when toggled off

### Tips:
- All terminals persist - they keep running when toggled off
- Use `<Esc>` to exit insert mode in terminal, then navigate normally
- Terminal sessions survive even if you switch buffers or close windows
- Great for keeping multiple dev environments active simultaneously
- Terminals auto-scroll to show new output
- Each terminal has its own independent working directory

### Troubleshooting:
- If a terminal won't close, press `<Esc>` first to exit insert mode
- To kill a terminal process: `<Esc>` then `:bd!` 
- To restart a terminal: Close it (`:bd!`) then toggle it again

---

## 5. cursoragent.nvim (Cursor Agent Integration)

### What it does:
- Runs the Cursor Agent CLI inside Neovim
- Neovim exposes an MCP bridge so the agent can read buffers, selections, and diagnostics
- Supports agent, ask, plan, and resume modes
- Auto-reloads buffers when the agent edits files on disk

### Keybindings:
- `<leader>ca` - Toggle Cursor Agent terminal
- `<leader>cq` - Open in ask mode (read-only Q&A)
- `<leader>cp` - Open in plan mode (read-only planning)
- `<leader>cr` - Resume the most recent session
- `<leader>cs` - Send visual selection to the agent
- `<leader>cb` - Send the current buffer to the agent

### Usage:
1. Open a project and press `<leader>ca` to toggle the agent terminal
2. Ask the agent to explain, refactor, or fix code in the project root
3. Select code in visual mode and press `<leader>cs` to send just that range
4. Use `<leader>cr` to continue a previous conversation

### Tips:
- The terminal opens on the right at 40% width by default
- MCP servers from `~/.cursor/mcp.json` and project `.cursor/mcp.json` are available to the agent
- Requires `cursor-agent` at `~/.local/bin/cursor-agent`

---

## 6. nvim-mcp (Cursor IDE Control)

### What it does:
- Lets Cursor IDE view and control your running Neovim session(s)
- Uses Neovim's native RPC socket — no extra Neovim plugin required
- Configured globally in `~/.cursor/mcp.json` and `~/.cursor/rules/nvim-mcp.mdc`

### Neovim commands:
- `:McpServerAddress` - Print this instance's RPC socket path
- `:McpClearHighlights` - Clear MCP highlight annotations
- `:McpClearVirtualTexts` - Clear MCP virtual text annotations

### Usage:
1. Start Neovim normally — each instance auto-starts an RPC server
2. In Cursor IDE, use Agent chat with nvim-mcp tools enabled
3. If multiple Neovim instances are running, tell Cursor which one to connect to

### Tips:
- Restart Cursor after MCP config changes
- For a fixed socket per instance, start Neovim with `nvim --listen /tmp/my.sock`
- Requires `uvx nvim-mcp` (installed via `~/.local/bin/uvx`)

---

## 7. blame.nvim (Git Blame with Commit Messages)

### What it does:
- Shows git blame in a fugitive-style vertical split
- Displays **commit messages** instead of just author names
- Format: `hash • commit message • date`
- Built-in GitHub/GitLab/Bitbucket integration
- Navigate through file history at any point (blame stack)

### Keybindings:
- `<leader>gb` - Toggle blame window

### Blame Window Mappings:
When the blame window is open:
- `<CR>` - Show full commit details
- `o` - Open commit on GitHub/GitLab/Bitbucket in browser
- `i` - Show commit info popup
- `<Tab>` - Push to blame stack (view file before this commit)
- `<BS>` - Pop from blame stack (go back)
- `y` - Copy commit hash to clipboard
- `q` or `<Esc>` - Close blame window

### Usage:

**Basic blame workflow:**
```
1. Open any file in a git repository
2. Press <leader>gb
3. Blame window opens showing:
   48e80193 • Add vim-rhubarb integration • 2026-02-24
   a3347a5 • Configure nvim plugins • 2026-02-22
4. Navigate through commits as needed
```

**View commit details:**
```
1. Open blame with <leader>gb
2. Move cursor to a commit line
3. Press <CR> to see full commit
4. Or press i for a quick popup
```

**Open commit on GitHub:**
```
1. Open blame with <leader>gb
2. Position cursor on any commit
3. Press o
4. Commit opens in your browser on GitHub
```

**Navigate file history (blame stack):**
```
1. Open blame with <leader>gb
2. Find an interesting commit
3. Press <Tab> to see file BEFORE that commit
4. Press <Tab> again to go further back
5. Press <BS> to return to more recent state
```

### Display Format:

The blame window shows:
```
48e80193 • organize neovim files • 2026-02-06
4023fcb • Add vim-rhubarb for GitHub integration • 2026-02-24
a3347a5 • Add Neovim plugins: folding, context, glance • 2026-02-22
```

**Format breakdown:**
- `48e80193` - First 8 chars of commit hash (highlighted)
- `•` - Separator
- `organize neovim files` - **Commit message** (this is what you wanted!)
- `•` - Separator  
- `2026-02-06` - Date in YYYY-MM-DD format

### Workflow Examples:

**Example 1: Understanding Why Code Changed**
```
1. See a confusing line of code
2. Press <leader>gb
3. Read commit message for that line
4. Press <CR> to see full commit context
5. Press o to view PR on GitHub if needed
```

**Example 2: Finding When Bug Was Introduced**
```
1. Find buggy line
2. Press <leader>gb
3. See commit: "Add feature X • 2025-12-15"
4. Press <Tab> to see file before that commit
5. Keep pressing <Tab> to find when bug appeared
6. Press <BS> to return to current state
```

**Example 3: Sharing Commit Context**
```
1. Teammate asks about a line
2. Press <leader>gb
3. Position on relevant commit
4. Press y to copy commit hash
5. Or press o to get GitHub URL to share
```

### Tips:
- Blame window is scroll-bound to your code - they scroll together
- Same commits are highlighted in the same color
- Works with GitHub, GitLab, and Bitbucket
- Commit messages make it easy to understand change context
- Blame stack is great for archaeological code investigation

### Comparison with Fugitive's :Git blame:

| Feature | fugitive `:Git blame` | blame.nvim |
|---------|----------------------|------------|
| Shows commit hash | ✅ Yes | ✅ Yes |
| Shows author | ✅ Yes | ❌ No |
| Shows commit message | ❌ No | ✅ Yes |
| Shows date | ✅ Yes | ✅ Yes |
| Customizable format | ❌ No | ✅ Yes |
| Blame stack (history) | ❌ No | ✅ Yes |
| Open on GitHub | ⚠️ Via rhubarb | ✅ Built-in |
| Virtual text mode | ❌ No | ✅ Yes |

---

## 8. vim-rhubarb (GitHub Integration)

### What it does:
- Extends vim-fugitive with GitHub-specific features
- Enables `:GBrowse` to open GitHub URLs in your browser
- Provides GitHub issue and collaborator autocomplete in commit messages
- Works seamlessly with GitHub and GitHub Enterprise

### Commands:

**`:GBrowse`** - Open current file/commit/selection on GitHub
- From normal mode: Opens current file on GitHub at current branch
- From visual mode: Opens the selected line range on GitHub
- In fugitive buffers: Opens commits, blobs, trees, etc. on GitHub
- Add `!` to copy URL to clipboard instead: `:GBrowse!`

**Omni-completion** (in commit messages):
- `<C-X><C-O>` - Autocomplete GitHub issues, URLs, and collaborators
- Type `#` and trigger completion to see issues
- Type `@` and trigger completion to see collaborators

### Usage:

**Opening files on GitHub:**
```
1. Open any file in a GitHub repository
2. Type :GBrowse and press Enter
3. Your browser opens to that file on GitHub
```

**Opening specific line ranges:**
```
1. Select lines in visual mode (V or v)
2. Type :GBrowse
3. Opens GitHub with those exact lines highlighted
```

**Copying GitHub URLs:**
```
1. Position cursor or select lines
2. Type :GBrowse!
3. URL is copied to clipboard instead of opening browser
```

**Commit message autocomplete:**
```
1. Run :Git commit
2. In the commit message, type "Closes #"
3. Press <C-X><C-O> to autocomplete issue numbers
4. Or type @<C-X><C-O> to autocomplete collaborator names
```

### Workflow Examples:

**Example 1: Sharing Code with Teammates**
```
1. Navigate to the code you want to share
2. Select the relevant lines in visual mode
3. Run :GBrowse!
4. Paste the URL in Slack/email - includes line numbers!
```

**Example 2: Reviewing PR Changes**
```
1. Use fugitive to view a commit: :Git show <commit-hash>
2. Run :GBrowse to open that commit on GitHub
3. Review the full PR context in the browser
```

**Example 3: Writing Better Commit Messages**
```
1. Run :Git commit
2. Type "Fixes #" then <C-X><C-O>
3. Select the issue from the autocomplete list
4. Add collaborator with @<C-X><C-O>
5. Complete: "Fixes #123 - thanks @username!"
```

**Example 4: Quick Documentation Lookup**
```
1. Place cursor on a function definition
2. Run :GBrowse
3. GitHub opens showing the function
4. Use GitHub's "View blame" to see history
```

### GitHub Enterprise Setup:

If using GitHub Enterprise, add to your config:
```lua
vim.g.github_enterprise_urls = {'https://github.yourcompany.com'}
```

### GitHub API Setup (Optional):

For autocomplete features, generate a personal access token:
1. Go to https://github.com/settings/tokens/new
2. Create token with `repo` permissions
3. Add to `~/.netrc`:
   ```
   machine api.github.com login <username> password <token>
   ```

### Tips:
- Works with any fugitive buffer (commits, diffs, trees)
- `GBrowse` respects your current branch
- Line ranges in URLs are automatically formatted for GitHub
- Use `:GBrowse @upstream` to open on the upstream remote
- Combine with fugitive's `:Git blame` then `:GBrowse` to see commit on GitHub
- In visual mode, works with both line-wise (V) and character-wise (v) selections

### Troubleshooting:

**"Not a git repository" error:**
- Make sure you're in a file tracked by git
- Check `:Git` works first (fugitive requirement)

**GBrowse opens wrong URL:**
- Check your git remotes: `:Git remote -v`
- Specify remote explicitly: `:GBrowse origin`

**Autocomplete not working:**
- Ensure you have curl installed: `which curl`
- Check your `~/.netrc` has the API token
- Try `:set omnifunc?` to verify completion is set

---

## 9. vim-rails (Rails Navigation)

### What it does:
- Teaches Neovim about Rails project conventions so you can jump between related files instantly
- Understands the naming rules Rails uses (controller → spec, model → view, routes → controller, etc.)
- Enhances `gf` (go to file) so it works on Rails-style references like `:sku_options` in routes
- Provides ex commands for navigating to any Rails file type by name

### Commands:

**`:A`** — Alternate file (most useful command)
- In a controller → jumps to its spec
- In a spec → jumps back to the source file
- In a model → jumps to its spec

**`:Econtroller <name>`** — Open a controller by name
- `:Econtroller sku_options` → opens `app/controllers/.../sku_options_controller.rb`
- `:Econtroller api/internal/catalog/skus` → opens that nested controller

**`:Emodel <name>`** — Open a model by name
- `:Emodel sku` → opens `app/models/sku.rb`
- `:Emodel lab/order` → opens `app/models/lab/order.rb`

**`:Espec <name>`** — Open a spec by name
- `:Espec models/sku` → opens `spec/models/sku_spec.rb`

**`:Eroutes`** — Open `config/routes.rb`

**`:Emigration`** — Open the most recent migration

**`:Eschema`** — Open `db/schema.rb`

**`:Einitializer <name>`** — Open an initializer by name

**`gf`** — Go to file (enhanced by vim-rails)
- Cursor on `:sku_options` in routes.rb → opens the controller
- Cursor on a `render 'partial_name'` → opens the partial
- Cursor on a `require` path → opens the file

### Usage:

**Jump to the controller for a route:**
```
1. Open config/routes.rb
2. Put cursor on :sku_options
3. Press gf → opens Api::External::SkuOptionsController
```

**Jump between controller and spec:**
```
1. Open any controller (e.g. skus_controller.rb)
2. Press :A → jumps to spec/controllers/.../skus_controller_spec.rb
3. Press :A again → jumps back to the controller
```

**Open any model by name:**
```
:Emodel care/plan     → app/models/care/plan.rb
:Emodel sku_category  → app/models/sku_category.rb
```

### Tips:
- `:A` is the command you'll use most — build the muscle memory
- All `E` commands support tab-completion
- Works with nested namespaces using `/` as the separator
- `gf` on a partial name in a `render` call opens the partial file

---

## 10. vim-test (Run RSpec from Neovim)

### What it does:
- Runs RSpec tests without leaving Neovim
- Runs the nearest test, the whole file, or the last test with single keymaps
- Output appears in Terminal 1 (the horizontal split at the bottom)
- Runs tests via `docker compose exec rails bundle exec rspec` (inside the Rails container)

### Keybindings:
- `<leader>rn` - Run the test **nearest** to your cursor
- `<leader>rf` - Run all tests in the **current file**
- `<leader>rl` - **Re-run** the last test that was run
- `<leader>rs` - Run the **full suite** (use sparingly — runs everything)

### Usage:

**Run a single test:**
```
1. Open a spec file (e.g. spec/models/sku_spec.rb)
2. Put your cursor anywhere inside an `it` block
3. Press <leader>rn → runs just that one example
4. Output appears in the terminal split at the bottom
```

**Run all tests in a file:**
```
1. Open any spec file
2. Press <leader>rf → runs the whole file
3. Toggle Terminal 1 (<leader>tt) to see full output if it scrolled past
```

**Re-run after making a fix:**
```
1. A test fails
2. Edit the implementation
3. Press <leader>rl → re-runs the exact same test without moving your cursor
```

### Workflow: TDD loop
```
1. Open the spec file and navigate to the test you're working on
2. Press <leader>rn — test fails (expected)
3. Press <leader>tt to read the failure output
4. Press <leader>tt again to return to code
5. Edit the implementation
6. Press <leader>rl to re-run — no need to navigate back to the spec
7. Repeat until green
```

### Tips:
- `<leader>rn` detects the nearest `it`, `describe`, or `context` block — works from anywhere inside it
- The terminal persists between runs so you can scroll back through output
- `<leader>rl` is the most-used binding — run it from anywhere after a failure

---

## Workflow Examples

### Example 1: Understanding a Large Function
1. Use `zM` to fold all code and see the file structure
2. Navigate to your target function and press `zo` to open just that fold
3. Scroll through the function - the treesitter-context shows you which function you're in
4. See a call to another function? Press `gpd` to peek at its definition
5. Press `q` to close glance and continue reading

### Example 2: Refactoring with Context
1. Find the function you want to refactor using `<leader>st` (Telescope treesitter)
2. Use `gpr` to see all references to that function
3. Navigate through references with `j`/`k` to understand usage
4. Close glance and select the function in visual mode
5. Press `<leader>ca` and ask Cursor Agent to refactor it
6. Review the changes in the diff view

### Example 3: Navigating Nested Code
1. You're deep in a nested function and lost context
2. Look at the top of the screen - treesitter-context shows you the full context chain
3. Press `[c` to jump up to the parent function definition
4. Use `zc` to fold the function and see other functions around it
5. Press `zK` while on the fold to preview what's inside without opening

### Example 4: Full-Stack Development Workflow
1. Open your backend code file
2. Press `<leader>t2` and start backend server (`npm run server`)
3. Press `<leader>t2` to return to code
4. Open your frontend file
5. Press `<leader>t3` and start frontend (`npm run dev`)
6. Press `<leader>t3` to return to code
7. Use `<leader>tt` for quick git commits
8. Toggle between terminals as needed - all stay running

### Example 5: Debugging with Terminals and Context
1. Open a file with a bug
2. Press `gpd` on a function to see its definition
3. Press `<leader>t2` to open a REPL and test the function
4. See the error? Press `<leader>t2` to return to code
5. Use `<leader>cs` to send the problematic code to Cursor Agent for a fix
6. Press `<leader>t2` to test again in REPL
7. Use `zM` to fold all and see the bigger picture

---

## Installation & Setup

### Initial Installation
After pulling these config files, you need to:

1. Restart Neovim or run `:source ~/.config/nvim/init.lua`
2. Run `:Lazy sync` to install the new plugins
3. Restart Neovim again to fully activate everything

The plugins will auto-install on first load thanks to lazy.nvim!

### Plugin Files Location

All plugin configurations are in `~/.config/nvim/lua/plugins/`:
- `folding.lua` - nvim-ufo configuration
- `context.lua` - nvim-treesitter-context configuration
- `glance.lua` - glance.nvim configuration
- `toggleterm.lua` - toggleterm.nvim configuration
- `cursoragent.lua` - Cursor Agent CLI integration

### Modified Core Files

The following core config files were modified:
- `lua/emchap4/options.lua` - Added fold display characters
- `lua/emchap4/init.lua` - Added debug_context require
- `lua/plugins/lsp.lua` - Added LSP auto-start for all configured servers
- `lua/emchap4/debug_context.lua` - Debug helper for treesitter-context

### Verifying Installation

To verify everything is working:

1. **Check plugins loaded**: `:Lazy` should show all plugins installed
2. **Test folding**: Open a code file and press `zM` - should fold all code
3. **Test context**: Scroll into a function - should see function header at top
4. **Test glance**: Put cursor on a function and press `gpd` - should see peek window
5. **Test terminal**: Press `<leader>tt` - should open terminal at bottom
6. **Test Cursor Agent**: Press `<leader>ca` - should open the agent terminal

### Troubleshooting

**Context not showing:**
- Run `:TSContextToggle` to enable it
- Check treesitter installed: `:checkhealth nvim-treesitter`
- Make sure you're in a supported language file

**Folding not working:**
- Check fold settings: `:set foldmethod?` should show "expr"
- Try `:e` to reload the file
- Check treesitter: `:checkhealth nvim-treesitter`

**Glance not working:**
- Make sure LSP is attached: `:LspInfo`
- Check language server is running for your file type

**Terminal not toggling:**
- Make sure you're in normal mode (press `<Esc>` if in terminal mode)
- Try closing and reopening Neovim

**Cursor Agent not responding:**
- Make sure `cursor-agent` is installed at `~/.local/bin/cursor-agent`
- Run `cursor-agent status` in a shell to verify auth
- Check `:Lazy` shows `cursoragent.nvim` installed

---

## Quick Reference Card

### Code Folding
| Key | Action |
|-----|--------|
| `za` | Toggle fold |
| `zc` | Close fold |
| `zo` | Open fold |
| `zM` | Close all folds |
| `zR` | Open all folds |
| `zK` | Peek fold |

### Context Navigation
| Key | Action |
|-----|--------|
| `<leader>tc` | Toggle context |
| `[c` | Jump to context |

### LSP Peek
| Key | Action |
|-----|--------|
| `gpd` | Peek definitions |
| `gpr` | Peek references |
| `gpt` | Peek type defs |
| `gpi` | Peek implementations |

### Terminals
| Key | Action |
|-----|--------|
| `<leader>tt` | Terminal 1 (split) |
| `<leader>t2` | Terminal 2 (fullscreen) |
| `<leader>t3` | Terminal 3 (fullscreen) |
| `<leader>t4` | Terminal 4 (fullscreen) |
| `<Esc>` | Exit terminal mode |

### Cursor Agent
| Key | Action |
|-----|--------|
| `<leader>ca` | Toggle agent terminal |
| `<leader>cq` | Ask mode |
| `<leader>cp` | Plan mode |
| `<leader>cr` | Resume session |
| `<leader>cs` | Send selection |
| `<leader>cb` | Send buffer |

### Git Blame
| Key | Action |
|-----|--------|
| `<leader>gb` | Toggle blame |
| `<CR>` | Show commit (in blame) |
| `o` | Open on GitHub (in blame) |
| `i` | Commit info popup |
| `<Tab>` | Blame stack push |
| `<BS>` | Blame stack pop |
| `y` | Copy commit hash |

### GitHub Integration
| Command | Action |
|---------|--------|
| `:GBrowse` | Open on GitHub |
| `:GBrowse!` | Copy GitHub URL |
| `<C-X><C-O>` | Autocomplete (in commits) |

### Rails Navigation
| Command | Action |
|---------|--------|
| `:A` | Alternate file (controller ↔ spec) |
| `:Econtroller <name>` | Open controller by name |
| `:Emodel <name>` | Open model by name |
| `:Espec <name>` | Open spec by name |
| `:Eroutes` | Open routes.rb |
| `:Emigration` | Open latest migration |
| `:Eschema` | Open schema.rb |
| `gf` | Go to Rails file under cursor |

### RSpec (vim-test)
| Key | Action |
|-----|--------|
| `<leader>rn` | Run nearest test |
| `<leader>rf` | Run test file |
| `<leader>rl` | Re-run last test |
| `<leader>rs` | Run full suite |

---

## Summary of Changes

This configuration adds the following capabilities to Neovim:

1. **Smart Code Folding** - Fold functions, classes, and blocks with treesitter intelligence
2. **Sticky Headers** - Always see what function/class you're in
3. **LSP Peek Windows** - View definitions and references without losing your place
4. **Terminal Management** - Run multiple persistent terminals alongside your code
5. **AI Integration** - Cursor Agent inside Neovim, plus Cursor IDE control via nvim-mcp
6. **Git Blame with Commit Messages** - See why code changed, not just who changed it
7. **GitHub Integration** - Open files and commits on GitHub, autocomplete issues in commits
8. **Auto-starting LSP** - Language servers automatically start when opening files
9. **Rails Navigation** - Jump between controllers, models, specs, and routes by convention
10. **RSpec Runner** - Run nearest test, file, or last test without leaving Neovim

All features work together to create a powerful code navigation and development environment.

### Plugin Files

The following plugin files are configured:
- `lua/plugins/git.lua` - Git-related plugins (fugitive, rhubarb, gitsigns, blame.nvim)
- `lua/plugins/folding.lua` - nvim-ufo code folding
- `lua/plugins/context.lua` - nvim-treesitter-context
- `lua/plugins/glance.lua` - LSP peek windows
- `lua/plugins/toggleterm.lua` - Terminal management
- `lua/plugins/cursoragent.lua` - Cursor Agent CLI integration
- `lua/plugins/rails.lua` - vim-rails (Rails navigation) + vim-test (RSpec runner)
