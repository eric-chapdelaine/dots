return {
  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      -- Snippet Engine
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          -- {
          --   'rafamadriz/friendly-snippets',
          --   config = function()
          --     require('luasnip.loaders.from_vscode').lazy_load()
          --   end,
          -- },
        },
        opts = {},
      },
      -- Completion sources
      'saadparwaiz1/cmp_luasnip',  -- Snippet completions
      'hrsh7th/cmp-nvim-lsp',       -- LSP completions
      'hrsh7th/cmp-path',           -- Path completions
      'hrsh7th/cmp-buffer',         -- Buffer completions
      'folke/lazydev.nvim',
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = {
          completeopt = 'menu,menuone,noinsert',
        },
        mapping = cmp.mapping.preset.insert({
          -- Ctrl+y to confirm completion (similar to blink.cmp default)
          ['<C-y>'] = cmp.mapping.confirm({ select = true }),
          
          -- Ctrl+Space to trigger completion
          ['<C-Space>'] = cmp.mapping.complete(),
          
          -- Ctrl+n/p to navigate through completion items
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          
          -- Ctrl+e to abort completion
          ['<C-e>'] = cmp.mapping.abort(),
          
          -- Ctrl+d/u to scroll docs
          ['<C-d>'] = cmp.mapping.scroll_docs(4),
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          
          -- Tab/S-Tab for snippet expansion and navigation
          ['<Tab>'] = cmp.mapping(function(fallback)
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'lazydev', group_index = 0 },  -- Lua API completion
          { name = 'nvim_lsp' },                  -- LSP completions
          { name = 'luasnip' },                   -- Snippet completions
          { name = 'path' },                      -- Path completions
        }, {
          { name = 'buffer' },                    -- Buffer completions (fallback)
        }),
        formatting = {
          format = function(entry, vim_item)
            -- Show source name in completion menu
            vim_item.menu = ({
              nvim_lsp = '[LSP]',
              luasnip = '[Snippet]',
              buffer = '[Buffer]',
              path = '[Path]',
              lazydev = '[Lua]',
            })[entry.source.name]
            return vim_item
          end,
        },
      })
    end,
  },
}
