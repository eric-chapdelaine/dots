return {
  -- Git signs in the gutter
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },
  
  -- Git commands
  {
    "tpope/vim-fugitive"
  },
  
  -- GitHub integration for fugitive (enables :GBrowse)
  {
    "tpope/vim-rhubarb",
    dependencies = { "tpope/vim-fugitive" },
  },
  
  -- Git blame with commit messages
  {
    "FabijanZulj/blame.nvim",
    config = function()
      require('blame').setup {
        date_format = "%Y-%m-%d",
        format_fn = function(line_porcelain, config, idx)
          local summary = line_porcelain.summary
          local date = os.date(config.date_format, line_porcelain.author_time)
          local hash = line_porcelain.hash:sub(1, 8)
          
          return {
            idx = idx,
            values = {
              { textValue = hash, hl = "Comment" },
              { textValue = " • ", hl = "Normal" },
              { textValue = summary, hl = "String" },
              { textValue = " • ", hl = "Normal" },
              { textValue = date, hl = "Comment" },
            },
            format = "%s%s%s%s%s"
          }
        end,
        mappings = {
          commit_info = "i",
          stack_push = "<TAB>",
          stack_pop = "<BS>",
          show_commit = "<CR>",
          close = { "<esc>", "q" },
          copy_hash = "y",
          open_in_browser = "o",  -- Open commit on GitHub
        }
      }
      
      -- Keybinding for easy access
      vim.keymap.set('n', '<leader>gb', ':BlameToggle<CR>', { desc = 'Toggle Git Blame' })
    end,
  },
}
