-- Autocommands

-- Match prettier's tabWidth for JS/TS files (2 spaces)
vim.api.nvim_create_autocmd('FileType', {
  desc = 'Set 2-space indent for JS/TS files to match prettier config',
  group = vim.api.nvim_create_augroup('js-ts-indent', { clear = true }),
  pattern = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
