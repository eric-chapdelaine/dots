-- Leader key
vim.g.mapleader = " "

-- Line numbers
vim.o.number = true
vim.o.relativenumber = true

-- Clipboard
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- Search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Indentation
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

vim.cmd('filetype indent on')
