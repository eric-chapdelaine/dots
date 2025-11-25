vim.g.mapleader = " "

vim.o.number = true
vim.o.relativenumber = true

-- share clipboard with OS and neovim
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Exit terminal mode 
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Set options for indentation
vim.opt.autoindent = true       -- Copy the indentation of the current line to the new line
vim.opt.smartindent = true      -- More intelligent indentation (e.g., after a '{')
vim.opt.expandtab = true        -- Convert tabs into spaces
vim.opt.shiftwidth = 4          -- Number of spaces for auto-indent (e.g., when pressing < or >)
vim.opt.tabstop = 4             -- Number of spaces a <Tab> character counts for

-- Optional: This is generally the default in Neovim, but good practice
vim.cmd('filetype indent on')
