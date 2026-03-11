return {
  {
    "nvim-telescope/telescope.nvim",
    version = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>sf', builtin.git_files, { desc = 'Telescope find git files' })
      vim.keymap.set('n', '<leader>sr', builtin.find_files, { desc = 'Telescope find files' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = 'Telescope live grep' })
      vim.keymap.set('n', '<leader>sb', builtin.buffers, { desc = 'Telescope buffers' })
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = 'Telescope help tags' })
      vim.keymap.set('n', '<leader>st', builtin.treesitter, { desc = 'Telescope treesitter' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = 'Telescope old files' })
      vim.keymap.set('n', '<leader>ps', function()
        builtin.grep_string({ search = vim.fn.input("Grep > ") })
      end, { desc = 'Telescope grep prompt' })
      vim.keymap.set('n', '<leader>pf', function()
        local regex = vim.fn.input("Regex > ")
        if regex == "" then return end
        local glob = vim.fn.input("Glob > ")
        builtin.live_grep({
          default_text = regex,
          glob_pattern = glob ~= "" and glob or nil,
        })
      end, { desc = 'Telescope grep with regex and glob filter' })
    end,
  },
}
