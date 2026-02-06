-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Toggle format on save
vim.keymap.set('n', '<leader>tf', function()
  if vim.g.disable_autoformat then
    vim.g.disable_autoformat = false
    vim.b.disable_autoformat = false
    print('Format on save enabled')
  else
    vim.g.disable_autoformat = true
    vim.b.disable_autoformat = true
    print('Format on save disabled')
  end
end, { desc = 'Toggle format on save' })
