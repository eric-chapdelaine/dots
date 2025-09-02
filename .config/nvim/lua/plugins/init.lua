return {
  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    version = "0.1.8", -- same as tag = "0.1.8"
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>sf', builtin.git_files, { desc = 'Telescope find git files' })
      vim.keymap.set('n', '<leader>sr', builtin.find_files, { desc = 'Telescope find files' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = 'Telescope live grep' })
      vim.keymap.set('n', '<leader>sb', builtin.buffers, { desc = 'Telescope buffers' })
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = 'Telescope help tags' })
      vim.keymap.set('n', '<leader>st', builtin.treesitter, { desc = 'Telescope help tags' })
      vim.keymap.set('n', '<leader>ps', function()
        builtin.grep_string({ search = vim.fn.input("Grep > ") });
      end)
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline" },
      sync_install = false,
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
    },
  },

  -- Git
  { "tpope/vim-fugitive" },

  -- LSP
  { "neovim/nvim-lspconfig" },

  -- Mason (LSP/DAP/formatter installer)
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "vtsls",
          "eslint",
          "pyright",
          "lua_ls"
        },
      })
    end,
  },

  -- Blink completion
  {
    "saghen/blink.cmp",
    version = "1.*",
    dependencies = { "rafamadriz/friendly-snippets" }, -- optional
    opts = {
      keymap = { preset = "default" },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
    },
  },

  -- { "yioneko/nvim-vtsls" },
  -- { "hrsh7th/nvim-cmp" },
  -- { "hrsh7th/cmp-nvim-lsp" },
}
